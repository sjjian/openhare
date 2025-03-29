// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instances.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstanceModel _$InstanceModelFromJson(Map<String, dynamic> json) =>
    InstanceModel(
      dbType: $enumDecode(_$DatabaseTypeEnumMap, json['db_type']),
      connectValue:
          ConnectValue.fromJson(json['connect_value'] as Map<String, dynamic>),
      activeSchemas: json['active_schemas'] == null
          ? null
          : ActiveNameSet.fromJson((json['active_schemas'] as List<dynamic>)
              .map((e) => e as String)
              .toList()),
    );

Map<String, dynamic> _$InstanceModelToJson(InstanceModel instance) =>
    <String, dynamic>{
      'db_type': _$DatabaseTypeEnumMap[instance.dbType]!,
      'connect_value': instance.connectValue,
      'active_schemas': instance.activeSchemas,
    };

const _$DatabaseTypeEnumMap = {
  DatabaseType.mysql: 'mysql',
  DatabaseType.pg: 'pg',
};

ActiveNameSet _$ActiveNameSetFromJson(Map<String, dynamic> json) =>
    ActiveNameSet(
      (json['data'] as List<dynamic>).map((e) => e as String).toList(),
    )..maxLength = (json['maxLength'] as num).toInt();

Map<String, dynamic> _$ActiveNameSetToJson(ActiveNameSet instance) =>
    <String, dynamic>{
      'data': instance.data.toList(),
      'maxLength': instance.maxLength,
    };
