import 'package:client/models/instances.dart';
import 'package:client/models/session_conn.dart';
import 'package:client/repositories/instances/instances.dart';
import 'package:client/repositories/session_conn.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_conn.g.dart';

@Riverpod(keepAlive: true)
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
  SessionConnModel build(ConnId connId) {
    SessionConnModel conn =
        ref.watch(sessionConnRepoProvider).getConn(connId);
    return conn;
  }

  Future<void> connect() async {
    await ref.read(sessionConnRepoProvider).connect(connId);
    ref.invalidateSelf();
  }

  Future<void> close() async {
    await ref.read(sessionConnRepoProvider).close(connId);
    ref.invalidateSelf();
  }

  Future<void> onSchemaChanged(String schema) async {
    await ref
        .read(sessionConnRepoProvider)
        .onSchemaChanged(connId, schema);
    ref.invalidateSelf();
  }

  Future<void> setCurrentSchema(String schema) async {
    await ref
        .read(sessionConnRepoProvider)
        .setCurrentSchema(connId, schema);
    ref.invalidateSelf();
  }

  Future<List<String>> getSchemas() async {
    return ref.read(sessionConnRepoProvider).getSchemas(connId);
  }

  Future<MetaDataNode> getMetadata() async {
    return ref.read(sessionConnRepoProvider).getMetadata(connId);
  }

  Future<BaseQueryResult?> query(String query) async {
    return ref
        .read(sessionConnRepoProvider)
        .query(connId, query);
  }
}