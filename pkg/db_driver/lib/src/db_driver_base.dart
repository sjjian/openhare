import 'db_driver_interface.dart';
import 'db_driver_conn_meta.dart';
import 'db_driver_mysql.dart';
import 'package:mysql/mysql.dart' as mysql_lib;
import 'db_driver_pg.dart';

class ConnectionFactory {
  static Future<void> init() async {
    await mysql_lib.RustLib.init();
  }

  static Future<BaseConnection> open(
      {required DatabaseType type,
      required ConnectValue meta,
      String? schema,
      Function()? onCloseCallback,
      Function(String)? onSchemaChangedCallback}) async {
    final conn = switch (type) {
      DatabaseType.mysql =>
        await MySQLConnection.open(meta: meta, schema: schema),
      DatabaseType.pg => await PGConnection.open(meta: meta, schema: schema),
    };
    conn.listen(
        onCloseCallback: onCloseCallback,
        onSchemaChangedCallback: onSchemaChangedCallback);
    return conn;
  }
}

List<ConnectionMeta> connectionMetas = [
  ConnectionMeta(
    displayName: "MySQL",
    type: DatabaseType.mysql,
    logoAssertPath: "assets/icons/mysql_icon.png",
    connMeta: [
      NameMeta(),
      AddressMeta(),
      UserMeta(),
      PasswordMeta(),
      DescMeta(),
    ],
  ),
  ConnectionMeta(
    displayName: "PostgreSQL",
    type: DatabaseType.pg,
    logoAssertPath: "assets/icons/pg_icon.png",
    connMeta: [
      NameMeta(),
      AddressMeta(),
      UserMeta(),
      PasswordMeta(),
      DescMeta(),
      CustomMeta(
          name: "database", type: "text", group: "conn", isRequired: true),
    ],
  ),
];

List<DatabaseType> allDatabaseType =
    connectionMetas.map((meta) => meta.type).toList();

Map<DatabaseType, ConnectionMeta> connectionMetaMap = {
  for (var meta in connectionMetas) meta.type: meta
};
