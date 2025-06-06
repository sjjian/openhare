import 'package:client/models/sessions.dart';
import 'package:client/repositories/sessions.dart';
import 'package:client/repositories/instances.dart';
import 'package:client/repositories/repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions.g.dart';

@Riverpod(keepAlive: true)
class SessionsServices extends _$SessionsServices {
  @override
  SessionListModel build() {
    print("SessionsServices build");
    SessionListModel sessions = ref.watch(sessionRepoProvider).getSessions();
    return sessions;
  }

  void selectSessionByIndex(int index) {
    ref.read(sessionRepoProvider).selectSessionByIndex(index);
    ref.invalidateSelf();
  }

  void reorderSession(int oldIndex, int newIndex) {
    // state.sessions.reorder(oldIndex, newIndex);
    ref.read(sessionRepoProvider).reorderSession(oldIndex, newIndex);
    ref.invalidateSelf();
    // refresh
    // state = state.copyWith(sessions: state.sessions);
  }

  Future<void> addSession(InstanceModel instance, {String? schema}) async {
    // SessionRepo sessionRepo = ref.read(sessionRepoProvider);
    SessionModel selectedSession;
    if (state.selectedSession == null) {
      selectedSession = await ref.read(sessionRepoProvider).newSession();
    } else {
      selectedSession = state.selectedSession!;
    }

    // todo: riverpod 改造
    ObjectBox ob = ref.watch(objectboxProvider);
    // 记录使用的数据源
    ob.addActiveInstance(instance);
    if (schema != null) {
      ob.addInstanceActiveSchema(instance, schema);
    }
    await ref
        .read(sessionRepoProvider)
        .updateSession(selectedSession, instance, schema ?? '');
    ref.invalidateSelf();
    // SessionStorage? session = state.sessions.selected();
    // if (session == null) {
    //   session = SessionStorage();
    //   state.sessions.add(session);
    //   sessionRepo.addSession(session);
    // }
    // session.instance.target = instance;
    // session.currentSchema = schema;
    // sessionRepo.updateSession(session);
    // refresh
    // state = state.copyWith(sessions: state.sessions);
  }

  Future<void> newSession() async {
    await ref.read(sessionRepoProvider).newSession();
    ref.invalidateSelf();
  }

  void deleteSessionByIndex(int index) {
    SessionRepo sessionRepo = ref.read(sessionRepoProvider);
    final session = state.sessions.removeAt(index);
    sessionRepo.deleteSession(session);
    // refresh
    state = state.copyWith(sessions: state.sessions);
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionIdServices extends _$SelectedSessionIdServices {
  @override
  SessionModel? build() {
    int sessionId = ref.watch(sessionsServicesProvider.select((s) {
      print("notify sessionTabControllerProvider");
      if (s.selectedSession == null || s.selectedSession!.instanceId == null) {
        return 0;
      }
      return s.selectedSession!.sessionId;
    }));
    print("SelectedSessionIdController1 build: $sessionId");
    if (sessionId == 0) {
      return null;
    }
    print("SelectedSessionIdController2 build: $sessionId");
    return ref.read(sessionRepoProvider).getSession(sessionId);
  }
}
