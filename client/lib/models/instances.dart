import 'package:client/utils/active_set.dart';
import 'package:db_driver/db_driver.dart';
import 'package:json_annotation/json_annotation.dart';

part 'instances.g.dart';

@JsonSerializable()
class InstanceModel {
  @JsonKey(name: 'db_type')
  DatabaseType dbType;

  @JsonKey(name: 'connect_value')
  ConnectValue connectValue;

  @JsonKey(name: "active_schemas")
  ActiveNameSet activeSchemas;

  InstanceModel({
    required this.dbType,
    required this.connectValue,
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
