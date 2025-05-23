import 'package:client/models/interface.dart';
import 'package:client/repositories/sessions.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/instances.dart';
import 'package:client/repositories/repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions.g.dart';

@Riverpod(keepAlive: true)
class SessionDrawerController extends _$SessionDrawerController {
  @override
  CurrentSessionDrawer build() {
    SelectedSessionId sessionIdModel = ref.watch(selectedSessionIdControllerProvider)!;
    return ref.watch(sessionDrawerStateProvider(sessionIdModel.sessionId));
  }

  Future<void> loadMetadata() async {
    // CurrentSessionDrawer? session = ref.read(currentSessionDrawerProvider);
    // if (session == null || session is UnInitSession) {
    //   return;
    // }
    // if ((session as Session).metadata != null) {
    //   return;
    // }

    // if (session.connState != SQLConnectState.connected) {
    //   return;
    // }
    // session.metadata = await session.conn2!.metadata();
    // ref.invalidate(currentSessionDrawerProvider);
    return;
  }

  void showRightPage() {
    state = state.copyWith(isRightPageOpen: true);
  }

  void hideRightPage() {
    state = state.copyWith(isRightPageOpen: false);
  }

  void showSQLResult({BaseQueryValue? result, BaseQueryColumn? column}) {
    state = state.copyWith(
      drawerPage: DrawerPage.sqlResult,
      sqlColumn: column ?? state.sqlColumn,
      sqlResult: result ?? state.sqlResult,
    );
  }

  void goToTree() {
    state = state.copyWith(
      drawerPage: DrawerPage.metadataTree,
      sqlColumn: null,
      sqlResult: null,
    );
  }
}

@Riverpod(keepAlive: true)
class SessionSplitViewController extends _$SessionSplitViewController {
  @override
  CurrentSessionSplitView build() {
    SelectedSessionId sessionIdModel = ref.watch(selectedSessionIdControllerProvider)!;
    return ref.watch(sessionSplitViewStateProvider(sessionIdModel.sessionId));
  }
}

@Riverpod(keepAlive: true)
class SessionMetadataController extends _$SessionMetadataController {
  @override
  CurrentSessionMetadata build() {
    SelectedSessionId sessionIdModel = ref.watch(selectedSessionIdControllerProvider)!;
    return ref.watch(sessionMetadataStateProvider(sessionIdModel.sessionId));
  }
}

@Riverpod(keepAlive: true)
class SessionEditorController extends _$SessionEditorController {
  @override
  CurrentSessionEditor build() {
    SelectedSessionId sessionIdModel = ref.watch(selectedSessionIdControllerProvider)!;
    return ref.watch(sessionEditorProvider(sessionIdModel.sessionId));
  }
}

@riverpod
class SessionTabController extends _$SessionTabController {
  @override
  SessionTab build() {
    List<SessionStorage> sessions =
        ref.watch(sessionRepoProvider).getSessions();
    return SessionTab(sessions: ReorderSelectedList(data: sessions));
  }

  void selectSessionByIndex(int index) {
    if (state.sessions.select(index)) {
      // refresh
      state = state.copyWith(sessions: state.sessions);
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


    // ref.invalidate(sessionsRepoProvider);
    // ref.invalidateSelf();
    // ref.invalidate(sessionRepoProvider);
    // print("addSession refresh");
    // connect(session);
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

@Riverpod(keepAlive: true)
class SelectedSessionIdController extends _$SelectedSessionIdController {
  @override
  SelectedSessionId build() {
    int sessionId =
        ref.watch(sessionTabControllerProvider.select((s){
          if (s.sessions.selected() == null || s.sessions.selected()!.instance.target == null) {
            return 0;
          }
          return s.sessions.selected()!.id;
        }));
    if (sessionId == 0) {
      return const SelectedSessionId(sessionId: 0, instanceId: 0);
    }
    SessionStorage session = ref.read(sessionRepoProvider).getSession(sessionId)!; 
    return SelectedSessionId(sessionId: sessionId, instanceId: session.instance.target?.id);
  }
}