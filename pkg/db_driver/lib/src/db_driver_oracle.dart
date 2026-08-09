// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:go_impl/go_impl.dart' as impl;
import 'package:sql_parser/parser.dart' as sp;

import 'db_driver_conn_meta.dart';
import 'db_driver_interface.dart';
import 'db_driver_metadata.dart';

class OracleConnection extends GoImplConnection {
  OracleConnection(super._conn);

  static const bool supportsExplainCapability = true;

  @override
  bool get supportsExplain => supportsExplainCapability;

  @override
  Future<DatabaseModeType> getDatabaseMode() async =>
      DatabaseModeType.databaseMode;

  @override
  sp.SQLDefiner parser(String sql) => sp.parser(sp.DialectType.oracle, sql);

  /// Oracle 的 EXPLAIN PLAN FOR 只写入计划表，需再查 DBMS_XPLAN 才能拿到可读结果。
  @override
  Future<BaseQueryResult> explain(String sql) async {
    sql = parser(sql).trimDelimiter(sql);
    await query('EXPLAIN PLAN FOR $sql');
    return query("SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY())");
  }

  static Future<BaseConnection> open(
      {required ConnectValue meta, DatabaseRef? schema}) async {
    final service = meta.getValue("service", "FREEPDB1");
    final dsn = Uri(
      scheme: "oracle",
      userInfo: '${meta.user}:${Uri.encodeComponent(meta.password)}',
      host: meta.getHost(),
      port: meta.getPort() ?? 1521,
      path: service,
    ).toString();

    final conn = await impl.ImplConnection.openOracle(dsn);
    final oc = OracleConnection(conn);

    if (schema != null && schema.databaseName().isNotEmpty) {
      await oc.setCurrentSchema(DatabaseMode(database: schema.databaseName()));
    }

    return oc;
  }

  @override
  Future<void> ping() async {
    await query("SELECT 1 FROM dual");
  }

  @override
  Future<String> version() async {
    try {
      final results = await query(
          "SELECT banner AS version FROM v\\$version WHERE rownum = 1");
      return results.rows.first.getString("VERSION") ?? "";
    } catch (_) {
      final results = await query(
          "SELECT version AS version FROM product_component_version WHERE rownum = 1");
      return results.rows.first.getString("VERSION") ?? "";
    }
  }

  String _escapeIdent(String ident) {
    final escaped = ident.replaceAll('"', '""');
    return '"$escaped"';
  }

  @override
  Future<void> setCurrentSchema(DatabaseRef schema) async {
    await query(
        "ALTER SESSION SET CURRENT_SCHEMA = ${_escapeIdent(schema.databaseName())}");
    final currentSchema = await getCurrentSchema();
    onSchemaChanged(
        currentSchema ?? DatabaseMode(database: schema.databaseName()));
  }

  @override
  Future<DatabaseRef?> getCurrentSchema() async {
    final results = await query(
        "SELECT SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AS CURRENT_SCHEMA FROM dual");
    return DatabaseMode(
        database: results.rows.first.getString("CURRENT_SCHEMA") ?? '');
  }

  @override
  Future<List<DatabaseRef>> schemas() async {
    final results = await query(
        "SELECT username AS SCHEMA_NAME FROM all_users ORDER BY username");
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
    owner AS TABLE_SCHEMA,
    table_name AS TABLE_NAME,
    column_name AS COLUMN_NAME,
    data_type AS DATA_TYPE
FROM
    all_tab_columns
ORDER BY
    owner,
    table_name,
    column_id""");

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
      "NUMBER" ||
      "BINARY_FLOAT" ||
      "BINARY_DOUBLE" ||
      "FLOAT" ||
      "INTEGER" ||
      "DECIMAL" =>
        DataType.number,
      "VARCHAR2" ||
      "NVARCHAR2" ||
      "CHAR" ||
      "NCHAR" ||
      "CLOB" ||
      "NCLOB" =>
        DataType.char,
      "DATE" ||
      "TIMESTAMP" ||
      "TIMESTAMP WITH TIME ZONE" ||
      "TIMESTAMP WITH LOCAL TIME ZONE" =>
        DataType.time,
      "BLOB" || "RAW" || "LONG RAW" || "BFILE" => DataType.blob,
      "JSON" => DataType.json,
      _ => DataType.char,
    };
  }
}
