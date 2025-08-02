import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/sessions/session_sql_result.dart';
import 'package:client/repositories/sessions/sessions.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/services/instances/metadata.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:client/widgets/split_view.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:sql_parser/parser.dart';
import 'package:excel/excel.dart' as excel;

part 'sessions.g.dart';

@Riverpod(keepAlive: true)
class SessionsServices extends _$SessionsServices {
  @override
  SessionListModel build() {
    SessionListModel sessions = ref.watch(sessionRepoProvider).getSessions();
    return sessions;
  }

  SessionDetailModel? getSession(SessionId sessionId) {
    SessionModel? session = ref.read(sessionRepoProvider).getSession(sessionId);
    if (session == null) {
      return null;
    }

    InstanceModel? instance = session.instanceId == null
        ? null
        : ref
            .read(instancesServicesProvider.notifier)
            .getInstanceById(session.instanceId!);

    SessionConnModel? conn = session.connId == null
        ? null
        : ref
            .read(sessionConnsServicesProvider.notifier)
            .getConn(session.connId!);

    return SessionDetailModel(
      sessionId: session.sessionId,
      instanceId: instance?.id,
      instanceName: instance?.name,
      dbType: instance?.dbType,
      connId: conn?.connId,
      connState: conn?.state,
      currentSchema: session.currentSchema,
    );
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

    ref
        .read(instancesServicesProvider.notifier)
        .addActiveInstance(instance.id, schema: schema);

    await ref.read(sessionRepoProvider).updateSession(selectedSessionId,
        instance: instance, currentSchema: schema);
    ref.invalidateSelf();
  }

  Future<void> newSession() async {
    await ref.read(sessionRepoProvider).newSession();
    ref.invalidateSelf();
  }

  Future<void> deleteSessionByIndex(int index) async {
    SessionModel session = state.sessions[index];

    // 1. delete session
    await ref.read(sessionRepoProvider).deleteSession(session.sessionId);

    // 2. kill and close conn
    if (session.connId != null) {
      final connsServices = ref.read(sessionConnsServicesProvider.notifier);
      await connsServices.killQuery(session.connId!);
      await connsServices.close(session.connId!);
      await connsServices.removeConn(session.connId!);
    }

    // 3. delete result
    ref.read(sqlResultsRepoProvider).deleteSQLResults(session.sessionId);

    // 4. delete provider status
    ref.invalidate(sessionSQLEditorServiceProvider(session.sessionId));
    ref.invalidate(sessionSplitViewStateProvider(session.sessionId));
    ref.invalidate(sessionDrawerStateProvider(session.sessionId));

    ref.invalidateSelf();
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
class SessionSQLEditorService extends _$SessionSQLEditorService {
  @override
  SessionEditorModel build(SessionId sessionId) {
    final controller = CodeLineEditingController(
      spanBuilder: ({required codeLines, required context, required style}) {
        return TextSpan(
          children: Lexer(codeLines.asString(TextLineBreak.lf))
              .tokens()
              .map<TextSpan>((tok) => TextSpan(
                  text: tok.content,
                  style: style.merge(getStyle(tok.id) ?? style)))
              .toList(),
        );
      },
    );

    final code = ref.read(sessionRepoProvider).getCode(sessionId);
    controller.text = code ?? "";
    return SessionEditorModel(code: controller);
  }

  void saveCode() {
    ref.read(sessionRepoProvider).saveCode(sessionId, state.code.text);
  }
}

@Riverpod(keepAlive: true)
SessionDrawerModel sessionDrawerState(Ref ref, SessionId sessionId) {
  return const SessionDrawerModel(
      drawerPage: DrawerPage.metadataTree,
      sqlResult: null,
      sqlColumn: null,
      showRecord: false,
      isRightPageOpen: true);
}

@Riverpod(keepAlive: true)
SessionSplitViewModel sessionSplitViewState(Ref ref, SessionId sessionId) {
  return SessionSplitViewModel(
      multiSplitViewCtrl: SplitViewController(Area(), Area(min: 35, size: 500)),
      metaDataSplitViewCtrl:
          SplitViewController(Area(flex: 7, min: 3), Area(flex: 3, min: 3)));
}

@Riverpod(keepAlive: true)
class SessionsNotifier extends _$SessionsNotifier {
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
class SelectedSessionNotifier extends _$SelectedSessionNotifier {
  @override
  SessionDetailModel? build() {
    return ref.watch(sessionsNotifierProvider.select((s) {
      return s.selectedSession;
    }));
  }
}

@Riverpod(keepAlive: true)
class SessionSplitViewNotifier extends _$SessionSplitViewNotifier {
  @override
  SessionSplitViewModel build() {
    SessionDetailModel? sessionModel =
        ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null) {
      return ref.watch(sessionSplitViewStateProvider(
          const SessionId(value: 0))); // todo: 空值处理
    }
    return ref.watch(sessionSplitViewStateProvider(sessionModel.sessionId));
  }
}

@Riverpod(keepAlive: true)
class SessionDrawerNotifier extends _$SessionDrawerNotifier {
  @override
  SessionDrawerModel build() {
    SessionDetailModel? sessionModel =
        ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null) {
      return ref.watch(sessionDrawerStateProvider(const SessionId(value: 0)));
    }
    return ref.watch(sessionDrawerStateProvider(sessionModel.sessionId));
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
class SessionMetadataNotifier extends _$SessionMetadataNotifier {
  @override
  InstanceMetadataModel? build() {
    SessionDetailModel? sessionModel =
        ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null || sessionModel.instanceId == null) {
      return null;
    }
    return ref
        .watch(instanceMetadataServicesProvider(sessionModel.instanceId!));
  }
}

@Riverpod()
class SessionOpBarNotifier extends _$SessionOpBarNotifier {
  @override
  SessionOpBarModel? build() {
    SessionDetailModel? session = ref.watch(selectedSessionNotifierProvider);
    if (session == null) {
      return null;
    }

    SessionDrawerModel? sessionDrawer =
        ref.watch(sessionDrawerNotifierProvider);
    if (sessionDrawer == null) {
      return null;
    }

    return SessionOpBarModel(
      sessionId: session.sessionId,
      connId: session.connId,
      state: session.connState,
      currentSchema: session.currentSchema ?? "",
      isRightPageOpen: sessionDrawer.isRightPageOpen,
    );
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionSQLEditorNotifier
    extends _$SelectedSessionSQLEditorNotifier {
  @override
  SessionSQLEditorModel build() {
    SessionDetailModel? sessionModel =
        ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null) {
      return const SessionSQLEditorModel();
    }
    InstanceMetadataModel? sessionMeta =
        ref.watch(sessionMetadataNotifierProvider);

    return SessionSQLEditorModel(
      currentSchema: sessionModel.currentSchema,
      metadata: sessionMeta?.metadata,
    );
  }
}

@Riverpod(keepAlive: true)
class SessionEditorNotifier extends _$SessionEditorNotifier {
  @override
  SessionEditorModel build() {
    SessionDetailModel? sessionModel =
        ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null) {
      return ref
          .watch(sessionSQLEditorServiceProvider(const SessionId(value: 0)));
    }
    return ref.watch(sessionSQLEditorServiceProvider(sessionModel.sessionId));
  }
}

@Riverpod(keepAlive: true)
class SelectedSQLResultTabNotifier extends _$SelectedSQLResultTabNotifier {
  @override
  SessionSQLResultsModel? build() {
    SessionDetailModel? sessionModel =
        ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null) {
      return null;
    }
    return ref.watch(sQLResultsServicesProvider.select((m) {
      return m.cache[sessionModel.sessionId];
    }));
  }
}

@Riverpod(keepAlive: true)
class SelectedSQLResultNotifier extends _$SelectedSQLResultNotifier {
  @override
  SQLResultDetailModel? build() {
    SessionDetailModel? sessionModel =
        ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null) {
      return null;
    }
    SQLResultModel? sqlResultModel =
        ref.watch(sQLResultsServicesProvider.select((m) {
      return m.cache[sessionModel.sessionId]?.selected;
    }));
    if (sqlResultModel == null) {
      return null;
    }
    return ref
        .read(sQLResultsServicesProvider.notifier)
        .getSQLResult(sqlResultModel.resultId);
  }

  excel.Excel toExcel() {
    final data = excel.Excel.createExcel();
    final sheet = data["Sheet1"];
    sheet.appendRow(state!.data!.columns
        .map<excel.TextCellValue>((e) => excel.TextCellValue(e.name))
        .toList());
    for (final row in state!.data!.rows) {
      sheet.appendRow(row.values
          .map<excel.TextCellValue>(
              (e) => excel.TextCellValue(e.getString() ?? ''))
          .toList());
    }
    return data;
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionStatusNotifier extends _$SelectedSessionStatusNotifier {
  @override
  SessionStatusModel? build() {
    SessionDetailModel? session = ref.watch(selectedSessionNotifierProvider);
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
