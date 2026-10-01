// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:go_impl/go_impl.dart' as impl;
import 'package:sql_parser/parser.dart' as sp;

import 'db_driver_conn_meta.dart';
import 'db_driver_interface.dart';
import 'db_driver_metadata.dart';

class ClickHouseConnection extends GoImplConnection {
  ClickHouseConnection(super._conn);

  static const bool supportsExplainCapability = true;
  static const bool supportsSelectSqlCapability = true;
  static const bool supportsInsertSqlCapability = true;

  static String quoteIdent(String ident) =>
      '`${ident.replaceAll('`', '``')}`';
  static String placeholder(int index) => '?';

  static String buildSelectSql({
    required String name,
    String? database,
    String? schema,
    List<String> columns = const [],
  }) {
    final relation = qualifyRelation(
      quoteIdent,
      name: name,
      database: database,
      schema: schema,
    );
    final colList =
        columns.isEmpty ? '*' : columns.map(quoteIdent).join(',\n  ');
    return 'SELECT\n  $colList\nFROM $relation;';
  }

  static String buildInsertSql({
    required String name,
    String? database,
    String? schema,
    List<String> columns = const [],
  }) {
    final relation = qualifyRelation(
      quoteIdent,
      name: name,
      database: database,
      schema: schema,
    );
    if (columns.isEmpty) return 'INSERT INTO $relation;';
    final colList = columns.map(quoteIdent).join(', ');
    final placeholders = [
      for (var i = 1; i <= columns.length; i++) placeholder(i),
    ].join(', ');
    return 'INSERT INTO $relation ($colList)\nVALUES ($placeholders);';
  }

  @override
  bool get supportsExplain => supportsExplainCapability;

  @override
  bool get supportsSelectSql => supportsSelectSqlCapability;

  @override
  bool get supportsInsertSql => supportsInsertSqlCapability;

  @override
  Future<DatabaseModeType> getDatabaseMode() async =>
      DatabaseModeType.databaseMode;

  @override
  sp.SQLDefiner parser(String sql) =>
      sp.parser(sp.DialectType.clickhouse, sql);

  @override
  Future<BaseQueryResult> explain(String sql) {
    sql = parser(sql).trimDelimiter(sql);
    return query('EXPLAIN $sql');
  }

  static Future<BaseConnection> open(
      {required ConnectValue meta, DatabaseRef? schema}) async {
    final database = schema?.databaseName() ?? meta.getValue("database", "default");
    final host = meta.getHost();
    final port = meta.getPort() ?? 9000;
    final user = meta.user.trim().isEmpty ? "default" : meta.user;
    final password = meta.password;
    final protocol = meta.getValue("protocol", "native").toLowerCase();
    final secure = meta.getValue("secure", "false").toLowerCase() == "true";
    final compress = meta.getValue("compress", "lz4");
    final connectTimeout = meta.getIntValue("connectTimeout", 10);

    final scheme = switch ((protocol, secure)) {
      ("http", true) => "https",
      ("http", false) => "http",
      _ => "clickhouse",
    };

    final queryParameters = <String, String>{
      "dial_timeout": "${connectTimeout}s",
      "compress": compress,
    };
    if (protocol != "http") {
      queryParameters["secure"] = secure ? "true" : "false";
    }

    final dsn = Uri(
      scheme: scheme,
      userInfo: '$user:${Uri.encodeComponent(password)}',
      host: host,
      port: port,
      path: '/$database',
      queryParameters: queryParameters,
    ).toString();

    final conn = await impl.ImplConnection.openClickhouse(dsn);
    return ClickHouseConnection(conn);
  }

  @override
  Future<void> ping() async {
    await query("SELECT 1");
  }

  @override
  Future<String> version() async {
    final results = await query("SELECT version() AS version");
    return results.rows.first.getString("version") ?? "";
  }

  @override
  Future<List<DatabaseRef>> schemas() async {
    final results = await query("SHOW DATABASES");
    return results.rows
        .map((r) {
          final name = r.getString("name");
          if (name != null && name.isNotEmpty) return name;
          if (r.values.isNotEmpty) return r.values.first.getString() ?? "";
          return "";
        })
        .where((s) => s.isNotEmpty)
        .map((s) => DatabaseMode(database: s))
        .toList();
  }

  @override
  Future<void> setCurrentSchema(DatabaseRef schema) async {
    final escaped = schema.databaseName().replaceAll('`', '``');
    await query("USE `$escaped`");
    final currentSchema = await getCurrentSchema();
    onSchemaChanged(currentSchema ?? DatabaseMode(database: ''));
  }

  @override
  Future<DatabaseRef?> getCurrentSchema() async {
    final results = await query("SELECT currentDatabase() AS current_schema");
    return DatabaseMode(
        database: results.rows.first.getString("current_schema") ?? '');
  }

  @override
  Future<List<MetaDataNode>> metadata() async {
    final databaseList = await schemas();

    final results = await query("""SELECT
    c.database AS TABLE_SCHEMA,
    c.table AS TABLE_NAME,
    c.name AS COLUMN_NAME,
    c.type AS DATA_TYPE
FROM system.columns c
INNER JOIN system.tables t
    ON c.database = t.database
    AND c.table = t.name
ORDER BY
    c.database,
    c.table,
    c.position""");

    final rows = results.rows;
    final databaseRows =
        rows.groupListsBy((result) => result.getString("TABLE_SCHEMA")!);

    final databaseNodes = <MetaDataNode>[];
    for (final database in databaseList) {
      final databaseNode =
          MetaDataNode(MetaType.database, database.databaseName());
      databaseNodes.add(databaseNode);

      final tableNodes = <MetaDataNode>[];
      final tableRows = databaseRows[database.databaseName()];
      if (tableRows != null) {
        final byTable =
            tableRows.groupListsBy((result) => result.getString("TABLE_NAME")!);
        for (final table in byTable.keys) {
          final tableNode = MetaDataNode(MetaType.table, table);
          tableNodes.add(tableNode);

          final columnRows = byTable[table]!;
          final columnNodes = columnRows
              .map((result) => MetaDataNode(
                  MetaType.column, result.getString("COLUMN_NAME")!)
                ..withProp(MetaDataPropType.dataType,
                    _getDataType(result.getString("DATA_TYPE")!)))
              .toList();
          tableNode.items = columnNodes;
        }
      }
      databaseNode.items = tableNodes;
    }
    return databaseNodes;
  }

  static DataType _getDataType(String dataType) {
    final t = dataType.toLowerCase().trim();
    if (t.contains("array") ||
        t.contains("map") ||
        t.contains("tuple") ||
        t.contains("nested") ||
        t.contains("json") ||
        t.contains("object") ||
        t.contains("variant") ||
        t.contains("dynamic")) {
      return DataType.json;
    }
    if (t.contains("date") || t.contains("time") || t.contains("interval")) {
      return DataType.time;
    }
    if (t.contains("int") ||
        t.contains("float") ||
        t.contains("decimal") ||
        t.contains("numeric") ||
        t.contains("bool") ||
        t.contains("bfloat")) {
      return DataType.number;
    }
    if (t.contains("string") ||
        t.contains("uuid") ||
        t.contains("enum") ||
        t.contains("ipv") ||
        t.contains("fixedstring")) {
      return DataType.char;
    }
    return DataType.blob;
  }
}
