// import 'package:client/core/connection/metadata.dart';
// import 'package:client/models/instances.dart';
// import 'package:mysql_client/mysql_client.dart' as mysql;
// import 'package:common/parser.dart';
// import 'package:client/core/connection/result_set.dart';
// import 'package:mysql_client/mysql_protocol.dart';

// enum SQLConnectState { pending, connecting, connected, failed }

// class SQLConnection {
//   InstanceModel instance;
//   mysql.MySQLConnection? conn;
//   SQLConnectState state = SQLConnectState.pending;
//   final void Function() onClose;
//   final void Function(String) onSchemaChanged;
//   String? currentSchema;

//   SQLConnection(this.instance, this.onClose, this.onSchemaChanged,
//       {this.currentSchema});

//   Future<void> connect() async {
//     try {
//       state = SQLConnectState.connecting;
//       final conn = await mysql.MySQLConnection.createConnection(
//         host: instance.addr,
//         port: instance.port,
//         userName: instance.user,
//         password: instance.password,
//         databaseName: currentSchema, // todo: connect 后再切换db
//       );
//       await conn.connect();
//       this.conn = conn;
//       conn.onClose(() {
//         state = SQLConnectState.pending;
//         onClose();
//       });

//       if (currentSchema != null) {
//         onSchemaChanged(currentSchema!);
//       }

//       state = SQLConnectState.connected;
//     } catch (e) {
//       state = SQLConnectState.failed;
//     }
//   }

//   Future<void> close() async {
//     if (conn == null || state != SQLConnectState.connected) {
//       return;
//     }
//     try {
//       await conn!.close();
//       state = SQLConnectState.pending;
//       conn = null;
//     } catch (e) {
//       // todo: handler error;
//     }
//   }

//   Future<mysql.IResultSet> _execute(String query) async {
//     // 加入注释. todo: 通用方法处理
//     query = "/* call by natuo */ $query";
//     mysql.IResultSet resultSet = await conn!.execute(query);
//     return resultSet;
//   }

//   ValueType convertMySQLType(MySQLColumnType mt) {
//     return switch (mt.intVal) {
//       mysqlColumnTypeDate ||
//       mysqlColumnTypeDateTime ||
//       mysqlColumnTypeDateTime2 ||
//       mysqlColumnTypeTimestamp ||
//       mysqlColumnTypeTimestamp2 ||
//       mysqlColumnTypeTime ||
//       mysqlColumnTypeTime2 ||
//       mysqlColumnTypeNewDate /* driver 未使用到*/ =>
//         ValueType.time,
//       mysqlColumnTypeTiny ||
//       mysqlColumnTypeShort ||
//       mysqlColumnTypeLong ||
//       mysqlColumnTypeLongLong ||
//       mysqlColumnTypeInt24 ||
//       mysqlColumnTypeYear ||
//       mysqlColumnTypeFloat ||
//       mysqlColumnTypeDouble ||
//       mysqlColumnTypeDecimal ||
//       mysqlColumnTypeNewDecimal =>
//         ValueType.number,
//       mysqlColumnTypeLongBlob ||
//       mysqlColumnTypeMediumBlob ||
//       mysqlColumnTypeBlob ||
//       mysqlColumnTypeTinyBlob ||
//       mysqlColumnTypeBit =>
//         ValueType.bit,
//       mysqlColumnTypeVarChar ||
//       mysqlColumnTypeEnum ||
//       mysqlColumnTypeSet ||
//       mysqlColumnTypeVarString ||
//       mysqlColumnTypeString =>
//         ValueType.str,
//       mysqlColumnTypeGeometry => ValueType.str,
//       mysqlColumnTypeNull /* driver 未使用到*/ => ValueType.str,
//       _ => ValueType.str,
//     };
//   }

//   Future<ResultSet> execute(String query) async {
//     print("start");
//     // 判断是否是 SELECT 语句, 若是则嵌套一层 LIMIT 限制返回数据量, 暂时为100行. todo: 通用方法处理
//     final firstTok = Lexer(query).firstTrim();
//     if (firstTok != null && firstTok.content.toLowerCase() == "select") {
//       query = query.trimRight();
//       if (query.endsWith(";")) query = query.substring(0, query.length - 1);
//       query = "SELECT * FROM ($query) AS dt_1 Limit 100;";
//     }
//     mysql.IResultSet resultSet = await _execute(query);
//     // 如果执行的语句包含`use schema`
//     if (firstTok != null && firstTok.content.toLowerCase() == "use") {
//       await getCurrentSchema();
//       onSchemaChanged(currentSchema!);
//     }
//         print("00000000");
//     List<ResultSetColumn> columns = resultSet.cols.map<ResultSetColumn>((e) {
//       return ResultSetColumn(e.name, convertMySQLType(e.type));
//     }).toList();
//     print(1111111111);
//     List<ResultSetRow> rows = List.empty(growable: true);
//     for (final result in resultSet) {
//       for (final row in result.rows) {
//         rows.add(ResultSetRow(columns.map<MySQLResultSetValue>((e) {
//           return MySQLResultSetValue(e, row.colByName(e.name));
//         }).toList()));
//       }
//     }
//         print(22222222);
//     return ResultSet(columns, rows, resultSet.affectedRows);
//   }

//   Future<List<String>> schemas() async {
//     List<String> schemas = List.empty(growable: true);
//     mysql.IResultSet resultSet = await _execute("show databases");
//     for (final result in resultSet) {
//       for (final row in result.rows) {
//         schemas.add(row.colByName("Database")!);
//       }
//     }
//     return schemas;
//   }

//   Future<void> setCurrentSchema(String schema) async {
//     await _execute("USE $schema");
//     await getCurrentSchema();
//     onSchemaChanged(currentSchema!);
//   }

//   Future<String?> getCurrentSchema() async {
//     mysql.IResultSet resultSet = await _execute("SELECT DATABASE()");
//     currentSchema = resultSet.first.rows.first.colByName("DATABASE()");
//     return currentSchema;
//   }

//   Future<List<String>> getTables(String schema) async {
//     List<String> tables = List.empty(growable: true);
//     mysql.IResultSet resultSet = await _execute(
//         "select TABLE_NAME from information_schema.tables where table_schema='$schema' and TABLE_TYPE in ('BASE TABLE','SYSTEM VIEW')");
//     for (final result in resultSet) {
//       for (final row in result.rows) {
//         tables.add(row.colByName("TABLE_NAME")!);
//       }
//     }
//     return tables;
//   }

//   Future<List<TableColumnMeta>> getTableColumns(
//       String schema, String table) async {
//     List<TableColumnMeta> columns = List.empty(growable: true);
//     // ref: https://dev.mysql.com/doc/refman/8.4/en/information-schema-columns-table.html
//     mysql.IResultSet resultSet = await _execute(
//         "select COLUMN_NAME, COLUMN_DEFAULT, IS_NULLABLE, DATA_TYPE, CHARACTER_SET_NAME, COLLATION_NAME, COLUMN_TYPE, COLUMN_KEY, COLUMN_COMMENT, EXTRA from information_schema.columns where TABLE_SCHEMA = '$schema' and TABLE_NAME = '$table'");
//     for (final result in resultSet) {
//       for (final row in result.rows) {
//         columns.add(TableColumnMeta.loadFromRow(row));
//       }
//     }
//     return columns;
//   }

//   Future<List<TableKeyMeta>> getTableKeys(String schema, String table) async {
//     List<TableKeyMeta> keys = List.empty(growable: true);
//     mysql.IResultSet resultSet = await _execute(
//         "SELECT INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX SEPARATOR \",\") AS COLUMNS FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = '$schema' AND TABLE_NAME = '$table' GROUP BY INDEX_NAME");
//     for (final result in resultSet) {
//       for (final row in result.rows) {
//         keys.add(TableKeyMeta.loadFromRow(row));
//       }
//     }
//     return keys;
//   }
// }


