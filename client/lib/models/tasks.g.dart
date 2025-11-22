// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExportDataParameters _$ExportDataParametersFromJson(
        Map<String, dynamic> json) =>
    _ExportDataParameters(
      instanceId:
          InstanceId.fromJson(json['instanceId'] as Map<String, dynamic>),
      schema: json['schema'] as String,
      query: json['query'] as String,
      fileDir: json['fileDir'] as String,
      fileName: json['fileName'] as String,
    );

Map<String, dynamic> _$ExportDataParametersToJson(
        _ExportDataParameters instance) =>
    <String, dynamic>{
      'instanceId': instance.instanceId,
      'schema': instance.schema,
      'query': instance.query,
      'fileDir': instance.fileDir,
      'fileName': instance.fileName,
    };
