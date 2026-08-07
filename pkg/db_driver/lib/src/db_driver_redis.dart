import 'dart:convert';

import 'package:go_impl/go_impl.dart' as impl;
import 'package:sql_parser/parser.dart' as sp;

import 'db_driver_conn_meta.dart';
import 'db_driver_interface.dart';
import 'db_driver_metadata.dart';

class RedisConnection extends GoImplConnection {
  RedisConnection(super._conn, this._dbIndex);

  int _dbIndex;

  @override
  bool get supportsKillQuery => false;

  static const bool supportsExplainCapability = false;

  @override
  bool get supportsExplain => supportsExplainCapability;

  @override
  Future<DatabaseModeType> getDatabaseMode() async =>
      DatabaseModeType.databaseMode;

  @override
  sp.SQLDefiner parser(String sql) => sp.parser(sp.DialectType.redis, sql);

  @override
  Stream<BaseQueryStreamItem> queryStream(String sql, {int? limit}) async* {
    final sd = parser(sql);
    sql = sd.trimDelimiter(sql);
    if (limit != null && limit > 0 && sd.canLimit) {
      sql = sd.wrapLimit(sql, limit);
    }
    yield* queryStreamInternal(sql);
    if (sd.changeSchema) {
      final currentSchema = await getCurrentSchema();
      onSchemaChanged(currentSchema ?? DatabaseMode(database: ''));
    }
  }

  /// 将 query 按 [sp.createLexer]（Redis 方言）切成参数并编码为 Go 端期望的 JSON（`cmd` / `args`）
  String _buildQuery(String sql) {
    final args = <String>[];
    final lexer = sp.createLexer(sp.DialectType.redis, sql);
    while (true) {
      final tok = lexer.scanWhere(
        (t) => t.id != sp.TokenType.whitespace && t.id != sp.TokenType.comment,
      );
      if (tok == null) {
        break;
      }
      var v = tok.content;
      // 与 SingleQValueTokenBuilder / DoubleQValueTokenBuilder / BackQValueTokenBuilder 一致：去掉包裹引号。
      if (tok.id == sp.TokenType.singleQValue ||
          tok.id == sp.TokenType.doubleQValue ||
          tok.id == sp.TokenType.backQValue) {
        if (v.length >= 2) {
          v = v.substring(1, v.length - 1);
        }
      }
      args.add(v);
    }
    if (args.isEmpty) {
      throw StateError('Empty query');
    }
    return jsonEncode(<String, dynamic>{
      'cmd': args.isNotEmpty ? args.first : '',
      'args': args.length > 1 ? args.sublist(1) : const <String>[],
    });
  }

  @override
  Stream<BaseQueryStreamItem> queryStreamInternal(String sql) async* {
    List<BaseQueryColumn>? columns;

    final wire = _buildQuery(sql);
    await for (final item in implConn.streamQuery(wire)) {
      switch (item) {
        case impl.DbQueryCancel():
          yield const QueryStreamItemCancel();
        case impl.DbQueryHeader():
          columns = item.columns
              .map<BaseQueryColumn>((c) => GoImplQueryColumn(c))
              .toList(growable: false);
          yield QueryStreamItemHeader(
            columns: columns,
            affectedRows: item.affectedRows,
          );
        case impl.DbQueryRow():
          final currentColumns = columns;
          if (currentColumns == null) {
            throw StateError('No header received before row');
          }
          yield QueryStreamItemRow(
            row: QueryResultRow(
              currentColumns,
              item.values
                  .map<BaseQueryValue>((c) => GoImplQueryValue(c))
                  .toList(growable: false),
            ),
          );
      }
    }
  }

  static Future<BaseConnection> open(
      {required ConnectValue meta, DatabaseRef? schema}) async {
    final db = meta.getIntValue('db', 0);
    final tls = meta.getValue('tls', 'false').toLowerCase() == 'true' ||
        meta.getValue('ssl', 'false').toLowerCase() == 'true';
    final user = meta.user.trim();
    final pass = meta.password;

    String? userInfo;
    if (user.isNotEmpty) {
      userInfo = '$user:${Uri.encodeComponent(pass)}';
    } else if (pass.isNotEmpty) {
      userInfo = ':${Uri.encodeComponent(pass)}';
    }

    final uri = Uri(
      scheme: tls ? 'rediss' : 'redis',
      userInfo: userInfo,
      host: meta.getHost().isEmpty ? '127.0.0.1' : meta.getHost(),
      port: meta.getPort() ?? 6379,
      path: '/$db',
    );
    final conn = await impl.ImplConnection.openRedis(uri.toString());
    final r = RedisConnection(conn, db);
    if (schema != null && schema.databaseName().isNotEmpty) {
      final n = int.tryParse(schema.databaseName().trim());
      if (n != null && n >= 0) {
        await r.query('SELECT $n');
        r._dbIndex = n;
      }
    }
    return r;
  }

  @override
  Future<void> ping() async {
    await query('PING');
  }

  @override
  Future<String> version() async {
    final r = await query('INFO server');
    if (r.rows.isEmpty) {
      return '';
    }
    final raw = r.rows.first.getString('result');
    if (raw == null || raw.isEmpty) {
      return '';
    }
    String text;
    try {
      final decoded = jsonDecode(raw);
      text = decoded is String ? decoded : raw;
    } catch (_) {
      text = raw;
    }
    for (final l in text.split(RegExp(r'\r?\n'))) {
      final s = l.trim();
      if (s.startsWith('redis_version:')) {
        return s.substring('redis_version:'.length).trim();
      }
    }
    return '';
  }

  /// 逻辑库数量来自 `CONFIG GET databases`；失败时按默认 16 个库处理。
  @override
  Future<List<DatabaseRef>> schemas() async {
    var count = 16;
    try {
      final r = await query('CONFIG GET databases');
      if (r.rows.isNotEmpty) {
        final raw = r.rows.first.getString('result');
        if (raw != null && raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          int? n;
          if (decoded is Map) {
            final v = decoded['databases'];
            if (v != null) {
              n = int.tryParse(v.toString());
            }
          } else if (decoded is List && decoded.length >= 2) {
            n = int.tryParse(decoded[1].toString());
          }
          if (n != null && n > 0) {
            count = n;
          }
        }
      }
    } catch (_) {
      // CONFIG 可能被禁用或拒绝。
    }
    return List<DatabaseRef>.generate(
        count, (i) => DatabaseMode(database: '$i'));
  }

  @override
  Future<void> setCurrentSchema(DatabaseRef schema) async {
    final n = int.tryParse(schema.databaseName().trim());
    if (n == null || n < 0) {
      return;
    }
    await query('SELECT $n');
    _dbIndex = n;
    onSchemaChanged(schema);
  }

  @override
  Future<DatabaseRef?> getCurrentSchema() async =>
      DatabaseMode(database: '$_dbIndex');

  @override
  Future<List<MetaDataNode>> metadata() async {
    final names = await schemas();
    return names
        .map((n) =>
            MetaDataNode(MetaType.database, n.databaseName())..items = [])
        .toList();
  }
}
