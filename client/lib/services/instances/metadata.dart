import 'package:client/models/instances.dart';
import 'package:client/repositories/instances/metadata.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'metadata.g.dart';

@Riverpod()
class InstanceMetadataServices extends _$InstanceMetadataServices {
  @override
  InstanceMetadataModel build(InstanceId instanceId) {
    return ref.watch(instanceMetadataRepoProvider).getMetadata(instanceId);
  }

  // todo: 需要对conn 判空
  Future<void> refreshMetadata() async {
    final connModel = await ref.read(sessionConnsServicesProvider.notifier).createConn(instanceId);
    await ref.read(sessionConnServicesProvider(connModel.connId).notifier).connect();
    final metadata = await ref.read(sessionConnServicesProvider(connModel.connId).notifier).getMetadata();
    ref.read(instanceMetadataRepoProvider).updateMetadata(state.instanceId, metadata);
    await ref.read(sessionConnServicesProvider(connModel.connId).notifier).close();
    await ref.read(sessionConnsServicesProvider.notifier).removeConn(connModel.connId);
    ref.invalidateSelf();
  }
}
