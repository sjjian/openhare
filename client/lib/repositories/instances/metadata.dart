import 'package:client/models/instances.dart';
import 'package:client/utils/state_value.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'metadata.g.dart';

class InstanceMetadataRepoImpl implements InstanceMetadataRepo {
  Map<InstanceId, InstanceMetadataModel> models = {};

  @override
  InstanceMetadataModel? getMetadata(InstanceId instanceId) {
    return models[instanceId];
  }

  @override
  void updateMetadata(
      InstanceId instanceId, StateValue<List<MetaDataNode>> metadata) {
    models[instanceId] =
        InstanceMetadataModel(instanceId: instanceId, metadata: metadata);
  }
}

@Riverpod(keepAlive: true)
InstanceMetadataRepo instanceMetadataRepo(Ref ref) {
  return InstanceMetadataRepoImpl();
}
