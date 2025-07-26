import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/sessions/session_sql_result.dart';
import 'package:client/repositories/sessions/sessions.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/services/sessions/session_conn.dart';
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
    SessionModel selectedSession;
    if (state.selectedSession == null) {
      selectedSession = await ref.read(sessionRepoProvider).newSession();
    } else {
      selectedSession = state.selectedSession!;
    }

    ref
        .read(instancesServicesProvider.notifier)
        .addActiveInstance(instance.id, schema: schema);

    await ref.read(sessionRepoProvider).updateSession(selectedSession.sessionId,
        instance: instance, currentSchema: schema);
    ref.invalidateSelf();
  }

  Future<void> newSession() async {
    await ref.read(sessionRepoProvider).newSession();
    ref.invalidateSelf();
  }

  Future<void> deleteSessionByIndex(int index) async {
    // 1. delete session
    await ref
        .read(sessionRepoProvider)
        .deleteSession(state.sessions[index].sessionId);

    // 2. close conn
    final session = state.sessions[index];
    if (session.connId != null) {
      await ref
          .read(sessionConnServicesProvider(session.connId!).notifier)
          .close();
      await ref
          .read(sessionConnsServicesProvider.notifier)
          .removeConn(session.connId!);
    }

    // 3. delete result
    ref.read(sqlResultsRepoProvider).deleteSQLResults(session.sessionId);

    ref.invalidateSelf();
  }

  Future<void> connectSession(SessionId sessionId) async {
    final session = ref.read(sessionRepoProvider).getSession(sessionId);
    if (session == null) {
      return;
    }
    var connId = session.connId;
    if (connId == null) {
      // create conn
      final connsServices = ref.read(sessionConnsServicesProvider.notifier);
      final connModel = await connsServices.createConn(
        session.instanceId!,
        currentSchema: session.currentSchema,
      );
      // 关联 session 和 conn
      final repo = ref.read(sessionRepoProvider);
      repo.setConnId(session.sessionId, connModel.connId);
      connId = connModel.connId;
    }

    // connect conn
    final connServices = ref.read(sessionConnServicesProvider(connId).notifier);
    await connServices.connect(onSchemaChangedCallback: (schema) async {
      print("onSchemaChangedCallback: $schema");
      await ref
          .read(sessionRepoProvider)
          .updateSession(sessionId, currentSchema: schema);

      ref
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
    await ref
        .read(sessionConnServicesProvider(session.connId!).notifier)
        .close();

    // remove conn
    await ref
        .read(sessionConnsServicesProvider.notifier)
        .removeConn(session.connId!);

    // set connId to null
    ref.read(sessionRepoProvider).unsetConnId(session.sessionId);

    ref.invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionServices extends _$SelectedSessionServices {
  @override
  SessionModel? build() {
    return ref.watch(sessionsServicesProvider.select((s) {
      return s.selectedSession;
    }));
  }
}
