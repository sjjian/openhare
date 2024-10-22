import 'package:client/models/instances.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:common/parser.dart';

enum SQLConnectState { pending, connecting, connected, failed }

class SQLConnection {
  InstanceModel instance;
  MySQLConnection? conn;
  SQLConnectState state = SQLConnectState.pending;
  final void Function() onClose;
  String? currentSchema;

  SQLConnection(this.instance, this.onClose, {this.currentSchema});

  Future<void> connect() async {
    try {
      state = SQLConnectState.connecting;
      final conn = await MySQLConnection.createConnection(
          host: instance.addr,
          port: instance.port,
          userName: instance.user,
          password: instance.password,
          databaseName: currentSchema, // todo: connect 后再切换db
          );
      await conn.connect();
      this.conn = conn;
      conn.onClose(() {
        state = SQLConnectState.pending;
        onClose();
      });
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

  Future<IResultSet> _execute(String query) async {
    // 加入注释. todo: 通用方法处理
    query = "/* call by natuo */ $query";
    IResultSet resultSet = await conn!.execute(query);
    return resultSet;
  }

  Future<IResultSet> execute(String query) async {
    // 判断是否是 SELECT 语句, 若是则嵌套一层 LIMIT 限制返回数据量, 暂时为100行. todo: 通用方法处理
    final firstTok = Lexer(query).firstTrim();
    if (firstTok != null && firstTok.content.toLowerCase() == "select") {
      query = query.trimRight();
      if (query.endsWith(";")) query = query.substring(0, query.length - 1);
      query = "SELECT * FROM ($query) AS dt_1 Limit 100;";
    }
    IResultSet resultSet = await _execute(query);
    // 如果执行的语句包含`use schema`
    if (firstTok != null && firstTok.content.toLowerCase() == "use") {
      await getCurrentSchema();
    }
    return resultSet;
  }

  Future<List<String>> schemas() async {
    List<String> schemas = List.empty(growable: true);
    IResultSet resultSet = await _execute("show databases");
    for (final result in resultSet) {
      for (final row in result.rows) {
        schemas.add(row.colByName("Database")!);
      }
    }
    return schemas;
  }

  Future<void> setCurrentSchema(String schema) async {
    await _execute("USE $schema");
    await getCurrentSchema();
  }

  Future<String?> getCurrentSchema() async {
    IResultSet resultSet = await _execute("SELECT DATABASE()");
    currentSchema = resultSet.first.rows.first.colByName("DATABASE()");
    return currentSchema;
  }
}
