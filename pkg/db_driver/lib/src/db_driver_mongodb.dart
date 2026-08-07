import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:go_impl/go_impl.dart' as impl;
import 'package:sql_parser/parser.dart' as sp;
import 'package:uuid/uuid.dart';

import 'db_driver_conn_meta.dart';
import 'db_driver_interface.dart';
import 'db_driver_metadata.dart';

class MongoConnection extends GoImplConnection {
  MongoConnection(super._conn, this._currentDb);

  DatabaseRef _currentDb;

  @override
  bool get supportsKillQuery => false;

  static const bool supportsExplainCapability = false;

  @override
  bool get supportsExplain => supportsExplainCapability;

  @override
  Future<DatabaseModeType> getDatabaseMode() async =>
      DatabaseModeType.databaseMode;

  static Future<BaseConnection> open(
      {required ConnectValue meta, DatabaseRef? schema}) async {
    final user = meta.user.trim();
    final pass = meta.password;
    String? userInfo;
    if (user.isNotEmpty) {
      userInfo = '$user:${Uri.encodeComponent(pass)}';
    } else if (pass.isNotEmpty) {
      userInfo = ':${Uri.encodeComponent(pass)}';
    }

    final dbName = meta.getValue('database', 'test').trim().isEmpty
        ? 'test'
        : meta.getValue('database', 'test').trim();
    final authSource = meta.getValue('authSource', '').trim();
    final tls = meta.getValue('tls', 'false').toLowerCase() == 'true' ||
        meta.getValue('ssl', 'false').toLowerCase() == 'true';
    final directConnection =
        meta.getValue('directConnection', 'true').trim().toLowerCase() ==
            'true';

    final qp = <String, String>{};
    if (authSource.isNotEmpty) {
      qp['authSource'] = authSource;
    }
    if (tls) {
      qp['tls'] = 'true';
    }
    if (directConnection) {
      qp['directConnection'] = 'true';
    }

    final uri = Uri(
      scheme: 'mongodb',
      userInfo: userInfo,
      host: meta.getHost().isEmpty ? '127.0.0.1' : meta.getHost(),
      port: meta.getPort() ?? 27017,
      path: '/$dbName',
      queryParameters: qp.isEmpty ? null : qp,
    );

    final conn = await impl.ImplConnection.openMongo(uri.toString());
    return MongoConnection(conn, schema ?? DatabaseMode(database: dbName));
  }

  @override
  sp.SQLDefiner parser(String sql) => sp.parser(sp.DialectType.mongodb, sql);

  static String _buildQuery(String shell, DatabaseRef db, {int? maxRows}) {
    final m = <String, dynamic>{'shell': shell, 'db': db.databaseName()};
    if (maxRows != null && maxRows > 0) {
      m['maxRows'] = maxRows;
    }
    return jsonEncode(m);
  }

  @override
  Stream<BaseQueryStreamItem> queryStream(String sql, {int? limit}) async* {
    final sd = parser(sql);
    sql = sd.trimDelimiter(sql);
    final query = _buildQuery(sql, _currentDb, maxRows: limit);
    yield* queryStreamInternal(query);

    if (sd.changeSchema) {
      final currentSchema = await getCurrentSchema();
      onSchemaChanged(currentSchema ?? DatabaseMode(database: ''));
    }
  }

  Future<BaseQueryResult> _queryOnDb(String sql, DatabaseRef database) async {
    final sd = parser(sql);
    final shell = sd.trimDelimiter(sql);
    final wire = _buildQuery(shell, _currentDb);

    final queryId = Uuid().v4();
    List<BaseQueryColumn>? resultColumns;
    BigInt? resultAffectedRows;
    final rows = <QueryResultRow>[];

    await for (final item in queryStreamInternal(wire)) {
      switch (item) {
        case QueryStreamItemHeader(:final columns, :final affectedRows):
          resultColumns = columns;
          resultAffectedRows = affectedRows;
        case QueryStreamItemRow(:final row):
          rows.add(row);
        case QueryStreamItemCancel():
          throw const QueryCancelledException();
      }
    }

    if (resultColumns == null || resultAffectedRows == null) {
      throw StateError('No header received');
    }
    return BaseQueryResult(
      queryId,
      resultColumns,
      rows,
      resultAffectedRows,
    );
  }

  @override
  Future<void> ping() async {
    await query('db.version()');
  }

  @override
  Future<String> version() async {
    final r = await query('db.version()');
    return r.rows.firstOrNull?.getString('version') ?? '';
  }

  @override
  Future<List<DatabaseRef>> schemas() async {
    final r = await query('show dbs');
    return r.rows
        .map((e) => DatabaseMode(database: e.getString('name') ?? ''))
        .toList(growable: false);
  }

  @override
  Future<DatabaseRef?> getCurrentSchema() async => _currentDb;

  @override
  Future<void> setCurrentSchema(DatabaseRef schema) async {
    final s = schema.databaseName().trim();
    if (s.isEmpty) {
      return;
    }
    _currentDb = schema;
    onSchemaChanged(schema);
  }

  @override
  Future<List<MetaDataNode>> metadata() async {
    final dbs = await schemas();
    final out = <MetaDataNode>[];
    for (final db in dbs) {
      final dbNode = MetaDataNode(MetaType.database, db.databaseName());
      try {
        final r = await _queryOnDb('db.getCollectionNames()', db);
        dbNode.items = r.rows
            .map((row) =>
                MetaDataNode(MetaType.table, row.getString('name') ?? ''))
            .where((n) => n.value.isNotEmpty)
            .toList();
      } catch (_) {
        dbNode.items = [];
      }
      out.add(dbNode);
    }
    return out;
  }
}
