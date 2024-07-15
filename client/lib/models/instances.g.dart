// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instances.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstanceModel _$InstanceModelFromJson(Map<String, dynamic> json) =>
    InstanceModel(
      name: json['name'] as String,
      desc: json['desc'] as String?,
      addr: json['addr'] as String,
      port: (json['port'] as num).toInt(),
      user: json['user'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$InstanceModelToJson(InstanceModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'desc': instance.desc,
      'addr': instance.addr,
      'port': instance.port,
      'user': instance.user,
      'password': instance.password,
    };
