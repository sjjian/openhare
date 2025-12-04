import 'package:client/models/ai.dart';
import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/sessions/session_sql_result.dart';
import 'package:client/repositories/sessions/sessions.dart';
import 'package:client/services/ai/chat.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/services/sessions/session_drawer.dart';
import 'package:client/services/sessions/session_metadata_tree.dart';
import 'package:client/services/sessions/session_sql_editor.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/sessions/session_controller.dart';
import 'package:client/services/tasks/overview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions.g.dart';

@Riverpod(keepAlive: true)
class SessionsServices extends _$SessionsServices {
  @override
  SessionListModel build() {
    SessionListModel sessions = ref.watch(sessionRepoProvider).getSessions();
    return sessions;
  }

  SessionModel? getSession(SessionId sessionId) {
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
    SessionId selectedSessionId;
    if (state.selectedSession == null) {
      selectedSessionId = await ref.read(sessionRepoProvider).newSession();
    } else {
      selectedSessionId = state.selectedSession!.sessionId;
    }

    await ref
        .read(instancesServicesProvider.notifier)
        .addActiveInstance(instance.id, schema: schema);

    await ref.read(sessionRepoProvider).updateSession(selectedSessionId,
        instance: instance, currentSchema: schema);

    ref.invalidateSelf();

    // auto connect when new session.
    connectSession(selectedSessionId);
  }

  Future<void> newSession() async {
    await ref.read(sessionRepoProvider).newSession();
    ref.invalidateSelf();
  }

  Future<void> deleteSessionByIndex(int index) async {
    SessionModel session = state.sessions[index];

    // 1. delete session
    await ref.read(sessionRepoProvider).deleteSession(session.sessionId);
    ref.invalidateSelf();

    // 2. kill and close conn
    if (session.connId != null) {
      final connsServices = ref.read(sessionConnsServicesProvider.notifier);
      await connsServices.killQuery(session.connId!);
      await connsServices.close(session.connId!);
      await connsServices.removeConn(session.connId!);
    }

    // 3. delete result
    ref.read(sqlResultsRepoProvider).deleteSQLResults(session.sessionId);

    // 4. delete ai chat
    ref
        .read(aIChatServiceProvider.notifier)
        .delete(AIChatId(value: session.sessionId.value));

    // 5. delete provider status
    ref.invalidate(sessionSQLEditorServiceProvider(session.sessionId));
    ref.invalidate(sessionDrawerServicesProvider(session.sessionId));
    ref.invalidate(sessionMetadataServicesProvider(session.sessionId));
    SessionController.removeSessionController(session.sessionId);
  }

  Future<void> connectSession(SessionId sessionId) async {
    final session = ref.read(sessionRepoProvider).getSession(sessionId);
    if (session == null) {
      return;
    }
    final connsServices = ref.read(sessionConnsServicesProvider.notifier);
    var connId = session.connId;
    if (connId == null) {
      // create conn
      final connModel = await connsServices.createConn(
        session.instanceId!,
        currentSchema: session.currentSchema,
      );
      // 关联 session 和 conn
      final repo = ref.read(sessionRepoProvider);
      repo.setConnId(session.sessionId, connModel.connId);
      connId = connModel.connId;
      ref.invalidateSelf();
    }

    // connect conn
    await connsServices.connect(connId,
        onSchemaChangedCallback: (schema) async {
      await ref
          .read(sessionRepoProvider)
          .updateSession(sessionId, currentSchema: schema);

      await ref
          .read(instancesServicesProvider.notifier)
          .addActiveInstance(session.instanceId!, schema: schema);

      ref.invalidateSelf();
    });

    ref.invalidateSelf();
  }

  Future<void> disconnectSession(SessionId sessionId) async {
    final session = ref.read(sessionRepoProvider).getSession(sessionId);
    if (session == null) {
      return;
    }
    if (session.connId == null) {
      return;
    }
    // close conn
    final connsServices = ref.read(sessionConnsServicesProvider.notifier);
    await connsServices.close(session.connId!);

    // remove conn
    await connsServices.removeConn(session.connId!);

    // set connId to null
    ref.read(sessionRepoProvider).unsetConnId(session.sessionId);

    ref.invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionNotifier extends _$SelectedSessionNotifier {
  @override
  SessionModel? build() {
    return ref.watch(sessionsServicesProvider.select((s) {
      return s.selectedSession;
    }));
  }
}

@Riverpod(keepAlive: true)
class SessionsDetailNotifier extends _$SessionsDetailNotifier {
  @override
  SessionDetailListModel build() {
    SessionListModel sessions = ref.watch(sessionsServicesProvider);
    SessionConnListModel conns = ref.watch(sessionConnsServicesProvider);
    InstancesServices instanceServices =
        ref.read(instancesServicesProvider.notifier);

    // selected instance
    SessionDetailModel? selectedSession;
    if (sessions.selectedSession != null) {
      InstanceModel? selectedInstance =
          sessions.selectedSession!.instanceId == null
              ? null
              : instanceServices
                  .getInstanceById(sessions.selectedSession!.instanceId!);
      selectedSession = SessionDetailModel(
        sessionId: sessions.selectedSession!.sessionId,
        instanceId: sessions.selectedSession!.instanceId,
        instanceName: selectedInstance?.name,
        dbType: selectedInstance?.dbType,
        connId: conns.conns[sessions.selectedSession!.connId]?.connId,
        connState: conns.conns[sessions.selectedSession!.connId]?.state,
        connErrorMsg: conns.conns[sessions.selectedSession!.connId]?.errorMsg,
        currentSchema: sessions.selectedSession!.currentSchema,
      );
    }
    return SessionDetailListModel(
      sessions: sessions.sessions.map((session) {
        InstanceModel? instance = session.instanceId == null
            ? null
            : instanceServices.getInstanceById(session.instanceId!);
        return SessionDetailModel(
          sessionId: session.sessionId,
          instanceId: session.instanceId,
          instanceName: instance?.name,
          dbType: instance?.dbType,
          connId: conns.conns[session.connId]?.connId,
          connState: conns.conns[session.connId]?.state,
          connErrorMsg: conns.conns[session.connId]?.errorMsg,
          currentSchema: session.currentSchema,
        );
      }).toList(),
      selectedSession: selectedSession,
    );
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionDetailNotifier extends _$SelectedSessionDetailNotifier {
  @override
  SessionDetailModel? build() {
    return ref.watch(sessionsDetailNotifierProvider.select((s) {
      return s.selectedSession;
    }));
  }
}

@Riverpod()
class SessionOpBarNotifier extends _$SessionOpBarNotifier {
  @override
  SessionOpBarModel? build() {
    SessionDetailModel? session =
        ref.watch(selectedSessionDetailNotifierProvider);
    if (session == null) {
      return null;
    }

    SessionDrawerModel? sessionDrawer =
        ref.watch(sessionDrawerNotifierProvider);
    if (sessionDrawer == null) {
      return null;
    }

    // Watch task overview to get running task count for auto refresh
    final taskOverview = ref.watch(taskOverviewServiceProvider);
    final runningTaskCount = taskOverview.runningTasks.length;

    return SessionOpBarModel(
      sessionId: session.sessionId,
      instanceId: session.instanceId,
      connId: session.connId,
      state: session.connState,
      currentSchema: session.currentSchema ?? "",
      isRightPageOpen: sessionDrawer.isRightPageOpen,
      runningTaskCount: runningTaskCount,
    );
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionStatusNotifier extends _$SelectedSessionStatusNotifier {
  @override
  SessionStatusModel? build() {
    SessionDetailModel? session =
        ref.watch(selectedSessionDetailNotifierProvider);
    if (session == null) {
      return null;
    }

    SQLResultDetailModel? sqlResultModel =
        ref.watch(selectedSQLResultNotifierProvider);

    return SessionStatusModel(
      sessionId: session.sessionId,
      instanceName: session.instanceName ?? "",
      connState: session.connState,
      connErrorMsg: session.connErrorMsg,
      resultId: sqlResultModel?.resultId,
      state: sqlResultModel?.state ?? SQLExecuteState.init,
      query: sqlResultModel?.query,
      executeTime: sqlResultModel?.executeTime,
      affectedRows: sqlResultModel?.data?.affectedRows,
    );
  }
}
