import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/instances/instances.dart';
import 'package:client/repositories/instances/session_conn.dart';
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

  Future<SessionConnModel> createConn(InstanceId instanceId, {DatabaseRef? currentSchema}) async {
    final instance = ref.read(instanceRepoProvider).getInstanceById(instanceId);
    return ref.read(sessionConnRepoProvider).createConn(instance!, currentSchema: currentSchema);
  }

  Future<void> removeConn(ConnId connId) async {
    ref.read(sessionConnRepoProvider).removeConn(connId);
  }

  Future<void> connect(
    ConnId connId, {
    Function(DatabaseRef)? onSchemaChangedCallback,
  }) async {
    await ref
        .read(sessionConnRepoProvider)
        .connect(
          connId,
          onStateChangedCallback: () {
            ref.invalidateSelf();
          },
          onSchemaChangedCallback: onSchemaChangedCallback,
        );
    ref.invalidateSelf();
  }

  Future<void> close(ConnId connId) async {
    await ref.read(sessionConnRepoProvider).close(connId);
    ref.invalidateSelf();
  }

  Future<void> setCurrentSchema(ConnId connId, DatabaseRef schema) async {
    await ref.read(sessionConnRepoProvider).setCurrentSchema(connId, schema);
    ref.invalidateSelf();
  }

  Future<BaseQueryResult?> query(ConnId connId, String query, {int? limit}) async {
    return ref.read(sessionConnRepoProvider).query(connId, query, limit: limit);
  }

  Stream<BaseQueryStreamItem> queryStream(ConnId connId, String query) {
    return ref.read(sessionConnRepoProvider).queryStream(connId, query);
  }

  Future<void> killQuery(ConnId connId) async {
    await ref.read(sessionConnRepoProvider).killQuery(connId);
  }

  bool supportsKillQuery(ConnId connId) {
    return ref.read(sessionConnRepoProvider).supportsKillQuery(connId);
  }
}
