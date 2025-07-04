import 'package:client/models/instances.dart';
import 'package:client/models/session_conn.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/session_sql_result.dart';
import 'package:client/repositories/sessions.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/services/session_conn.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions.g.dart';

@Riverpod(keepAlive: true)
class SessionsServices extends _$SessionsServices {
  @override
  SessionListModel build() {
    SessionListModel sessions = ref.watch(sessionRepoProvider).getSessions();
    return sessions;
  }

  SessionModel? getSession(SessionId sessionId){
    return ref.read(sessionRepoProvider).getSession(sessionId);
  }

  void selectSessionByIndex(int index) {
    ref.read(sessionRepoProvider).selectSessionByIndex(index);
    ref.invalidateSelf();
  }

  void reorderSession(int oldIndex, int newIndex) {
    ref.read(sessionRepoProvider).reorderSession(oldIndex, newIndex);
    ref.invalidateSelf();
  }

  Future<void> addSession(InstanceModel instance, {String? schema}) async {
    SessionModel selectedSession;
    if (state.selectedSession == null) {
      selectedSession = await ref.read(sessionRepoProvider).newSession();
    } else {
      selectedSession = state.selectedSession!;
    }

    ref.read(instancesServicesProvider.notifier).addActiveInstance(instance.id, schema: schema);
    
    await ref
        .read(sessionRepoProvider)
        .updateSession(selectedSession.sessionId, instance, schema ?? '');
    ref.invalidateSelf();
  }

  void setConnId(SessionId sessionId, ConnId connid) {
    ref.read(sessionRepoProvider).setConnId(sessionId, connid);
    ref.invalidateSelf();
  }

  Future<void> newSession() async {
    await ref.read(sessionRepoProvider).newSession();
    ref.invalidateSelf();
  }

  Future<void> deleteSessionByIndex(int index) async {
    // 1. delete session
    await ref.read(sessionRepoProvider).deleteSession(state.sessions[index].sessionId);
    // 2. close conn
    final session = state.sessions[index];
    if (session.connId != null) {
      await ref.read(sessionConnServicesProvider(session.connId!).notifier).close();
      await ref.read(sessionConnsServicesProvider.notifier).removeConn(session.connId!);
    }
    // 3. delete result
    ref.read(sqlResultsRepoProvider).deleteSQLResults(session.sessionId);

    ref.invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionIdServices extends _$SelectedSessionIdServices {
  @override
  SessionModel? build() {
    return ref.watch(sessionsServicesProvider.select((s) {
      return s.selectedSession;
    }));
  }
}
