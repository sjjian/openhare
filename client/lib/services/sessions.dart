import 'package:client/models/instances.dart';
import 'package:client/models/session_conn.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/sessions.dart';
import 'package:client/services/instances/instances.dart';
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

    ref.read(instancesServicesProvider.notifier).addActiveInstance(instance, schema: schema);
    
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
    await ref.read(sessionRepoProvider).deleteSession(state.sessions[index].sessionId);
    ref.invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionIdServices extends _$SelectedSessionIdServices {
  @override
  SessionModel? build() {
    SessionModel? session = ref.watch(sessionsServicesProvider.select((s) {
      if (s.selectedSession == null || s.selectedSession!.instanceId == null) {
        return null;
      }
      return s.selectedSession;
    }));
    if (session == null) {
      return null;
    }
    return session;
  }
}
