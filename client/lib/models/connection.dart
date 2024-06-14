import 'package:mysql_client/mysql_client.dart';

enum SQLConnectState { pending, connecting, connected, failed }

class SQLConnMetaModel {
  String host;
  int port;
  String user;
  String password;

  SQLConnMetaModel(this.host, this.port, this.user, this.password);
}

class SQLConnModel {
  SQLConnMetaModel meta;
  MySQLConnection? conn;
  SQLConnectState state = SQLConnectState.pending;

  SQLConnModel(this.meta);

  Future<void> connect() async {
    try {
      state = SQLConnectState.connecting;
      final conn = await MySQLConnection.createConnection(
          host: meta.host,
          port: meta.port,
          userName: meta.user,
          password: meta.password);
      await conn.connect();
      this.conn = conn;
      state = SQLConnectState.connected;
    } catch (e) {
      print(e);
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
}
