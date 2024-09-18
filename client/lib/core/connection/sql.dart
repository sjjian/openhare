import 'package:client/models/instances.dart';
import 'package:mysql_client/mysql_client.dart';

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
    IResultSet resultSet =  await conn!.execute(query);
    return resultSet;
  }
}
