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
    BaseConnection? conn;
    try {
      conn = switch (type) {
        DatabaseType.mysql =>
          await MySQLConnection.open(meta: meta, schema: schema),
        DatabaseType.pg => await PGConnection.open(meta: meta, schema: schema),
      };
      conn.listen(
          onCloseCallback: onCloseCallback,
          onSchemaChangedCallback: onSchemaChangedCallback);

      for (var sql in meta.initQuerys) {
        await conn.query(sql);
      }
    } catch (e) {
      conn?.close();
      rethrow;
    }
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
      PortMeta("3306"),
      UserMeta(),
      PasswordMeta(),
      DescMeta(),
    ],
    initQuerys: [
      "SET NAMES utf8mb4;",
      "SET CHARACTER SET utf8mb4;",
      "SET character_set_connection=utf8mb4;",
      "SET sql_mode = 'STRICT_ALL_TABLES';",
    ],
  ),
  ConnectionMeta(
      displayName: "PostgreSQL",
      type: DatabaseType.pg,
      logoAssertPath: "assets/icons/pg_icon.png",
      connMeta: [
        NameMeta(),
        AddressMeta(),
        PortMeta("5432"),
        UserMeta(),
        PasswordMeta(),
        DescMeta(),
        CustomMeta(
            name: "database",
            type: "text",
            group: "connection",
            isRequired: true,
            defaultValue: "postgres"),
        CustomMeta(
          name: "connectTimeout",
          type: "text",
          group: "connection",
          defaultValue: "10",
        ),
        CustomMeta(
          name: "queryTimeout",
          type: "text",
          group: "connection",
          defaultValue: "600",
        ),
      ],
      // postgresql init sql
      initQuerys: [
        "SET client_encoding = 'UTF8';",
      ]),
];

List<DatabaseType> allDatabaseType =
    connectionMetas.map((meta) => meta.type).toList();

Map<DatabaseType, ConnectionMeta> connectionMetaMap = {
  for (var meta in connectionMetas) meta.type: meta
};
