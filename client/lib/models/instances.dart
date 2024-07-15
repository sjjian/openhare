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

  InstanceModel(
      {required this.name,
      this.desc,
      required this.addr,
      required this.port,
      required this.user,
      required this.password});

  factory InstanceModel.fromJson(Map<String, dynamic> json) =>
      _$InstanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$InstanceModelToJson(this);
}

final instances = List<InstanceModel>.empty(growable: true);
