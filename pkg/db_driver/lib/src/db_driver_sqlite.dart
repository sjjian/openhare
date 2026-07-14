import 'package:collection/collection.dart';
import 'package:sql_parser/parser.dart' as sp;
import 'package:go_impl/go_impl.dart' as impl;

import 'db_driver_conn_meta.dart';
import 'db_driver_interface.dart';
import 'db_driver_metadata.dart';

class SQLiteConnection extends GoImplConnection {
  SQLiteConnection(super._conn);

  @override
  Future<DatabaseModeType> getDatabaseMode() async =>
      DatabaseModeType.singleMode;

  @override
  sp.SQLDefiner parser(String sql) => sp.parser(sp.DialectType.sqlite, sql);

  @override
  Future<BaseQueryResult> explain(String sql) {
    sql = parser(sql).trimDelimiter(sql);
    return query('EXPLAIN QUERY PLAN $sql');
  }

  static Future<BaseConnection> open(
      {required ConnectValue meta, DatabaseRef? schema}) async {
    var dsn = meta.getDbFile();
    if (dsn.startsWith("file://")) {
      dsn = Uri.parse(dsn).toFilePath();
    }
    final conn =
        await impl.ImplConnection.openSqlite(dsn.isEmpty ? ":memory:" : dsn);
    final sqliteConn = SQLiteConnection(conn);
    return sqliteConn;
  }

  @override
  Future<void> ping() async {
    await query("SELECT 1");
  }

  @override
  Future<String> version() async {
    final results = await query("SELECT sqlite_version() AS version");
    return results.rows.first.getString("version") ?? "";
  }

  @override
  Future<List<DatabaseRef>> schemas() async {
    return [];
  }

  @override
  Future<void> setCurrentSchema(DatabaseRef schema) async {
    return;
  }

  @override
  Future<DatabaseRef?> getCurrentSchema() async {
    return null;
  }

  @override
  Future<List<MetaDataNode>> metadata() async {
    final results = await query("""SELECT
    m.name AS TABLE_NAME,
    p.name AS COLUMN_NAME,
    p.type AS DATA_TYPE
FROM
    sqlite_master AS m
JOIN
    pragma_table_info(m.name) AS p
WHERE
    m.type IN ('table', 'view')
    AND m.name NOT LIKE 'sqlite_%'
ORDER BY
    m.name,
    p.cid;""");

    final tableNodes = <MetaDataNode>[];
    final tableRows =
        results.rows.groupListsBy((result) => result.getString("TABLE_NAME")!);

    for (final table in tableRows.keys) {
      final tableNode = MetaDataNode(MetaType.table, table);
      tableNodes.add(tableNode);

      final columnRows = tableRows[table]!;
      final columnNodes = columnRows
          .map((result) =>
              MetaDataNode(MetaType.column, result.getString("COLUMN_NAME")!)
                ..withProp(
                  MetaDataPropType.dataType,
                  _getDataType(result.getString("DATA_TYPE") ?? ""),
                ))
          .toList();
      tableNode.items = columnNodes;
    }

    return tableNodes;
  }

  static DataType _getDataType(String dataType) {
    final t = dataType.toUpperCase().trim();
    if (t.contains("INT") ||
        t.contains("REAL") ||
        t.contains("FLOA") ||
        t.contains("DOUB") ||
        t.contains("NUMERIC") ||
        t.contains("DECIMAL")) {
      return DataType.number;
    }
    if (t.contains("CHAR") || t.contains("CLOB") || t.contains("TEXT")) {
      return DataType.char;
    }
    if (t.contains("DATE") || t.contains("TIME")) {
      return DataType.time;
    }
    if (t.contains("BLOB")) {
      return DataType.blob;
    }
    if (t.contains("JSON")) {
      return DataType.json;
    }
    return DataType.char;
  }
}
