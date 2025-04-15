import 'package:json_annotation/json_annotation.dart';

part 'db_driver_conn_meta.g.dart';

enum DatabaseType { mysql, pg }

const String settingMetaGroupBase = "base";

const String settingMetaNameName = "name";
const String settingMetaNameAddr = "addr";
const String settingMetaNamePort = "port";
const String settingMetaNameUser = "user";
const String settingMetaNamePassword = "password";
const String settingMetaNameDesc = "desc";

class ConnectionMeta {
  String displayName;
  DatabaseType type;
  // todo: 这里反向依赖了flutter 主体的 asserts
  String logoAssertPath;

  List<SettingMeta> connMeta = [];

  List<String> initQuerys;

  ConnectionMeta(
      {required this.connMeta,
      required this.type,
      this.logoAssertPath = "",
      required this.displayName,
      this.initQuerys = const []});

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

class AddressMeta extends SettingMeta {
  @override
  String get name => settingMetaNameAddr;

  AddressMeta();
}

class PortMeta extends SettingMeta {
  @override
  String get name => settingMetaNamePort;
  @override
  final String? defaultValue;

  PortMeta(this.defaultValue);
}

class UserMeta extends SettingMeta {
  @override
  String get name => settingMetaNameUser;
}

class PasswordMeta extends SettingMeta {
  @override
  String get name => settingMetaNamePassword;
}

class DescMeta extends SettingMeta {
  @override
  String get name => settingMetaNameDesc;
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
  List<String> initQuerys;

  ConnectValue(
      {required this.name,
      required this.host,
      this.port,
      required this.user,
      required this.password,
      required this.desc,
      required this.custom,
      this.initQuerys = const []});

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

  factory ConnectValue.fromJson(Map<String, dynamic> json) =>
      _$ConnectValueFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectValueToJson(this);
}
