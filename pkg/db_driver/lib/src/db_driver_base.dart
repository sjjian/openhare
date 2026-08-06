import 'package:sql_parser/parser.dart';

import 'db_driver_interface.dart';
import 'db_driver_conn_meta.dart';
import 'db_driver_metadata.dart';
import 'ssh_tunnel.dart';
import 'db_driver_mysql.dart';
import 'db_driver_oracle.dart';
import 'db_driver_mssql.dart';
import 'db_driver_sqlite.dart';
import 'db_driver_pg.dart';
import 'db_driver_redis.dart';
import 'db_driver_mongodb.dart';
import 'db_driver_duckdb.dart';

/// 封装具体 [BaseConnection]，并统一管理 SSH 隧道生命周期。
class ConnectionWrapper extends BaseConnection {
  ConnectionWrapper(this._inner, {SshTunnel? sshTunnel})
      : _sshTunnel = sshTunnel;

  final BaseConnection _inner;
  final SshTunnel? _sshTunnel;
  bool _closed = false;

  BaseConnection get inner => _inner;

  SshTunnel? get sshTunnel => _sshTunnel;

  static Future<ConnectionWrapper> open({
    required DatabaseType type,
    required ConnectValue meta,
    DatabaseRef? schema,
    Function(DatabaseRef)? onSchemaChangedCallback,
  }) async {
    ConnectionWrapper? wrapper;
    SshTunnel? tunnel;
    try {
      late final ConnectValue wireMeta;
      if (type == DatabaseType.sqlite || type == DatabaseType.duckdb) {
        wireMeta = meta;
      } else {
        final sshConfig = meta.sshTunnel;
        if (sshConfig != null && sshConfig.enabled) {
          tunnel = SshTunnel(
            config: sshConfig,
            targetHost: meta.getHost(),
            targetPort: meta.getPort()!,
          );
          await tunnel.open();
        }
        final wireHost = tunnel?.host ?? meta.getHost();
        final wirePort = tunnel?.port ?? meta.getPort()!;
        wireMeta = ConnectValue(
          name: meta.name,
          target: ConnectTarget.network(host: wireHost, port: wirePort),
          user: meta.user,
          password: meta.password,
          desc: meta.desc,
          custom: Map<String, String>.from(meta.custom),
          initQuerys: meta.initQuerys,
        );
      }
      final inner = switch (type) {
        DatabaseType.mysql =>
          await MySQLConnection.open(meta: wireMeta, schema: schema),
        DatabaseType.pg =>
          await PGConnection.open(meta: wireMeta, schema: schema),
        DatabaseType.oracle =>
          await OracleConnection.open(meta: wireMeta, schema: schema),
        DatabaseType.mssql =>
          await MSSQLConnection.open(meta: wireMeta, schema: schema),
        DatabaseType.sqlite =>
          await SQLiteConnection.open(meta: wireMeta, schema: schema),
        DatabaseType.redis =>
          await RedisConnection.open(meta: wireMeta, schema: schema),
        DatabaseType.mongodb =>
          await MongoConnection.open(meta: wireMeta, schema: schema),
        DatabaseType.duckdb =>
          await DuckDBConnection.open(meta: wireMeta, schema: schema),
      };
      final opened = ConnectionWrapper(inner, sshTunnel: tunnel);
      opened.listen(onSchemaChangedCallback: onSchemaChangedCallback);

      for (var sql in meta.initQuerys) {
        await opened.query(sql);
      }
      wrapper = opened;
    } catch (e) {
      await wrapper?.close();
      if (wrapper == null) {
        await tunnel?.close();
      }
      rethrow;
    }
    return wrapper;
  }

  @override
  bool get supportsKillQuery => _inner.supportsKillQuery;

  @override
  bool get supportsExplain => _inner.supportsExplain;

  @override
  void listen({
    Function()? onCloseCallback,
    Function(DatabaseRef)? onSchemaChangedCallback,
  }) {
    _inner.listen(
      onCloseCallback: onCloseCallback,
      onSchemaChangedCallback: onSchemaChangedCallback,
    );
    super.listen(
      onCloseCallback: onCloseCallback,
      onSchemaChangedCallback: onSchemaChangedCallback,
    );
  }

  @override
  Future<void> ping() => _inner.ping();

  @override
  Future<void> killQuery() => _inner.killQuery();

  @override
  Stream<BaseQueryStreamItem> queryStreamInternal(String sql) =>
      _inner.queryStreamInternal(sql);

  @override
  Future<DatabaseModeType> getDatabaseMode() => _inner.getDatabaseMode();

  @override
  Future<List<MetaDataNode>> metadata() => _inner.metadata();

  @override
  Future<List<DatabaseRef>> schemas() => _inner.schemas();

  @override
  Future<DatabaseRef?> getCurrentSchema() => _inner.getCurrentSchema();

  @override
  Future<void> setCurrentSchema(DatabaseRef schema) =>
      _inner.setCurrentSchema(schema);

  @override
  Future<String> version() => _inner.version();

  @override
  SQLDefiner parser(String sql) => _inner.parser(sql);

  @override
  Future<BaseQueryResult> explain(String sql) => _inner.explain(sql);

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    await _inner.close();
    await _sshTunnel?.close();
  }
}

List<ConnectionMeta> connectionMetas = [
  ConnectionMeta(
    displayName: "MySQL",
    type: DatabaseType.mysql,
    logoAssertPath: "assets/icons/mysql_icon.png",
    connMeta: [
      NameMeta(),
      TargetNetworkMeta(defaultPort: "3306"),
      SshTunnelMeta(group: settingMetaGroupSshTunnel),
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
        TargetNetworkMeta(defaultPort: "5432"),
        SshTunnelMeta(group: settingMetaGroupSshTunnel),
        UserMeta(),
        PasswordMeta(),
        DescMeta(),
        CustomMeta(
            name: "database",
            type: SettingMetaType.text,
            group: settingMetaGroupBase,
            isRequired: true,
            defaultValue: "postgres"),
        CustomMeta(
          name: "connectTimeout",
          type: SettingMetaType.text,
          group: settingMetaGroupParams,
          defaultValue: "10",
        ),
        CustomMeta(
          name: "queryTimeout",
          type: SettingMetaType.text,
          group: settingMetaGroupParams,
          defaultValue: "600",
        ),
      ],
      // postgresql init sql
      initQuerys: [
        "SET client_encoding = 'UTF8';",
      ]),
  ConnectionMeta(
    displayName: "Oracle",
    type: DatabaseType.oracle,
    logoAssertPath: "assets/icons/oracle_icon.png",
    connMeta: [
      NameMeta(),
      TargetNetworkMeta(defaultPort: "1521"),
      SshTunnelMeta(group: settingMetaGroupSshTunnel),
      UserMeta(),
      PasswordMeta(),
      DescMeta(),
      CustomMeta(
          name: "service",
          type: SettingMetaType.text,
          group: settingMetaGroupBase,
          isRequired: true,
          defaultValue: "FREEPDB1"),
    ],
    initQuerys: const [],
  ),
  ConnectionMeta(
    displayName: "SQL Server",
    type: DatabaseType.mssql,
    logoAssertPath: "assets/icons/mssql_icon.png",
    connMeta: [
      NameMeta(),
      TargetNetworkMeta(defaultPort: "1433"),
      SshTunnelMeta(group: settingMetaGroupSshTunnel),
      UserMeta(),
      PasswordMeta(),
      DescMeta(),
      CustomMeta(
          name: "database",
          type: SettingMetaType.text,
          group: settingMetaGroupBase,
          isRequired: true,
          defaultValue: "master"),
      CustomMeta(
        name: "encrypt",
        type: SettingMetaType.enumValue,
        group: settingMetaGroupParams,
        defaultValue: "true",
        enumValues: ['true', 'false'],
      ),
      CustomMeta(
        name: "trustServerCertificate",
        type: SettingMetaType.enumValue,
        group: settingMetaGroupParams,
        defaultValue: "true",
        enumValues: ['true', 'false'],
      ),
      CustomMeta(
        name: "tlsmin",
        type: SettingMetaType.enumValue,
        group: settingMetaGroupParams,
        defaultValue: "1.2",
        enumValues: ["1.0", "1.1", "1.2", "1.3"],
      ),
    ],
    initQuerys: const [],
  ),
  ConnectionMeta(
    displayName: "SQLite",
    type: DatabaseType.sqlite,
    logoAssertPath: "assets/icons/sqlite_icon.png",
    connMeta: [
      NameMeta(),
      TargetDBFileMeta(),
      DescMeta(),
    ],
    initQuerys: const [
      "PRAGMA temp_store = MEMORY;",
      "PRAGMA journal_mode = MEMORY;",
    ],
  ),
  ConnectionMeta(
    displayName: "Redis",
    type: DatabaseType.redis,
    logoAssertPath: "assets/icons/redis_icon.png",
    connMeta: [
      NameMeta(),
      TargetNetworkMeta(defaultPort: "6379"),
      SshTunnelMeta(group: settingMetaGroupSshTunnel),
      UserMeta(),
      PasswordMeta(),
      DescMeta(),
      CustomMeta(
        name: "db",
        type: SettingMetaType.text,
        group: settingMetaGroupBase,
        defaultValue: "0",
      ),
      CustomMeta(
        name: "tls",
        type: SettingMetaType.enumValue,
        group: settingMetaGroupParams,
        defaultValue: "false",
        enumValues: ['true', 'false'],
      ),
    ],
    initQuerys: const [],
  ),
  ConnectionMeta(
    displayName: 'MongoDB',
    description: """
The connection driver uses mongosh-compatible shell syntax and leverages the gomongo library. Summary of unsupported features:
1. No interactive features (cursor methods, native shell functions), no JavaScript execution, and no database switching. 
2. It also excludes cluster/administration features (replication, sharding, user/role management, encryption) and Atlas-specific capabilities.
3. Database is set at connection time only, no database switching.
""",
    type: DatabaseType.mongodb,
    logoAssertPath: 'assets/icons/mongodb_icon.png',
    connMeta: [
      NameMeta(),
      TargetNetworkMeta(defaultPort: '27017'),
      SshTunnelMeta(group: settingMetaGroupSshTunnel),
      UserMeta(),
      PasswordMeta(),
      DescMeta(),
      CustomMeta(
        name: 'database',
        type: SettingMetaType.text,
        group: settingMetaGroupBase,
        isRequired: true,
        defaultValue: 'test',
        // comment: '连接 URI 路径中的默认数据库名，并作为 shell 执行的默认库',
      ),
      CustomMeta(
        name: 'authSource',
        type: SettingMetaType.text,
        group: settingMetaGroupParams,
        defaultValue: 'admin',
        // comment: 'SCRAM 等认证时查找用户凭证所在的数据库（URI 参数 authSource）',
      ),
      CustomMeta(
        name: 'tls',
        type: SettingMetaType.enumValue,
        group: settingMetaGroupParams,
        enumValues: ['true', 'false'],
        defaultValue: 'false',
        // comment: '是否启用 TLS（true/false，对应 URI 中 tls 选项）',
      ),
      CustomMeta(
        name: 'directConnection',
        type: SettingMetaType.enumValue,
        group: settingMetaGroupParams,
        defaultValue: 'true',
        enumValues: ['true', 'false'],
        // comment: '为 true 时只连当前主机端口，不解析副本集拓扑（URI 参数 directConnection）',
      ),
    ],
    initQuerys: const [],
  ),
  ConnectionMeta(
    displayName: "DuckDB",
    type: DatabaseType.duckdb,
    logoAssertPath: "assets/icons/duckdb_icon.png",
    description:
        "DuckDB is an in-process analytical database. Connect via a local .duckdb file or leave empty for an in-memory database.",
    connMeta: [
      NameMeta(),
      TargetDBFileMeta(),
      DescMeta(),
    ],
    initQuerys: const [],
  ),
];

List<DatabaseType> allDatabaseType =
    connectionMetas.map((meta) => meta.type).toList();

Map<DatabaseType, ConnectionMeta> connectionMetaMap = {
  for (var meta in connectionMetas) meta.type: meta
};

List<SettingMeta> getConnMetas(DatabaseType type) {
  return connectionMetaMap[type]?.connMeta ?? const <SettingMeta>[];
}
