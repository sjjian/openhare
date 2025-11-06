import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/sessions/sessions.dart';
import 'package:client/services/instances/metadata.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/sql_highlight.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sql_editor/re_editor.dart';

part 'session_sql_editor.g.dart';

@Riverpod(keepAlive: true)
class SessionSQLEditorService extends _$SessionSQLEditorService {
  @override
  SessionEditorModel build(SessionId sessionId) {
    final controller = CodeLineEditingController(
      spanBuilder: ({required codeLines, required context, required style}) {
        return getSQLHighlightTextSpan(codeLines.asString(TextLineBreak.lf),
            defalutStyle: style);
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
class SelectedSessionSQLEditorNotifier
    extends _$SelectedSessionSQLEditorNotifier {
  @override
  SessionSQLEditorModel build() {
    SessionModel? sessionModel = ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null) {
      return const SessionSQLEditorModel(sessionId: SessionId(value: 0));
    }
    if (sessionModel.instanceId != null) {
      InstanceMetadataModel? sessionMeta =
          ref.watch(instanceMetadataServicesProvider(sessionModel.instanceId!));
      return SessionSQLEditorModel(
        sessionId: sessionModel.sessionId,
        currentSchema: sessionModel.currentSchema,
        metadata: sessionMeta?.metadata
            .match((value) => value, (error) => null, () => null),
      );
    }

    return SessionSQLEditorModel(
      sessionId: sessionModel.sessionId,
      currentSchema: sessionModel.currentSchema,
      metadata: null,
    );
  }
}

@Riverpod(keepAlive: true)
class SessionEditorNotifier extends _$SessionEditorNotifier {
  @override
  SessionEditorModel build() {
    SessionModel? sessionModel = ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null) {
      return ref
          .watch(sessionSQLEditorServiceProvider(const SessionId(value: 0)));
    }
    return ref.watch(sessionSQLEditorServiceProvider(sessionModel.sessionId));
  }
}
