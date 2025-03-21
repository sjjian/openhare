import 'package:client/utils/active_set.dart';
import 'package:json_annotation/json_annotation.dart';

part 'instances.g.dart';

@JsonSerializable()
class InstanceModel {
  String type = "mysql";
  String name;
  String? desc;
  String addr;
  int port;
  String user;
  String password;
  String? databases;
  @JsonKey(name: "active_schemas")
  ActiveNameSet activeSchemas;

  InstanceModel({
    this.type = "mysql",
    required this.name,
    this.desc,
    required this.addr,
    required this.port,
    required this.user,
    required this.password,
    this.databases,
    ActiveNameSet? activeSchemas,
  }) : activeSchemas = activeSchemas ?? ActiveNameSet.empty();

  factory InstanceModel.fromJson(Map<String, dynamic> json) =>
      _$InstanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$InstanceModelToJson(this);
}

@JsonSerializable()
class ActiveNameSet extends ActiveSet<String> {
  ActiveNameSet(List<String> data) : super(data);

  ActiveNameSet.empty() : super(List.empty());

  factory ActiveNameSet.fromJson(List<String> data) => ActiveNameSet(data);

  List<String> toJson() => toList();
}
