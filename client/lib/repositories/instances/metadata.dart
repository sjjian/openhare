import 'package:client/models/instance_metadata.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'metadata.g.dart';

class InstanceMetadataRepoImpl implements InstanceMetadataRepo {
  Map<int, MetaDataNode> metadata = {};

  @override
  InstanceMetadataModel getMetadata(int instanceId) {
    return InstanceMetadataModel(
        instanceId: instanceId, metadata: metadata[instanceId]);
  }

  @override
  void updateMetadata(int instanceId, MetaDataNode metadata) {
    this.metadata[instanceId] = metadata;
  }

  @override
  void addMetadata(int instanceId, MetaDataNode metadata) {
    this.metadata[instanceId] = metadata;
  }
}

@Riverpod(keepAlive: true)
InstanceMetadataRepo instanceMetadataRepo(Ref ref) {
  return InstanceMetadataRepoImpl();
}
