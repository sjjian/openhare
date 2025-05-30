
import 'package:client/models/interface.dart';
import 'package:client/repositories/sessions.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:client/repositories/instances.dart';
import 'package:client/repositories/repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions.g.dart';

@Riverpod(keepAlive: true)
class SessionsServices extends _$SessionsServices {
  @override
  SessionTab build() {
    print("SessionsServices build");
    List<SessionStorage> sessions =
        ref.watch(sessionRepoProvider).getSessions();
    return SessionTab(sessions: ReorderSelectedList(data: sessions));
  }

  void selectSessionByIndex(int index) {
    if (state.sessions.select(index)) {
      // refresh
      ref.invalidateSelf();
      // state = state.copyWith(sessions: state.sessions);
    }
  }

  void reorderSession(int oldIndex, int newIndex) {
    state.sessions.reorder(oldIndex, newIndex);
    // refresh
    state = state.copyWith(sessions: state.sessions);
  }

  void addSession(InstanceModel instance, {String? schema}) {
    SessionRepo sessionRepo = ref.read(sessionRepoProvider);

    ObjectBox ob = ref.watch(objectboxProvider);
    // 记录使用的数据源
    ob.addActiveInstance(instance);
    if (schema != null) {
      ob.addInstanceActiveSchema(instance, schema);
    }

    SessionStorage? session = state.sessions.selected();
    if (session == null) {
      session = SessionStorage();
      state.sessions.add(session);
      sessionRepo.addSession(session);
    }
    session.instance.target = instance;
    session.currentSchema = schema;
    sessionRepo.updateSession(session);
    // refresh
    state = state.copyWith(sessions: state.sessions);
  }

  void newSession() {
    SessionRepo sessionRepo = ref.read(sessionRepoProvider);
    SessionStorage session = SessionStorage();
    state.sessions.add(session);
    sessionRepo.addSession(session);
    state = state.copyWith(sessions: state.sessions);
  }

  void deleteSessionByIndex(int index) {
    SessionRepo sessionRepo = ref.read(sessionRepoProvider);
    final session = state.sessions.removeAt(index);
    sessionRepo.deleteSession(session);
    // refresh
    state = state.copyWith(sessions: state.sessions);
  }
}