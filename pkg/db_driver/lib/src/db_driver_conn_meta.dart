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
  SettingMeta({this.group = "base"});
}

class NameMeta extends SettingMeta {}

class AddressMeta extends SettingMeta {}

class UserMeta extends SettingMeta {}

class PasswordMeta extends SettingMeta {}

class DescMeta extends SettingMeta {}

class CustomMeta extends SettingMeta {
  String name;
  String type;
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
  int port;
  String user;
  String password;
  String desc;
  Map<String, String> custom = {};

  ConnectValue(
      {required this.name,
      required this.host,
      required this.port,
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
