// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:go_impl/go_impl.dart' as impl;
import 'db_driver_interface.dart';
import 'db_driver_metadata.dart';
import 'package:sql_parser/parser.dart' as sp;
import 'package:db_driver/src/db_driver_conn_meta.dart';

class MySQLConnection extends GoImplConnection {
  MySQLConnection(super._conn);

  @override
  Future<DatabaseModeType> getDatabaseMode() async =>
      DatabaseModeType.databaseMode;

  @override
  sp.SQLDefiner parser(String sql) => sp.parser(sp.DialectType.mysql, sql);

  static Future<BaseConnection> open(
      {required ConnectValue meta, DatabaseRef? schema}) async {
    final database = schema?.databaseName() ?? meta.getValue("database", "");
    final host = meta.getHost();
    final port = meta.getPort() ?? 3306;
    final user = meta.user;
    final password = meta.password;

    final dsn = '$user:$password@tcp($host:$port)/$database';

    final conn = await impl.ImplConnection.openMysql(dsn);
    final mc = MySQLConnection(conn);
    return mc;
  }

  @override
  Future<void> ping() async {
    await query("SELECT 1");
  }

  @override
  Future<String> version() async {
    final results = await query("SELECT VERSION() AS version");
    return results.rows.first.getString("version") ?? "";
  }

  @override
  Future<List<DatabaseRef>> schemas() async {
    final results = await query("SHOW DATABASES");
    return results.rows
        .map((r) => r.getString("Database") ?? "")
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
    final results = await query("SELECT DATABASE() AS current_schema");
    return DatabaseMode(
        database: results.rows.first.getString("current_schema") ?? '');
  }

  @override
  Future<List<MetaDataNode>> metadata() async {
    final databaseList = await schemas();

    final results = await query("""SELECT 
    t.TABLE_SCHEMA,
    t.TABLE_NAME,
    c.COLUMN_NAME,
    c.DATA_TYPE
FROM 
    information_schema.TABLES t
JOIN 
    information_schema.COLUMNS c 
    ON t.TABLE_NAME = c.TABLE_NAME 
    AND t.TABLE_SCHEMA = c.TABLE_SCHEMA
WHERE 
    t.TABLE_TYPE IN ('BASE TABLE', 'SYSTEM VIEW')
ORDER BY
    t.TABLE_SCHEMA,
    t.TABLE_NAME, 
    c.ORDINAL_POSITION;""");

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
    return switch (t) {
      "int" ||
      "bigint" ||
      "smallint" ||
      "tinyint" ||
      "decimal" ||
      "double" ||
      "float" ||
      "mediumint" ||
      "bit" =>
        DataType.number,
      "char" || "varchar" || "binary" || "varbinary" => DataType.char,
      "datetime" || "time" || "timestamp" || "date" || "year" => DataType.time,
      "text" ||
      "blob" ||
      "longblob" ||
      "longtext" ||
      "mediumblob" ||
      "mediumtext" ||
      "tinyblob" ||
      "tinytext" =>
        DataType.blob,
      "json" => DataType.json,
      "set" || "enum" => DataType.dataSet,
      _ => DataType.blob,
    };
  }
}
