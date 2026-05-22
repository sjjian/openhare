import 'package:client/models/ai.dart';
import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/sessions/session_sql_result.dart';
import 'package:client/repositories/sessions/sessions.dart';
import 'package:client/services/ai/chat.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/services/sessions/session_drawer.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/sessions/session_controller.dart';
import 'package:client/services/tasks/overview.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions.g.dart';

@Riverpod(keepAlive: true)
class SessionsServices extends _$SessionsServices {
  @override
  int build() {
    return 1;
  }

  void _invalidateSelf() {
    state++;
  }

  SessionModel? getSession(SessionId sessionId) {
    return ref.read(sessionRepoProvider).getSession(sessionId);
  }

  SessionListModel getSessions() {
    return ref.read(sessionRepoProvider).getSessions();
  }

  void selectSessionByIndex(int index) {
    ref.read(sessionRepoProvider).selectSessionByIndex(index);
    _invalidateSelf();
  }

  void reorderSession(int oldIndex, int newIndex) {
    ref.read(sessionRepoProvider).reorderSession(oldIndex, newIndex);
    _invalidateSelf();
  }

  void updateSessionConfig(SessionId sessionId, SessionConfigModel config) {
    ref.read(sessionRepoProvider).updateSessionConfig(sessionId, config);
    _invalidateSelf();
  }

  Future<void> addSession(InstanceModel instance, {DatabaseRef? schema}) async {
    SessionId selectedSessionId;
    final selectedSession = ref.read(sessionRepoProvider).seletedSession();
    if (selectedSession == null) {
      selectedSessionId = ref.read(sessionRepoProvider).newSession();
    } else {
      selectedSessionId = selectedSession.sessionId;
    }

    // is async
    ref.read(instancesServicesProvider.notifier).addActiveInstance(instance.id, schema: schema);

    ref.read(sessionRepoProvider).updateSession(selectedSessionId, instance: instance, currentSchema: schema);

    _invalidateSelf();

    // auto connect when new session.
    connectSession(selectedSessionId);
  }

  void newSession() {
    ref.read(sessionRepoProvider).newSession();
    _invalidateSelf();
  }

  Future<void> deleteSessionByInstance(InstanceId instanceId) async {
    final sessions = getSessions().sessions.where((s) => s.instanceId?.value == instanceId.value).toList();
    for (final session in sessions) {
      await deleteSession(session.sessionId);
    }
  }

  Future<void> deleteSession(SessionId sessionId) async {
    SessionModel? session = ref.read(sessionRepoProvider).getSession(sessionId);
    if (session == null) {
      return;
    }
    // 1. delete session
    ref.read(sessionRepoProvider).deleteSession(session.sessionId);
    _invalidateSelf();

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
    ref.read(aIChatServiceProvider.notifier).delete(AIChatId(value: session.sessionId.value));

    // 5. delete provider status
    ref.invalidate(sessionDrawerServicesProvider(session.sessionId));
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
      _invalidateSelf();
    }

    // connect conn
    await connsServices.connect(
      connId,
      onSchemaChangedCallback: (schema) async {
        ref.read(sessionRepoProvider).updateSession(sessionId, currentSchema: schema);

        ref.read(instancesServicesProvider.notifier).addActiveInstance(session.instanceId!, schema: schema);

        _invalidateSelf();
      },
    );

    _invalidateSelf();
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

    _invalidateSelf();
  }

  void saveCode(SessionId sessionId) {
    final controller = SessionController.getSessionController(sessionId);
    if (controller == null) {
      return;
    }
    ref.read(sessionRepoProvider).saveCode(sessionId, controller.sqlEditorController.text);
    _invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionNotifier extends _$SelectedSessionNotifier {
  @override
  SessionModel? build() {
    ref.watch(sessionsServicesProvider);
    return ref.read(sessionRepoProvider).seletedSession();
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionDetailNotifier extends _$SelectedSessionDetailNotifier {
  @override
  SessionDetailModel? build() {
    final session = ref.watch(selectedSessionProvider);
    SessionConnListModel conns = ref.watch(sessionConnsServicesProvider);
    InstancesServices instanceServices = ref.read(instancesServicesProvider.notifier);
    if (session == null) {
      return null;
    }
    InstanceModel? selectedInstance = session.instanceId == null
        ? null
        : instanceServices.getInstanceById(session.instanceId!);

    return SessionDetailModel(
      sessionId: session.sessionId,
      instanceId: session.instanceId,
      instanceName: selectedInstance?.name,
      dbType: selectedInstance?.dbType,
      connId: conns.conns[session.connId]?.connId,
      connState: conns.conns[session.connId]?.state,
      connErrorMsg: conns.conns[session.connId]?.errorMsg,
      currentSchema: session.currentSchema,
      config: session.config,
      codeSaveTime: ref.read(sessionRepoProvider).getCodeSaveTime(session.sessionId),
    );
  }
}

@Riverpod(keepAlive: true)
class SessionTabNotifier extends _$SessionTabNotifier {
  @override
  SessionDetailListModel build() {
    ref.watch(sessionsServicesProvider);
    SessionConnListModel conns = ref.watch(sessionConnsServicesProvider);
    InstancesServices instanceServices = ref.read(instancesServicesProvider.notifier);

    final sessions = ref.read(sessionsServicesProvider.notifier).getSessions();
    // selected instance

    SessionDetailModel? selectedSession = ref.watch(selectedSessionDetailProvider);

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
          config: session.config,
        );
      }).toList(),
      selectedSession: selectedSession,
    );
  }
}

@Riverpod()
class SessionOpBarNotifier extends _$SessionOpBarNotifier {
  @override
  SessionOpBarModel? build() {
    SessionDetailModel? session = ref.watch(selectedSessionDetailProvider);
    if (session == null) {
      return null;
    }

    SessionDrawerModel? sessionDrawer = ref.watch(sessionDrawerProvider);
    if (sessionDrawer == null) {
      return null;
    }

    // Watch task overview to get running task count for auto refresh
    final taskOverview = ref.watch(taskOverviewServiceProvider);
    final runningTaskCount = taskOverview.runningTasks.length;

    return SessionOpBarModel(
      sessionId: session.sessionId,
      config: session.config,
      instanceId: session.instanceId,
      dbType: session.dbType,
      connId: session.connId,
      state: session.connState,
      currentSchema: session.currentSchema,
      isRightPageOpen: sessionDrawer.isRightPageOpen,
      runningTaskCount: runningTaskCount,
      codeSaveTime: session.codeSaveTime,
    );
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionStatusNotifier extends _$SelectedSessionStatusNotifier {
  @override
  SessionStatusModel? build() {
    SessionDetailModel? session = ref.watch(selectedSessionDetailProvider);
    if (session == null) {
      return null;
    }

    SQLResultDetailModel? sqlResultModel = ref.watch(selectedSQLResultProvider);

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
