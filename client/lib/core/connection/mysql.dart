import 'package:client/core/connection/metadata.dart';
import 'package:client/models/instances.dart';
import 'package:common/parser.dart';
import 'package:client/core/connection/result_set.dart';
import 'package:mysql1/mysql1.dart';
import 'dart:math';

enum SQLConnectState { pending, connecting, connected, failed }

class MySQLResultSetValue implements ResultSetValue {
  final Object? value;
  final ValueType _type;

  MySQLResultSetValue(this.value, this._type);

  static ValueType convertMySQLType(String mt) {
    return switch (mt) {
      'DATE' ||
      'DATETIME' ||
      'TIMESTAMP' ||
      'TIME' ||
      'NEWDATE' =>
        ValueType.time,
      'TINY' ||
      'SHORT' ||
      'LONG' ||
      'LONGLONG' ||
      'INT24' ||
      'YEAR' ||
      'FLOAT' ||
      'DOUBLE' ||
      'NEWDECIMAL' ||
      'DECIMAL' =>
        ValueType.number,
      'LONG_BLOB' ||
      'MEDIUM_BLOB' ||
      'BLOB' ||
      'TINY_BLOB' ||
      'BIT' =>
        ValueType.bit,
      'VARCHAR' || 'ENUM' || 'SET' || 'VAR_STRING' || 'STRING' => ValueType.str,
      'GEOMETRY' => ValueType.str,
      'JSON' => ValueType.json,
      _ => ValueType.str,
    };
  }

  @override
  ValueType type() {
    return _type;
  }

  @override
  String? asString() {
    return value?.toString();
  }

  @override
  List<int> asByte() {
    if (value == null) {
      return List.empty();
    }
    if (value is Blob) {
      return (value as Blob).toBytes();
    }
    return List<int>.empty();
  }

  @override
  String? summary() {
    String? value = asString();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value
        .substring(0, min(value.length, 50))
        .replaceAll('\r\n', '\n')
        .replaceAll("\r", "\n")
        .replaceAll("\n", " ");
  }
}

class SQLConnection {
  InstanceModel instance;
  MySqlConnection? conn;
  SQLConnectState state = SQLConnectState.pending;
  final void Function() onClose;
  final void Function(String) onSchemaChanged;
  String? currentSchema;

  SQLConnection(this.instance, this.onClose, this.onSchemaChanged,
      {this.currentSchema});

  Future<void> connect() async {
    try {
      // Open a connection (testdb should already exist)
      conn = await MySqlConnection.connect(ConnectionSettings(
          host: instance.addr,
          port: instance.port,
          user: instance.user,
          db: currentSchema,
          password: instance.password,
          ));

      state = SQLConnectState.connected;
    } catch (e) {
      state = SQLConnectState.failed;
    }
  }

  Future<void> close() async {
    if (conn == null || state != SQLConnectState.connected) {
      return;
    }
    try {
      await conn!.close();
      state = SQLConnectState.pending;
      conn = null;
    } catch (e) {
      // todo: handler error;
    }
  }

  Future<ResultSet> _execute(String query) async {
    // 加入注释. todo: 通用方法处理
    query = "/* call by natuo */ $query";
    Results results = await conn!.query(query);

    List<ResultSetColumn> columns = results.fields.map<ResultSetColumn>((e) {
      return ResultSetColumn(
          e.name!, MySQLResultSetValue.convertMySQLType(e.typeString));
    }).toList();

    List<ResultSetRow> rows = List.empty(growable: true);
    for (final result in results) {
      rows.add(ResultSetRow(columns.map<ResultSetCell>((e) {
        return ResultSetCell(e, MySQLResultSetValue(result[e.name], e.type));
      }).toList()));
    }
    return ResultSet(columns, rows, results.affectedRows);
  }

  Future<ResultSet> execute(String query) async {
    // 判断是否是 SELECT 语句, 若是则嵌套一层 LIMIT 限制返回数据量, 暂时为100行. todo: 通用方法处理
    final firstTok = Lexer(query).firstTrim();
    if (firstTok != null && firstTok.content.toLowerCase() == "select") {
      query = query.trimRight();
      if (query.endsWith(";")) query = query.substring(0, query.length - 1);
      query = "SELECT * FROM ($query) AS dt_1 Limit 100;";
    }
    ResultSet results = await _execute(query);
    // 如果执行的语句包含`use schema`
    if (firstTok != null && firstTok.content.toLowerCase() == "use") {
      await getCurrentSchema();
      onSchemaChanged(currentSchema!);
    }
    return results;
  }

  Future<List<String>> schemas() async {
    List<String> schemas = List.empty(growable: true);
    ResultSet results = await _execute("show databases");
    for (final result in results.rows) {
      schemas.add(result.getString("Database")!);
    }
    return schemas;
  }

  Future<void> setCurrentSchema(String schema) async {
    await _execute("USE $schema");
    await getCurrentSchema();
    onSchemaChanged(currentSchema!);
  }

  Future<String?> getCurrentSchema() async {
    ResultSet results = await _execute("SELECT DATABASE()");
    currentSchema = results.rows.first.getString("DATABASE()");
    return currentSchema;
  }

  Future<List<String>> getTables(String schema) async {
    List<String> tables = List.empty(growable: true);
    ResultSet results = await _execute(
        "select TABLE_NAME from information_schema.tables where table_schema='$schema' and TABLE_TYPE in ('BASE TABLE','SYSTEM VIEW')");
    for (final result in results.rows) {
      tables.add(result.getString("TABLE_NAME")!);
    }
    return tables;
  }

  Future<List<TableColumnMeta>> getTableColumns(
      String schema, String table) async {
    List<TableColumnMeta> columns = List.empty(growable: true);
    // ref: https://dev.mysql.com/doc/refman/8.4/en/information-schema-columns-table.html
    ResultSet results = await _execute(
        "select COLUMN_NAME, COLUMN_DEFAULT, IS_NULLABLE, DATA_TYPE, CHARACTER_SET_NAME, COLLATION_NAME, COLUMN_TYPE, COLUMN_KEY, COLUMN_COMMENT, EXTRA from information_schema.columns where TABLE_SCHEMA = '$schema' and TABLE_NAME = '$table'");
    for (final result in results.rows) {
      columns.add(TableColumnMeta.loadFromRow(result));
    }
    return columns;
  }

  Future<List<TableKeyMeta>> getTableKeys(String schema, String table) async {
    List<TableKeyMeta> keys = List.empty(growable: true);
    ResultSet results = await _execute(
        "SELECT INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX SEPARATOR \",\") AS COLUMNS FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = '$schema' AND TABLE_NAME = '$table' GROUP BY INDEX_NAME");
    for (final result in results.rows) {
      keys.add(TableKeyMeta.loadFromRow(result));
    }
    return keys;
  }
}
