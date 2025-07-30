import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/instances/instances.dart';
import 'package:client/repositories/sessions/session_conn.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_conn.g.dart';

@Riverpod(keepAlive: true)
class SessionConnsServices extends _$SessionConnsServices {
  @override
  SessionConnListModel build() {
    return ref.read(sessionConnRepoProvider).getConns();
  }

  SessionConnModel? getConn(ConnId connId) {
    return ref.read(sessionConnRepoProvider).getConn(connId);
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

  Future<void> connect(ConnId connId, {
    Function(String)? onSchemaChangedCallback,
  }) async {
    await ref.read(sessionConnRepoProvider).connect(
      connId,
      onStateChangedCallback: () {
        ref.invalidateSelf(); // todo: 订阅不了，因为rebuild了
      },
      onSchemaChangedCallback: onSchemaChangedCallback,
    );
    ref.invalidateSelf();
  }

  Future<void> close(ConnId connId) async {
    await ref.read(sessionConnRepoProvider).close(connId);
    ref.invalidateSelf();
  }

  Future<void> setCurrentSchema(ConnId connId, String schema) async {
    await ref.read(sessionConnRepoProvider).setCurrentSchema(connId, schema);
    ref.invalidateSelf();
  }

  Future<List<String>> getSchemas(ConnId connId) async {
    return ref.read(sessionConnRepoProvider).getSchemas(connId);
  }

  Future<MetaDataNode> getMetadata(ConnId connId) async {
    return ref.read(sessionConnRepoProvider).getMetadata(connId);
  }

  Future<BaseQueryResult?> query(ConnId connId, String query) async {
    return ref.read(sessionConnRepoProvider).query(connId, query);
  }

  Future<void> killQuery(ConnId connId) async {
    await ref.read(sessionConnRepoProvider).killQuery(connId);
  }
}

@Riverpod()
class SessionConnServices extends _$SessionConnServices {
  @override
  SessionConnModel? build(ConnId connId) {
    if (connId.value == 0) {
      return null;
    }
    return ref.watch(sessionConnsServicesProvider.select((s) {
      return s.conns[connId];
    }));
  }
}
