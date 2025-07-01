import 'package:client/models/instances.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:db_driver/db_driver.dart';

part 'instance_metadata.freezed.dart';

@freezed
abstract class InstanceMetadataModel with _$InstanceMetadataModel {
  const factory InstanceMetadataModel({
    required InstanceId instanceId,
    MetaDataNode? metadata,
  }) = _InstanceMetadataModel;
}

abstract class InstanceMetadataRepo {
  InstanceMetadataModel getMetadata(InstanceId instanceId);
  void updateMetadata(InstanceId instanceId, MetaDataNode metadata);
  void addMetadata(InstanceId instanceId, MetaDataNode metadata);
}
