enum DatabaseType { mysql, pg }

class ConnectionMeta {
  String displayName;
  DatabaseType type;
  // todo: 这里反向依赖了flutter 主体的 asserts
  String logoAssertPath;

  List<SettingMeta> connMeta = [];

  ConnectionMeta(
      {required this.connMeta, required this.type, this.logoAssertPath = "", required this.displayName});
}

sealed class SettingMeta {}

class CustomMeta extends SettingMeta {
  String name;
  String group;
  String type;
  String? defaultValue;
  String? comment;
  bool isRequired = false;

  CustomMeta(
      {required this.name,
      required this.type,
      required this.group,
      this.defaultValue,
      this.comment,
      this.isRequired = false});
}

class NameMeta extends SettingMeta {}

class AddressMeta extends SettingMeta {}

class UserMeta extends SettingMeta {}

class PasswordMeta extends SettingMeta {}

class DescMeta extends SettingMeta {}
