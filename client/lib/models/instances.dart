import 'package:client/utils/active_set.dart';
import 'package:db_driver/db_driver.dart';
import 'package:objectbox/objectbox.dart';
import 'dart:convert';

@Entity()
class InstanceModel {
  @Id()
  int id;

  @Transient()
  DatabaseType dbType;

  int get stDbType => dbType.index;

  set stDbType(int value) {
    dbType = DatabaseType.values[value];
  }

  String name;
  String host;
  int? port;
  String user;
  String password;
  String desc;

  @Transient()
  Map<String, String> custom = {};

  String get stCustom => jsonEncode(custom);

  set stCustom(String value) {
    custom = jsonDecode(value).map((key, value) => MapEntry(key, value.toString()));
  }

  List<String> initQuerys;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime? latestOpenAt;

  @Transient()
  ConnectValue get connectValue => ConnectValue(
      name: name,
      host: host,
      port: port,
      user: user,
      password: password,
      desc: desc,
      custom: custom,
      initQuerys: initQuerys);

  @Transient()
  ActiveSet<String> activeSchemas;
  List<String> get stActiveSchemas => activeSchemas.toList();

  set stActiveSchemas(List<String> value) {
    activeSchemas = ActiveSet<String>(value);
  }

  InstanceModel({
    this.id = 0,
    required int stDbType,
    required this.name,
    required this.host,
    this.port,
    required this.user,
    required this.password,
    required this.desc,
    required String stCustom,
    required this.initQuerys,
    ActiveSet<String>? activeSchemas,
    DateTime? createdAt,
    DateTime? latestOpenAt,
  })  : activeSchemas = activeSchemas ?? ActiveSet<String>(List.empty()),
        dbType = DatabaseType.values[stDbType],
        // custom = jsonDecode(stCustom),
        createdAt = createdAt ?? DateTime.now();

  InstanceModel.one({
    this.id = 0,
    required this.dbType,
    required ConnectValue connectValue,
    ActiveSet<String>? activeSchemas,
  })  : name = connectValue.name,
        host = connectValue.host,
        port = connectValue.port,
        user = connectValue.user,
        password = connectValue.password,
        desc = connectValue.desc,
        custom = connectValue.custom,
        initQuerys = connectValue.initQuerys,
        activeSchemas = activeSchemas ?? ActiveSet<String>(List.empty()),
        createdAt = DateTime.now();
}
