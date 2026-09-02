import 'package:collection/collection.dart';
import 'package:go_impl/go_impl.dart' as impl;
import 'package:sql_parser/parser.dart' as sp;

import 'db_driver_conn_meta.dart';
import 'db_driver_interface.dart';
import 'db_driver_metadata.dart';

class Db2Connection extends GoImplConnection {
  Db2Connection(super._conn);

  static const bool supportsExplainCapability = false;

  @override
  bool get supportsExplain => supportsExplainCapability;

  @override
  Future<DatabaseModeType> getDatabaseMode() async =>
      DatabaseModeType.databaseMode;

  @override
  sp.SQLDefiner parser(String sql) => sp.parser(sp.DialectType.db2, sql);

  static Future<BaseConnection> open(
      {required ConnectValue meta, DatabaseRef? schema}) async {
    final database = meta.getValue("database", "SAMPLE");
    final ssl = meta.getValue("ssl", "false");
    final timeout = meta.getValue("timeout", "15");

    final buffer = StringBuffer();
    buffer.write("hostname=${meta.getHost()};");
    buffer.write("port=${meta.getPort() ?? 50000};");
    buffer.write("database=$database;");
    buffer.write("uid=${meta.user};");
    buffer.write("pwd=${meta.password};");
    if (ssl.isNotEmpty) {
      buffer.write("ssl=$ssl;");
    }
    if (timeout.isNotEmpty) {
      buffer.write("timeout=$timeout;");
    }

    final dsn = buffer.toString();
    final conn = await impl.ImplConnection.openDb2(dsn);
    final dc = Db2Connection(conn);

    if (schema != null && schema.databaseName().isNotEmpty) {
      await dc.setCurrentSchema(DatabaseMode(database: schema.databaseName()));
    }

    return dc;
  }

  @override
  Future<void> ping() async {
    await query("SELECT 1 FROM SYSIBM.SYSDUMMY1");
  }

  @override
  Future<String> version() async {
    try {
      final results = await query(
          "SELECT SERVICE_LEVEL FROM TABLE(SYSPROC.ENV_GET_INST_INFO())");
      return results.rows.first.getString("SERVICE_LEVEL") ?? "";
    } catch (_) {
      try {
        final results = await query(
            "SELECT INST_NAME FROM TABLE(SYSPROC.ENV_GET_PROD_INFO())");
        return results.rows.first.getString("INST_NAME") ?? "";
      } catch (_) {
        return "";
      }
    }
  }

  String _escapeIdent(String ident) {
    final escaped = ident.replaceAll('"', '""');
    return '"$escaped"';
  }

  @override
  Future<void> setCurrentSchema(DatabaseRef schema) async {
    await query(
        "SET CURRENT SCHEMA = ${_escapeIdent(schema.databaseName())}");
    final currentSchema = await getCurrentSchema();
    onSchemaChanged(
        currentSchema ?? DatabaseMode(database: schema.databaseName()));
  }

  @override
  Future<DatabaseRef?> getCurrentSchema() async {
    final results = await query(
        "SELECT CURRENT SCHEMA AS CURRENT_SCHEMA FROM SYSIBM.SYSDUMMY1");
    return DatabaseMode(
        database: results.rows.first.getString("CURRENT_SCHEMA") ?? '');
  }

  @override
  Future<List<DatabaseRef>> schemas() async {
    final results = await query(
        "SELECT SCHEMANAME AS SCHEMA_NAME FROM SYSCAT.SCHEMATA WHERE SCHEMANAME NOT LIKE 'SYS%' ORDER BY SCHEMANAME");
    return results.rows
        .map((r) => r.getString("SCHEMA_NAME") ?? "")
        .where((s) => s.isNotEmpty)
        .map((s) => DatabaseMode(database: s))
        .toList();
  }

  @override
  Future<List<MetaDataNode>> metadata() async {
    final databaseList = await schemas();

    final results = await query("""SELECT
    TABSCHEMA AS TABLE_SCHEMA,
    TABNAME AS TABLE_NAME,
    COLNAME AS COLUMN_NAME,
    TYPENAME AS DATA_TYPE
FROM
    SYSCAT.COLUMNS
WHERE
    TABSCHEMA NOT LIKE 'SYS%'
ORDER BY
    TABSCHEMA,
    TABNAME,
    COLNO""");

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
    final t = dataType.toUpperCase().trim();
    return switch (t) {
      "SMALLINT" ||
      "INTEGER" ||
      "INT" ||
      "BIGINT" ||
      "DECIMAL" ||
      "DEC" ||
      "NUMERIC" ||
      "REAL" ||
      "DOUBLE" ||
      "FLOAT" ||
      "DECFLOAT" =>
        DataType.number,
      "CHAR" ||
      "VARCHAR" ||
      "LONG VARCHAR" ||
      "CLOB" ||
      "DBCLOB" ||
      "GRAPHIC" ||
      "VARGRAPHIC" =>
        DataType.char,
      "DATE" ||
      "TIME" ||
      "TIMESTAMP" ||
      "TIMESTAMPTZ" =>
        DataType.time,
      "BLOB" || "BINARY" || "VARBINARY" || "LONG VARBINARY" => DataType.blob,
      "XML" || "JSON" => DataType.json,
      _ => DataType.char,
    };
  }
}
