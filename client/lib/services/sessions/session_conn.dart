import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/instances/instances.dart';
import 'package:client/repositories/sessions/session_conn.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_conn.g.dart';

@Riverpod()
class SessionConnsServices extends _$SessionConnsServices {
  @override
  int build() {
    return 0;
  }

  Future<SessionConnModel> createConn(InstanceId instanceId,
      {String? currentSchema}) async {
    final instance = ref.read(instanceRepoProvider).getInstanceById(instanceId);
    return ref
        .read(sessionConnRepoProvider)
        .createConn(instance!, currentSchema: currentSchema);
  }

  Future<void> removeConn(ConnId connId) async {
    ref.read(sessionConnRepoProvider).removeConn(connId);
  }
}

@Riverpod(keepAlive: true)
class SessionConnServices extends _$SessionConnServices {
  @override
  SessionConnModel? build(ConnId connId) {
    if (connId.value == 0) {
      return null;
    }
    final model = ref.watch(sessionConnRepoProvider).getConn(connId);
    return model;
  }

  Future<void> connect({
    Function(String)? onSchemaChangedCallback,
  }) async {
    await ref.read(sessionConnRepoProvider).connect(
      connId,
      onStateChangedCallback: () {
        ref.invalidateSelf();
      },
      onSchemaChangedCallback: onSchemaChangedCallback,
    );
    ref.invalidateSelf();
  }

  Future<void> close() async {
    await ref.read(sessionConnRepoProvider).close(connId);
    ref.invalidateSelf();
  }

  Future<void> setCurrentSchema(String schema) async {
    await ref.read(sessionConnRepoProvider).setCurrentSchema(connId, schema);
    ref.invalidateSelf();
  }

  Future<List<String>> getSchemas() async {
    return ref.read(sessionConnRepoProvider).getSchemas(connId);
  }

  Future<MetaDataNode> getMetadata() async {
    return ref.read(sessionConnRepoProvider).getMetadata(connId);
  }

  Future<BaseQueryResult?> query(String query) async {
    return ref.read(sessionConnRepoProvider).query(connId, query);
  }
}
