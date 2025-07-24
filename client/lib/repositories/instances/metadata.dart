import 'package:client/models/instances.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'metadata.g.dart';

class InstanceMetadataRepoImpl implements InstanceMetadataRepo {
  Map<InstanceId, MetaDataNode> metadata = {};

  @override
  InstanceMetadataModel getMetadata(InstanceId instanceId) {
    return InstanceMetadataModel(
        instanceId: instanceId, metadata: metadata[instanceId]);
  }

  @override
  void updateMetadata(InstanceId instanceId, MetaDataNode metadata) {
    this.metadata[instanceId] = metadata;
  }

  @override
  void addMetadata(InstanceId instanceId, MetaDataNode metadata) {
    this.metadata[instanceId] = metadata;
  }
}

@Riverpod(keepAlive: true)
InstanceMetadataRepo instanceMetadataRepo(Ref ref) {
  return InstanceMetadataRepoImpl();
}
