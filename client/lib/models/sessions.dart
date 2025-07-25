import 'package:client/models/instances.dart';
import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/widgets/split_view.dart';
import 'package:client/repositories/sessions/session_conn.dart';

part 'sessions.freezed.dart';

abstract class SessionRepo {
  Future<SessionModel> newSession();
  SessionListModel getSessions();
  SessionModel? getSession(SessionId sessionId);
  Future<void> updateSession(
      SessionId sessionId, {InstanceModel? instance, String? currentSchema});
  void setConnId(SessionId sessionId, ConnId connId);
  void unsetConnId(SessionId sessionId);
  Future<void> deleteSession(SessionId sessionId);
  void selectSessionByIndex(int index);
  void reorderSession(int oldIndex, int newIndex);
}

abstract class SessionConnRepo {
  SessionConnModel getConn(ConnId connId);
  SessionConnModel createConn(InstanceModel model, {String? currentSchema});
  void removeConn(ConnId connId);

  Future<void> connect(
    ConnId connId, {
    Function()? onCloseCallback,
    Function(String)? onSchemaChangedCallback,
  });
  Future<void> close(ConnId connId);
  Future<void> setCurrentSchema(ConnId connId, String schema);
  Future<List<String>> getSchemas(ConnId connId);
  Future<MetaDataNode> getMetadata(ConnId connId);
  Future<BaseQueryResult?> query(ConnId connId, String query);
}

abstract class SQLResultRepo {
  SQLResultListModel getSqlResults(SessionId sessionId);
  void deleteSQLResults(SessionId sessionId);
  SQLResultModel getSQLReuslt(ResultId resultId);
  void selectSQLResult(ResultId resultId);
  SQLResultModel? selectedSQLResult(SessionId sessionId);
  void reorderSQLResult(SessionId sessionId, int oldIndex, int newIndex);
  SQLResultModel addSQLResult(SessionId sessionId);
  void deleteSQLResult(ResultId resultId);
  void updateSQLResult(ResultId resultId, SQLResultModel result);
}

// sessions model

@freezed
abstract class SessionId with _$SessionId {
  const factory SessionId({
    required int value,
  }) = _SessionId;
}

@freezed
abstract class SessionModel with _$SessionModel {
  const factory SessionModel({
    required SessionId sessionId,
    InstanceId? instanceId,
    String? instanceName,
    String? currentSchema,
    DatabaseType? dbType,
    ConnId? connId,
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
    required SessionId sessionId,
    required ConnId? connId,
    required bool canQuery,
    required String currentSchema,
    required bool isRightPageOpen,
  }) = _SessionOpBarModel;
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
    required SessionId sessionId,
    required String instanceName,
    // sql result
    ResultId? resultId,
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

// sessions conn model

@freezed
abstract class ConnId with _$ConnId {
  const factory ConnId({
    required int value,
  }) = _ConnId;
}

@freezed
abstract class SessionConnModel with _$SessionConnModel {
  const factory SessionConnModel({
    required ConnId connId,
    required InstanceId instanceId,
    required bool canQuery,
  }) = _SessionConnModel;
}

// sessions sql result model

@freezed
abstract class ResultId with _$ResultId {
  const factory ResultId({
    required SessionId sessionId,
    required int value,
  }) = _ResultId;
}

@freezed
abstract class SQLResultModel with _$SQLResultModel {
  const factory SQLResultModel({
    required ResultId resultId,
    required SQLExecuteState state,
    String? query,
    Duration? executeTime,
    String? error,
    BaseQueryResult? data,
  }) = _SQLResultModel;
}

@freezed
abstract class SQLResultListModel with _$SQLResultListModel {
  const factory SQLResultListModel({
    required SessionId sessionId,
    required List<SQLResultModel> results,
    SQLResultModel? selected,
  }) = _SQLResultListModel;
}
