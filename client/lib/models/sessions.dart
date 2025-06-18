import 'package:client/repositories/instances.dart';
import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/widgets/split_view.dart';
import 'package:client/repositories/session_conn.dart';

part 'sessions.freezed.dart';

@freezed
abstract class SessionModel with _$SessionModel {
  const factory SessionModel({
    required int sessionId,
    int? instanceId,
    String? instanceName,
    DatabaseType? dbType,
    int? connId,
  }) = _SessionModel;
}

@freezed
abstract class SessionListModel with _$SessionListModel {
  const factory SessionListModel({
    required List<SessionModel> sessions,
    SessionModel? selectedSession,
  }) = _SessionListModel;
}

@freezed
abstract class SessionOpBarModel with _$SessionOpBarModel {
  const factory SessionOpBarModel({
    required int sessionId,
    required int connId,
    required bool canQuery,
    required String currentSchema,
    required bool isRightPageOpen,
  }) = _SessionOpBarModel;
}

abstract class SessionRepo {
  SessionListModel getSessions();
  SessionModel? getSession(int sessionId);
  Future<SessionModel> newSession();
  Future<void> updateSession(
      SessionModel model, InstanceModel instance, String currentSchema);
  void setConnId(int sessionId, int connId);
  Future<void> deleteSession(SessionModel model);
  void selectSessionByIndex(int index);
  void reorderSession(int oldIndex, int newIndex);
}

@freezed
abstract class SessionEditorModel with _$SessionEditorModel {
  const factory SessionEditorModel({
    required CodeLineEditingController code,
  }) = _SessionEditorModel;
}

enum SQLConnectState { pending, connecting, connected, failed }

enum DrawerPage {
  metadataTree,
  sqlResult,
}

@freezed
abstract class SessionDrawerModel with _$SessionDrawerModel {
  const factory SessionDrawerModel({
    required DrawerPage drawerPage,
    required BaseQueryValue? sqlResult,
    required BaseQueryColumn? sqlColumn,
    required bool showRecord,
    required bool isRightPageOpen,
  }) = _SessionDrawerModel;
}

@freezed
abstract class SessionSplitViewModel with _$SessionSplitViewModel {
  const factory SessionSplitViewModel({
    required SplitViewController multiSplitViewCtrl,
    required SplitViewController metaDataSplitViewCtrl,
  }) = _SessionSplitViewModel;
}

@freezed
abstract class SessionStatusModel with _$SessionStatusModel {
  const factory SessionStatusModel({
    required int sessionId,
    required String instanceName,
    // sql result
    int? resultId,
    required SQLExecuteState state,
    Duration? executeTime,
    BigInt? affectedRows,
    String? query,
  }) = _SessionStatusModel;
}

@freezed
abstract class SessionSQLEditorModel with _$SessionSQLEditorModel {
  const factory SessionSQLEditorModel({
    String? currentSchema,
    MetaDataNode? metadata,
  }) = _SessionSQLEditorModel;
}