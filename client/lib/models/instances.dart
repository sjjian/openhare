import 'package:client/utils/active_set.dart';
import 'package:json_annotation/json_annotation.dart';

part 'instances.g.dart';

@JsonSerializable()
class InstanceModel {
  String name;
  String? desc;
  String addr;
  int port;
  String user;
  String password;
  @JsonKey(name: "active_schemas")
  ActiveNameSet activeSchemas;

  InstanceModel({
    required this.name,
    this.desc,
    required this.addr,
    required this.port,
    required this.user,
    required this.password,
    ActiveNameSet? activeSchemas,
  }) : activeSchemas = activeSchemas ?? ActiveNameSet.empty();

  factory InstanceModel.fromJson(Map<String, dynamic> json) =>
      _$InstanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$InstanceModelToJson(this);
}

class ActiveNameSet extends ActiveSet<String> {
  ActiveNameSet(List<String> data) : super(data);

  ActiveNameSet.empty() : super(List.empty());

  factory ActiveNameSet.fromJson(List<String> data) => ActiveNameSet(data);

  List<String> toJson() => toList();
}
