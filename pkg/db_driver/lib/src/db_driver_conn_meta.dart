import 'package:json_annotation/json_annotation.dart';

part 'db_driver_conn_meta.g.dart';

enum DatabaseType { mysql, pg }

class ConnectionMeta {
  String displayName;
  DatabaseType type;
  // todo: 这里反向依赖了flutter 主体的 asserts
  String logoAssertPath;

  List<SettingMeta> connMeta = [];

  ConnectionMeta(
      {required this.connMeta,
      required this.type,
      this.logoAssertPath = "",
      required this.displayName});
}

sealed class SettingMeta {
  String group;

  String get name;

  String? get defaultValue => "";

  SettingMeta({this.group = "base"});
}

class NameMeta extends SettingMeta {
  @override
  String get name => "name";
}

class AddressMeta extends SettingMeta {
  @override
  String get name => "addr";

  AddressMeta();
}

class PortMeta extends SettingMeta {
  @override
  String get name => "port";
  @override
  final String? defaultValue;

  PortMeta(this.defaultValue);
}

class UserMeta extends SettingMeta {
  @override
  String get name => "user";
}

class PasswordMeta extends SettingMeta {
  @override
  String get name => "password";
}

class DescMeta extends SettingMeta {
  @override
  String get name => "desc";
}

class CustomMeta extends SettingMeta {
  @override
  String name;
  
  String type;

  @override
  String? defaultValue;
  String? comment;
  bool isRequired = false;

  CustomMeta(
      {required this.name,
      required this.type,
      required super.group,
      this.defaultValue,
      this.comment,
      this.isRequired = false});
}

class SettingValue<SettingMeta, E> {
  SettingMeta meta;
  E value;

  SettingValue({required this.meta, required this.value});
}

@JsonSerializable()
class ConnectValue {
  String name;
  String host;
  int? port;
  String user;
  String password;
  String desc;
  Map<String, String> custom = {};

  ConnectValue(
      {required this.name,
      required this.host,
      this.port,
      required this.user,
      required this.password,
      required this.desc,
      required this.custom});

  String getValue(String name, [String defaultValue = ""]) {
    return custom[name] ?? defaultValue;
  }

  factory ConnectValue.fromJson(Map<String, dynamic> json) =>
      _$ConnectValueFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectValueToJson(this);
}
