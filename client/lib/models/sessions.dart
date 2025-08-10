import 'package:client/models/instances.dart';
import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/widgets/split_view.dart';

part 'sessions.freezed.dart';

abstract class SessionRepo {
  Future<SessionId> newSession();
  SessionListModel getSessions();
  SessionModel? getSession(SessionId sessionId);
  Future<void> updateSession(SessionId sessionId,
      {InstanceModel? instance, String? currentSchema});
  void setConnId(SessionId sessionId, ConnId connId);
  void unsetConnId(SessionId sessionId);
  Future<void> deleteSession(SessionId sessionId);
  void selectSessionByIndex(int index);
  void reorderSession(int oldIndex, int newIndex);
  String? getCode(SessionId sessionId);
  void saveCode(SessionId sessionId, String code);
}

abstract class SessionConnRepo {
  SessionConnListModel getConns();
  SessionConnModel getConn(ConnId connId);
  SessionConnModel createConn(InstanceModel model, {String? currentSchema});
  void removeConn(ConnId connId);

  Future<void> connect(
    ConnId connId, {
    Function()? onStateChangedCallback,
    Function(String)? onSchemaChangedCallback,
  });
  Future<void> close(ConnId connId);
  Future<void> setCurrentSchema(ConnId connId, String schema);
  Future<List<String>> getSchemas(ConnId connId);
  Future<MetaDataNode> getMetadata(ConnId connId);
  Future<BaseQueryResult?> query(ConnId connId, String query);
  Future<void> killQuery(ConnId connId);
}

abstract class SQLResultRepo {
  SQLResultsModel getSqlResults();
  void deleteSQLResults(SessionId sessionId);
  void selectSQLResult(ResultId resultId);
  SQLResultModel? selectedSQLResult(SessionId sessionId);
  void reorderSQLResult(SessionId sessionId, int oldIndex, int newIndex);
  SQLResultModel addSQLResult(SessionId sessionId);
  void deleteSQLResult(ResultId resultId);
  SQLResultDetailModel getSQLResult(ResultId resultId);
  void updateSQLResult(ResultId resultId, SQLResultDetailModel result);
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
    ConnId? connId,
    String? currentSchema,
  }) = _SessionModel;
}

@freezed
abstract class SessionDetailModel with _$SessionDetailModel {
  const factory SessionDetailModel({
    required SessionId sessionId,
    // instance
    InstanceId? instanceId,
    String? instanceName,
    DatabaseType? dbType,
    // conn
    ConnId? connId,
    SQLConnectState? connState,
    String? connErrorMsg,

    // schema
    String? currentSchema,
  }) = _SessionDetailModel;
}

@freezed
abstract class SessionListModel with _$SessionListModel {
  const factory SessionListModel({
    required List<SessionModel> sessions,
    SessionModel? selectedSession,
  }) = _SessionListModel;
}

@freezed
abstract class SessionDetailListModel with _$SessionDetailListModel {
  const factory SessionDetailListModel({
    required List<SessionDetailModel> sessions,
    SessionDetailModel? selectedSession,
  }) = _SessionDetailListModel;
}

@freezed
abstract class SessionOpBarModel with _$SessionOpBarModel {
  const factory SessionOpBarModel({
    required SessionId sessionId,
    required ConnId? connId,
    required SQLConnectState? state,
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

enum SQLConnectState {
  disconnected,
  connecting,
  connected,
  executing,
  unHealth,
  failed
}

enum SQLExecuteState { init, executing, done, error }

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
    // conn
    required SQLConnectState? connState,
    required String? connErrorMsg,
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
    required SQLConnectState state,
    String? errorMsg,
  }) = _SessionConnModel;
}

@freezed
abstract class SessionConnListModel with _$SessionConnListModel {
  const factory SessionConnListModel({
    required Map<ConnId, SessionConnModel> conns,
  }) = _SessionConnListModel;
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
    required String queryId,
    required SQLExecuteState state,
  }) = _SQLResultModel;
}

@freezed
abstract class SQLResultDetailModel with _$SQLResultDetailModel {
  const factory SQLResultDetailModel({
    required ResultId resultId,
    required SQLExecuteState state,
    String? queryId,
    String? query,
    Duration? executeTime,
    String? error,
    BaseQueryResult? data,
  }) = _SQLResultDetailModel;
}

@freezed
abstract class SessionSQLResultsModel with _$SessionSQLResultsModel {
  const factory SessionSQLResultsModel({
    required SessionId sessionId,
    required List<SQLResultModel> results,
    SQLResultModel? selected,
  }) = _SessionSQLResultsModel;
}

@freezed
abstract class SQLResultsModel with _$SQLResultsModel {
  const factory SQLResultsModel({
    required Map<SessionId, SessionSQLResultsModel> cache,
  }) = _SQLResultsModel;
}
