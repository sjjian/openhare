import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sql_parser/parser.dart';

part 'db_driver_conn_meta.freezed.dart';
part 'db_driver_conn_meta.g.dart';

enum DatabaseType {
  mysql,
  pg,
  oracle,
  mssql,
  sqlite,
  redis,
  mongodb,
  duckdb;

  DialectType get dialectType {
    switch (this) {
      case DatabaseType.mysql:
        return DialectType.mysql;
      case DatabaseType.pg:
        return DialectType.pg;
      case DatabaseType.oracle:
        return DialectType.oracle;
      case DatabaseType.mssql:
        return DialectType.mssql;
      case DatabaseType.sqlite:
        return DialectType.sqlite;
      case DatabaseType.redis:
        return DialectType.redis;
      case DatabaseType.mongodb:
        return DialectType.mongodb;
      case DatabaseType.duckdb:
        return DialectType.duckdb;
    }
  }
}

enum ConnectTargetType { network, dbFile }

@Freezed(toStringOverride: false)
abstract class ConnectTarget with _$ConnectTarget {
  const ConnectTarget._();
  const factory ConnectTarget.network({
    required String host,
    required int port,
  }) = _ConnectTargetNetwork;
  const factory ConnectTarget.dbFile({required String dbFile}) =
      _ConnectTargetDbFile;

  factory ConnectTarget.fromJson(Map<String, dynamic> json) =>
      _$ConnectTargetFromJson(json);

  @override
  String toString() {
    return when(
      dbFile: (dbFile) => dbFile.trim(),
      network: (host, port) => "${host.trim()}:$port",
    );
  }
}

const String settingMetaGroupBase = "base";
const String settingMetaGroupParams = "params";
const String settingMetaGroupSshTunnel = "ssh_tunnel";
const String settingMetaGroupInitQuery = 'init_query';

const String settingMetaNameName = "name";
const String settingMetaNameUser = "user";
const String settingMetaNamePassword = "password";
const String settingMetaNameTargetDBFile = "tartget_db_file";
const String settingMetaNameTargetNetworkHost = "tartget_network_host";
const String settingMetaNameTargetNetworkPort = "tartget_network_port";
const String settingMetaNameSshTunnel = "ssh_tunnel";
const String settingMetaNameSshTunnelHost = "ssh_tunnel_host";
const String settingMetaNameSshTunnelPort = "ssh_tunnel_port";
const String settingMetaNameSshTunnelUser = "ssh_tunnel_user";
const String settingMetaNameSshTunnelAuthMethod = "ssh_tunnel_auth_method";
const String settingMetaNameSshTunnelPassword = "ssh_tunnel_password";
const String settingMetaNameSshTunnelPrivateKeyPath =
    "ssh_tunnel_private_key_path";
const String settingMetaNameSshTunnelPrivateKeyPassphrase =
    "ssh_tunnel_private_key_passphrase";
const String settingMetaNameDesc = "desc";

class ConnectionMeta {
  DatabaseType type;

  // 界面显示的名称
  String displayName;

  // 数据库描述，主要会被ai chat 使用，这里记录与数据库有关的特性, 例如语法。
  String? description;

  // todo: 这里反向依赖了flutter 主体的 asserts
  String logoAssertPath;

  List<SettingMeta> connMeta = [];

  List<String> initQuerys;

  ConnectionMeta({
    required this.connMeta,
    required this.type,
    this.logoAssertPath = "",
    required this.displayName,
    this.description,
    this.initQuerys = const [],
  });

  String initQueryText() {
    if (initQuerys.isEmpty) {
      return "";
    }
    return initQuerys.map((e) {
      e = e.trimRight();
      if (e.endsWith(";")) {
        return e;
      } else {
        return "$e;";
      }
    }).join("\n");
  }
}

sealed class SettingMeta {
  final String group;

  String get name;

  String? get defaultValue => "";

  SettingMeta({this.group = settingMetaGroupBase});
}

class NameMeta extends SettingMeta {
  @override
  String get name => settingMetaNameName;
}

enum SshTunnelAuthMethod {
  password,
  privateKey,
}

const String kSshTunnelAuthMethodPassword = "password";
const String kSshTunnelAuthMethodPrivateKey = "private_key";

String sshTunnelAuthMethodToValue(SshTunnelAuthMethod method) =>
    switch (method) {
      SshTunnelAuthMethod.privateKey => kSshTunnelAuthMethodPrivateKey,
      SshTunnelAuthMethod.password => kSshTunnelAuthMethodPassword,
    };

SshTunnelAuthMethod sshTunnelAuthMethodFromValue(String? value) =>
    value?.trim() == kSshTunnelAuthMethodPrivateKey
        ? SshTunnelAuthMethod.privateKey
        : SshTunnelAuthMethod.password;

SshTunnelAuthMethod resolveSshTunnelAuthMethod(SshTunnelConfig config) {
  if (config.privateKeyPath?.trim().isNotEmpty == true &&
      (config.password == null || config.password!.trim().isEmpty)) {
    return SshTunnelAuthMethod.privateKey;
  }
  return config.authMethod;
}

class TargetNetworkMeta extends SettingMeta {
  final String? defaultPort;

  TargetNetworkMeta({this.defaultPort, super.group});

  @override
  String get name => settingMetaNameTargetNetworkHost;
}

@Freezed(toStringOverride: false)
abstract class SshTunnelConfig with _$SshTunnelConfig {
  const SshTunnelConfig._();
  const factory SshTunnelConfig({
    @Default(false) bool enabled,
    required String host,
    required int port,
    required String user,
    @Default(SshTunnelAuthMethod.password) SshTunnelAuthMethod authMethod,
    String? password,
    String? privateKeyPath,
    String? privateKeyPassphrase,
  }) = _SshTunnelConfig;

  factory SshTunnelConfig.fromJson(Map<String, dynamic> json) =>
      _$SshTunnelConfigFromJson(json);

  @override
  String toString() => "$user@${host.trim()}:$port";
}

const SshTunnelConfig kDefaultSshTunnelTemplate = SshTunnelConfig(
  enabled: false,
  host: '',
  port: 22,
  user: '',
);

class SshTunnelMeta extends SettingMeta {
  final SshTunnelConfig? value;

  SshTunnelMeta({this.value, super.group});

  SshTunnelConfig get template => value ?? kDefaultSshTunnelTemplate;

  @override
  String get name => settingMetaNameSshTunnel;
}

class UserMeta extends SettingMeta {
  @override
  String get name => settingMetaNameUser;
}

class PasswordMeta extends SettingMeta {
  @override
  String get name => settingMetaNamePassword;
}

class TargetDBFileMeta extends SettingMeta {
  @override
  String get name => settingMetaNameTargetDBFile;
}

class DescMeta extends SettingMeta {
  @override
  String get name => settingMetaNameDesc;
}

enum SettingMetaType {
  text,
  enumValue,
}

class CustomMeta extends SettingMeta {
  @override
  String name;

  /// 参数类型
  SettingMetaType type;

  /// 是否必填
  bool isRequired = false;

  @override
  String? defaultValue;

  /// 参数枚举值, 例如: ["true", "false"]
  List<String>? enumValues;

  String? comment;

  CustomMeta({
    required this.name,
    required this.type,
    required super.group,
    this.defaultValue,
    this.enumValues,
    this.comment,
    this.isRequired = false,
  });
}

class ConnectValue {
  String name;
  ConnectTarget target;
  String user;
  String password;
  String desc;
  Map<String, String> custom = {};
  List<String> initQuerys;
  SshTunnelConfig? sshTunnel;

  ConnectValue({
    required this.name,
    required this.target,
    required this.user,
    required this.password,
    required this.desc,
    required this.custom,
    this.initQuerys = const [],
    this.sshTunnel,
  });

  SshTunnelConfig? getSshTunnel() => sshTunnel;

  String getHost() {
    return target.when(
      network: (host, port) => host.trim(),
      dbFile: (dbFile) => "",
    );
  }

  int? getPort() {
    return target.when(
      network: (host, port) => port,
      dbFile: (dbFile) => null,
    );
  }

  String getDbFile() {
    return target.when(
      dbFile: (dbFile) => dbFile.trim(),
      network: (host, port) => "",
    );
  }

  String getValue(String name, [String defaultValue = ""]) {
    return custom[name] ?? defaultValue;
  }

  int getIntValue(String name, [int defaultValue = 0]) {
    return int.tryParse(custom[name] ?? "") ?? defaultValue;
  }

  String initQueryText() {
    if (initQuerys.isEmpty) {
      return "";
    }
    return initQuerys.map((e) {
      e = e.trimRight();
      if (e.endsWith(";")) {
        return e;
      } else {
        return "$e;";
      }
    }).join("\n");
  }
}
