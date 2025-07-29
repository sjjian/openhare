import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
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
    final connServices = ref.read(sessionConnsServicesProvider.notifier);
    SessionConnModel? connModel;
    try {
      connModel = await connServices.createConn(instanceId);
      await connServices.connect(connModel.connId);
      final metadata = await connServices.getMetadata(connModel.connId);
      ref
          .read(instanceMetadataRepoProvider)
          .updateMetadata(state.instanceId, metadata);
    } catch (e) {
      rethrow;
    } finally {
      if (connModel != null) {
        await connServices.close(connModel.connId);
        await connServices.removeConn(connModel.connId);
      }
      ref.invalidateSelf();
    }
  }
}
