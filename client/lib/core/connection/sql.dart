import 'package:client/models/instances.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:common/parser.dart';

enum SQLConnectState { pending, connecting, connected, failed }

class SQLConnection {
  InstanceModel instance;
  MySQLConnection? conn;
  SQLConnectState state = SQLConnectState.pending;
  final void Function() onClose;

  SQLConnection(this.instance, this.onClose);

  Future<void> connect() async {
    try {
      state = SQLConnectState.connecting;
      final conn = await MySQLConnection.createConnection(
          host: instance.addr,
          port: instance.port,
          userName: instance.user,
          password: instance.password);
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

  Future<IResultSet> execute(String query) async {
    // 判断是否是 SELECT 语句, 若是则嵌套一层 LIMIT 限制返回数据量, 暂时为100行. todo: 通用方法处理
    final firstTok = Lexer(query).firstTrim();
    if (firstTok != null && firstTok.content == "select") {
      query = query.trimRight();
      if (query.endsWith(";")) query = query.substring(0, query.length - 1);
      query = "SELECT * FROM ($query) AS dt_1 Limit 100;";
    }
    // 加入注释. todo: 通用方法处理
    query = "/* call by natuo */ $query";
    IResultSet resultSet = await conn!.execute(query);
    return resultSet;
  }
}
