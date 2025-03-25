// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:mysql/mysql.dart';
import 'db_driver_interface.dart';
import 'db_driver_metadata.dart';
import 'package:common/parser.dart';

class MysqlQueryValue extends BaseQueryValue {
  final QueryValue _value;

  MysqlQueryValue(this._value);

  @override
  String? getString() {
    return _value.when<String?>(
      bytes: (field0) => utf8.decode(field0),
      int: (field0) => field0.toString(),
      uInt: (field0) => field0.toString(),
      float: (field0) => field0.toString(),
      double: (field0) => field0.toString(),
      dateTime: (field0) => field0.toString(),
      null_: () => null,
    );
  }

  @override
  List<int> getBytes() {
    return _value.maybeWhen(
        bytes: (field0) {
          return field0;
        },
        orElse: () => List.empty());
  }
}

class MysqlQueryColumn extends BaseQueryColumn {
  final QueryColumn _column;

  MysqlQueryColumn(this._column);

  @override
  String get name => _column.name;

  static const MYSQL_TYPE_DECIMAL = 0;
  static const MYSQL_TYPE_TINY = 1;
  static const MYSQL_TYPE_SHORT = 2;
  static const MYSQL_TYPE_LONG = 3;
  static const MYSQL_TYPE_FLOAT = 4;
  static const MYSQL_TYPE_DOUBLE = 5;
  static const MYSQL_TYPE_NULL = 6;
  static const MYSQL_TYPE_TIMESTAMP = 7;
  static const MYSQL_TYPE_LONGLONG = 8;
  static const MYSQL_TYPE_INT24 = 9;
  static const MYSQL_TYPE_DATE = 10;
  static const MYSQL_TYPE_TIME = 11;
  static const MYSQL_TYPE_DATETIME = 12;
  static const MYSQL_TYPE_YEAR = 13;
  static const MYSQL_TYPE_NEWDATE = 14;
  static const MYSQL_TYPE_VARCHAR = 15;
  static const MYSQL_TYPE_BIT = 16;
  static const MYSQL_TYPE_TIMESTAMP2 = 17;
  static const MYSQL_TYPE_DATETIME2 = 18;
  static const MYSQL_TYPE_TIME2 = 19;
  static const MYSQL_TYPE_TYPED_ARRAY = 20;
  static const MYSQL_TYPE_VECTOR = 242;
  static const MYSQL_TYPE_UNKNOWN = 243;
  static const MYSQL_TYPE_JSON = 245;
  static const MYSQL_TYPE_NEWDECIMAL = 246;
  static const MYSQL_TYPE_ENUM = 247;
  static const MYSQL_TYPE_SET = 248;
  static const MYSQL_TYPE_TINY_BLOB = 249;
  static const MYSQL_TYPE_MEDIUM_BLOB = 250;
  static const MYSQL_TYPE_LONG_BLOB = 251;
  static const MYSQL_TYPE_BLOB = 252;
  static const MYSQL_TYPE_VAR_STRING = 253;
  static const MYSQL_TYPE_STRING = 254;
  static const MYSQL_TYPE_GEOMETRY = 255;

  @override
  DataType dataType() {
    return switch (_column.columnType) {
      MYSQL_TYPE_JSON => DataType.json, // JSON

      MYSQL_TYPE_BIT ||
      MYSQL_TYPE_TINY_BLOB ||
      MYSQL_TYPE_MEDIUM_BLOB ||
      MYSQL_TYPE_LONG_BLOB ||
      MYSQL_TYPE_BLOB =>
        DataType.blob, // BLOB, TINY_BLOB, MEDIUM_BLOB, LONG_BLOB

      MYSQL_TYPE_VARCHAR ||
      MYSQL_TYPE_VAR_STRING ||
      MYSQL_TYPE_STRING =>
        DataType.char, // STRING, VARCHAR, VAR_STRING

      MYSQL_TYPE_TIMESTAMP ||
      MYSQL_TYPE_DATE ||
      MYSQL_TYPE_TIME ||
      MYSQL_TYPE_DATETIME ||
      MYSQL_TYPE_YEAR ||
      MYSQL_TYPE_TIMESTAMP2 ||
      MYSQL_TYPE_DATETIME2 ||
      MYSQL_TYPE_TIME2 =>
        DataType.time, // DATE, DATETIME, TIMESTAMP

      MYSQL_TYPE_DECIMAL ||
      MYSQL_TYPE_TINY ||
      MYSQL_TYPE_SHORT ||
      MYSQL_TYPE_LONG ||
      MYSQL_TYPE_FLOAT ||
      MYSQL_TYPE_DOUBLE ||
      MYSQL_TYPE_LONGLONG ||
      MYSQL_TYPE_INT24 ||
      MYSQL_TYPE_NEWDECIMAL =>
        DataType.number, // number

      _ => DataType.char,
    };
  }
}

class MySQLConnection extends BaseConnection {
  final ConnWrapper _conn;

  MySQLConnection(this._conn);

  static Future<BaseConnection> open({required ConnectMeta meta}) async {
    var dsn = "mysql://${meta.user}:${meta.password}@${meta.addr}:${meta.port}";
    if (meta.schema != null) {
      dsn = "$dsn/${meta.schema}";
    }
    final conn = await ConnWrapper.open(dsn: dsn);
    return MySQLConnection(conn);
  }

  @override
  Future<void> close() async {
    await _conn.close();
    _conn.dispose();
  }

  @override
  Future<BaseQueryResult> query(String sql) async {
    BaseQueryResult results;
    // 判断是否是 SELECT 语句, 若是则嵌套一层 LIMIT 限制返回数据量, 暂时为100行. todo: 通用方法处理
    final firstTok = Lexer(sql).firstTrim();
    if (firstTok != null && firstTok.content.toLowerCase() == "select") {
      sql = sql.trimRight();
      if (sql.endsWith(";")) sql = sql.substring(0, sql.length - 1);
      sql = "SELECT * FROM ($sql) AS dt_1 Limit 100;";
    }
    results = await _query(sql);
    // 如果执行的语句包含`use schema`
    if (firstTok != null && firstTok.content.toLowerCase() == "use") {
      final schema = await getCurrentSchema();
      onSchemaChanged(schema ?? "");
    }
    return results;
  }

  Future<BaseQueryResult> _query(String sql) async {
    // 加入注释. todo: 通用方法处理
    sql = "/* call by natuo */ $sql";
    final qs = await _conn.query(query: sql);
    final columns =
        qs.columns.map<BaseQueryColumn>((qs) => MysqlQueryColumn(qs)).toList();
    List<QueryResultRow> rows = List.empty(growable: true);
    for (final r in qs.rows) {
      rows.add(QueryResultRow(
          columns, r.values.map((v) => MysqlQueryValue(v)).toList()));
    }
    return BaseQueryResult(columns, rows, qs.affectedRows);
  }

  @override
  Future<MetaDataNode> metadata() async {
    MetaDataNode metadata = MetaDataNode(MetaType.instance, "");
    List<String> schemas = await this.schemas();

    List<MetaDataNode> schemaNodes = List.empty(growable: true);
    metadata.items = schemaNodes;
    for (var schema in schemas) {
      MetaDataNode schemaNode = MetaDataNode(MetaType.schema, schema);
      // SchemaMeta schemaMeta = SchemaMeta(schema);
      schemaNodes.add(schemaNode);
      List<MetaDataNode> tables = await getTables(schema);
      schemaNode.items = tables;
      for (var table in tables) {
        // TableMeta tableMeta = TableMeta(table);
        // schemaMeta.tables.add(tableMeta);
        // todo: 一次性获取所有表信息
        List<MetaDataNode> columns = await getTableColumns(schema, table.value);

        table.items = columns;

        // List<TableKeyMeta> keys =
        //     await session!.conn!.getTableKeys(schema, table);
        // tableMeta.keys = keys;
      }
    }
    return metadata;
  }

  @override
  Future<List<String>> schemas() async {
    List<String> schemas = List.empty(growable: true);
    final results = await _query("show databases");
    for (final result in results.rows) {
      schemas.add(result.getString("Database") ?? "");
    }
    return schemas;
  }

  @override
  Future<void> setCurrentSchema(String schema) async {
    await _query("USE $schema");
    final currentSchema = await getCurrentSchema();
    onSchemaChanged(currentSchema!);
  }

  @override
  Future<String?> getCurrentSchema() async {
    final results = await _query("SELECT DATABASE()");
    final rows = results.rows;
    final currentSchema = rows.first.getString("DATABASE()");
    return currentSchema;
  }

  Future<List<MetaDataNode>> getTables(String schema) async {
    List<MetaDataNode> tables = List.empty(growable: true);
    final results = await _query(
        "select TABLE_NAME from information_schema.tables where table_schema='$schema' and TABLE_TYPE in ('BASE TABLE','SYSTEM VIEW')");
    final rows = results.rows;
    for (final result in rows) {
      tables.add(MetaDataNode(MetaType.table, result.getString("TABLE_NAME")!));
      // tables.add();
    }
    return tables;
  }

  static DataType getDataType(String dataType) {
    return switch (dataType) {
      "int" ||
      "bigint" ||
      "smallint" ||
      "tinyint" ||
      "decimal" ||
      "double" ||
      "float" =>
        DataType.number,
      "char" || "varchar" => DataType.char,
      "datetime" || "time" || "timestamp" => DataType.time,
      "text" ||
      "blob" ||
      "longblob" ||
      "longtext" ||
      "mediumblob" ||
      "mediumtext" =>
        DataType.blob,
      "json" => DataType.json,
      "set" || "enum" => DataType.dataSet,
      _ => DataType.blob,
    };
  }

  Future<List<MetaDataNode>> getTableColumns(
      String schema, String table) async {
    List<MetaDataNode> columns = List.empty(growable: true);
    // ref: https://dev.mysql.com/doc/refman/8.4/en/information-schema-columns-table.html
    final results = await _query(
        "select COLUMN_NAME, COLUMN_DEFAULT, IS_NULLABLE, DATA_TYPE, CHARACTER_SET_NAME, COLLATION_NAME, COLUMN_TYPE, COLUMN_KEY, COLUMN_COMMENT, EXTRA from information_schema.columns where TABLE_SCHEMA = '$schema' and TABLE_NAME = '$table'");
    final rows = results.rows;
    for (final result in rows) {
      final node = MetaDataNode(MetaType.column, result.getString("COLUMN_NAME")!)
      ..withProp(MetaDataPropType.dataType, getDataType(result.getString("DATA_TYPE")!));

      columns.add(node);
      // columns.add(TableColumnMeta.loadFromRow(result));
    }
    return columns;
  }

  // Future<List<MetaDataNode>> getTableKeys(String schema, String table) async {
  //   List<TableKeyMeta> keys = List.empty(growable: true);
  //   final results = await _query(
  //       "SELECT INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX SEPARATOR \",\") AS COLUMNS FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = '$schema' AND TABLE_NAME = '$table' GROUP BY INDEX_NAME");
  //   final rows = results.rows;
  //   for (final result in rows) {
  //     keys.add(TableKeyMeta.loadFromRow(result));
  //   }
  //   return keys;
  // }
}
