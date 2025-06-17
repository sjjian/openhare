import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:db_driver/db_driver.dart';

part 'instance_metadata.freezed.dart';

@freezed
abstract class InstanceMetadataModel with _$InstanceMetadataModel {
  const factory InstanceMetadataModel({
    required int instanceId,
    MetaDataNode? metadata,
    // TreeController<DataNode>? metadataController,
  }) = _InstanceMetadataModel;
}

abstract class InstanceMetadataRepo {
  InstanceMetadataModel getMetadata(int instanceId);
  void updateMetadata(int instanceId, MetaDataNode metadata);
  void addMetadata(int instanceId, MetaDataNode metadata);
}
