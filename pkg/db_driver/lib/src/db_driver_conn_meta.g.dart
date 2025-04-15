// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_driver_conn_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectValue _$ConnectValueFromJson(Map<String, dynamic> json) => ConnectValue(
      name: json['name'] as String,
      host: json['host'] as String,
      port: (json['port'] as num?)?.toInt(),
      user: json['user'] as String,
      password: json['password'] as String,
      desc: json['desc'] as String,
      custom: Map<String, String>.from(json['custom'] as Map),
      initQuerys: (json['initQuerys'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ConnectValueToJson(ConnectValue instance) =>
    <String, dynamic>{
      'name': instance.name,
      'host': instance.host,
      'port': instance.port,
      'user': instance.user,
      'password': instance.password,
      'desc': instance.desc,
      'custom': instance.custom,
      'initQuerys': instance.initQuerys,
    };
