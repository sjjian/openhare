import 'package:client/models/session_conn.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/repo.dart';
import 'package:client/repositories/session_conn.dart';
import 'package:client/services/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_conn.g.dart';

@Riverpod(keepAlive: true)
class SessionConnsServices extends _$SessionConnsServices {
  @override
  int build() {
    return 0;
  }

  Future<void> createConn(int sessionId, int instanceId,
      {String? currentSchema}) async {
    final instance = objectbox2.getInstanceById(instanceId);
    ref
        .read(sessionConnRepoProvider)
        .createConn(sessionId, instance!, currentSchema: currentSchema);
  }

  Future<void> removeConn(int sessionId) async {
    ref.read(sessionConnRepoProvider).removeConn(sessionId);
  }
}

@Riverpod(keepAlive: true)
class SessionConnServices extends _$SessionConnServices {
  @override
  SessionConnModel build(int sessionId) {
    SessionConnModel conn =
        ref.watch(sessionConnRepoProvider).getSessionConn(sessionId);
    return conn;
  }

  Future<void> connect() async {
    await ref.read(sessionConnRepoProvider).connect(sessionId);
    ref.invalidateSelf();
  }

  Future<void> close() async {
    await ref.read(sessionConnRepoProvider).close(sessionId);
    ref.invalidateSelf();
  }

  Future<void> onSchemaChanged(String schema) async {
    await ref.read(sessionConnRepoProvider).onSchemaChanged(sessionId, schema);
    ref.invalidateSelf();
  }

  Future<void> setCurrentSchema(String schema) async {
    await ref.read(sessionConnRepoProvider).setCurrentSchema(sessionId, schema);
    ref.invalidateSelf();
  }

  Future<List<String>> getSchemas() async {
    return ref.read(sessionConnRepoProvider).getSchemas(sessionId);
  }

  Future<BaseQueryResult?> query(String query) async {
    return ref.read(sessionConnRepoProvider).query(sessionId, query);
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionConnController extends _$SelectedSessionConnController {
  @override
  SessionConnModel? build() {
    SessionModel? sessionIdModel = ref.watch(selectedSessionIdServicesProvider);
    if (sessionIdModel == null) {
      return null;
    }
    SessionConnModel model =
        ref.watch(sessionConnServicesProvider(sessionIdModel.sessionId));
    return model;
  }
}
