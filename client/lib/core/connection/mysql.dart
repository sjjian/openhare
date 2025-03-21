import 'package:client/models/instances.dart';
import 'package:db_driver/db_driver.dart';

enum SQLConnectState { pending, connecting, connected, failed }

class SQLConnectionMgr {
  InstanceModel instance;
  // MySQLConn? conn;
  BaseConnection? conn2;
  SQLConnectState state = SQLConnectState.pending;
  final void Function() onClose;
  final void Function(String) onSchemaChanged;
  String? currentSchema;

  SQLConnectionMgr(this.instance, this.onClose, this.onSchemaChanged,
      {this.currentSchema});

  Future<void> connect() async {
    try {
      conn2 = await ConnectionFactory.open(
          type: DatabaseType.mysql,
          meta: ConnectMeta(
              addr: instance.addr,
              port: instance.port,
              user: instance.user,
              password: instance.password,
              database: currentSchema),
          onCloseCallback: onClose,
          onSchemaChangedCallback: onSchemaChanged);
      state = SQLConnectState.connected;
    } catch (e) {
      print("conn error: ${e}");
      state = SQLConnectState.failed;
    }
  }

  Future<void> close() async {
    if (conn2 == null || state != SQLConnectState.connected) {
      return;
    }
    try {
      conn2!.close();
      state = SQLConnectState.pending;
      // conn = null;
    } catch (e) {
      // todo: handler error;
    }
  }
}
