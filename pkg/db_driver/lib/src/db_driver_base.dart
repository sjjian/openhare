import 'db_driver_interface.dart';
import 'db_driver_mysql.dart';
import 'package:mysql/mysql.dart' as mysql_lib;
import 'db_driver_pg.dart';

class ConnectionFactory {
  static Future<void> init() async {
    await mysql_lib.RustLib.init();
  }

  static Future<BaseConnection> open(
      {required DatabaseType type,
      required ConnectMeta meta,
      Function()? onCloseCallback,
      Function(String)? onSchemaChangedCallback}) async {
    final conn =  switch (type) {
       DatabaseType.mysql=>  await MySQLConnection.open(meta: meta),
       DatabaseType.pg =>await PGConnection.open(meta: meta),
    };
    conn.listen(onCloseCallback: onCloseCallback, onSchemaChangedCallback: onSchemaChangedCallback);
    return conn;
  }
}
