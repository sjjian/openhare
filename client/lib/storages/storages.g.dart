// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Storage _$StorageFromJson(Map<String, dynamic> json) => Storage._internal(
      instances: (json['instances'] as List<dynamic>?)
          ?.map((e) => InstanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeInstances: json['active_instances'] == null
          ? null
          : ActiveNameSet.fromJson((json['active_instances'] as List<dynamic>)
              .map((e) => e as String)
              .toList()),
    );

Map<String, dynamic> _$StorageToJson(Storage instance) => <String, dynamic>{
      'instances': instance.instances,
      'active_instances': instance.activeInstances,
    };
