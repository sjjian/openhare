import 'package:client/models/ai.dart';
import 'package:client/models/instances.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/widgets/split_view.dart';

part 'sessions.freezed.dart';

abstract class SessionRepo {
  SessionId newSession();
  SessionListModel getSessions();
  SessionModel? getSession(SessionId sessionId);
  SessionModel? seletedSession();
  void updateSession(SessionId sessionId, {InstanceModel? instance, DatabaseRef? currentSchema});
  void setConnId(SessionId sessionId, ConnId connId);
  void unsetConnId(SessionId sessionId);
  void deleteSession(SessionId sessionId);
  void selectSessionByIndex(int index);
  void reorderSession(int oldIndex, int newIndex);
  String? getCode(SessionId sessionId);
  DateTime? getCodeSaveTime(SessionId sessionId);
  void saveCode(SessionId sessionId, String code);
  void updateSessionConfig(SessionId sessionId, SessionConfigModel config);
  SessionConfigModel getSessionConfig(SessionId sessionId);
}

abstract class SessionConnRepo {
  SessionConnListModel getConns();
  SessionConnModel getConn(ConnId connId);
  SessionConnModel createConn(InstanceModel model, {DatabaseRef? currentSchema});
  void removeConn(ConnId connId);

  Future<void> connect(
    ConnId connId, {
    Function()? onStateChangedCallback,
    Function(DatabaseRef)? onSchemaChangedCallback,
  });
  Future<void> close(ConnId connId);
  Future<void> setCurrentSchema(ConnId connId, DatabaseRef schema);
  Future<BaseQueryResult?> query(ConnId connId, String query, {int? limit});
  Stream<BaseQueryStreamItem> queryStream(ConnId connId, String query);
  Future<void> killQuery(ConnId connId);
  bool supportsKillQuery(ConnId connId);
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
    DatabaseRef? currentSchema,
    required SessionConfigModel config,
  }) = _SessionModel;
}

@freezed
abstract class SessionConfigModel with _$SessionConfigModel {
  const factory SessionConfigModel({
    @Default(1000) int queryLimit, // 每次查询的记录数, 0 表示不限制, 会自动补全limit语句
    @Default(true) bool enableQueryCheck, // 是否启用查询二次检查, true 表示启用, false 表示不启用
    // ai chat config
    @Default(false) bool askDQL, // 是否启用聊天输入时确认DQL语句
    @Default(true) bool askNoDQL, // 是否启用聊天输入时确认非DQL语句
    @Default(true) bool askDangerousSQL, // 是否启用聊天输入时确认高影响、危险SQL语句
  }) = _SessionConfigModel;
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
    DatabaseRef? currentSchema,

    // config
    required SessionConfigModel config,

    // code save time
    @Default(null) DateTime? codeSaveTime,
  }) = _SessionDetailModel;
}

@freezed
abstract class SessionListModel with _$SessionListModel {
  const factory SessionListModel({
    required List<SessionModel> sessions,
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
    required SessionConfigModel config,
    InstanceId? instanceId,
    DatabaseType? dbType,
    ConnId? connId,
    required SQLConnectState? state,
    DatabaseRef? currentSchema,
    required bool isRightPageOpen,
    required int runningTaskCount,
    DateTime? codeSaveTime,
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
  failed;

  static bool isConnected(SQLConnectState? state) {
    return state != null && (state == connected || state == executing);
  }

  static bool isDisconnected(SQLConnectState? state) {
    return state == null || state == disconnected || state == failed;
  }

  static bool isIdle(SQLConnectState? state) {
    return state != null && state == connected;
  }

  static bool isBusy(SQLConnectState? state) {
    return state != null && (state == connecting || state == executing);
  }

  static bool isConnecting(SQLConnectState? state) {
    return state != null && state == connecting;
  }

  static bool isUnhealthy(SQLConnectState? state) {
    return state != null && state == unHealth;
  }
}

enum SQLExecuteState { init, executing, done, error, cancel }

enum DrawerPage {
  sqlResult,
  aiChat,
}

@freezed
abstract class SessionDrawerModel with _$SessionDrawerModel {
  const factory SessionDrawerModel({
    required SessionId sessionId,
    required DrawerPage drawerPage,
    required BaseQueryValue? sqlResult,
    required BaseQueryColumn? sqlColumn,
    required bool showRecord,
    required bool isRightPageOpen,
    required bool isMetadataTreeOpen,
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
    required SessionId sessionId,
    DatabaseType? dbType,
    DatabaseRef? currentSchema,
    List<MetaDataNode>? metadata,
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
    ConnId? connId,
    @Default(false) bool canKill, // 该连接是否支持服务端 kill query；不支持时 UI 不展示「取消」按钮。
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

@freezed
abstract class SessionAIChatModel with _$SessionAIChatModel {
  const factory SessionAIChatModel({
    required SessionId sessionId,
    required SessionConfigModel config,
    required DatabaseRef? currentSchema,
    required DatabaseType? dbType,
    required InstanceMetadataModel? metadata,
    required ConnId? connId,
    required SQLConnectState? state,
    required AIChatOverviewModel chatOverviewModel,
    required LLMAgentsModel llmAgents,
  }) = _SessionAIChatModel;

  const SessionAIChatModel._();

  bool canSendMessage() {
    return llmAgents.lastUsedLLMAgent != null && chatOverviewModel.state != AIChatState.waiting;
  }

  bool canClearMessage() {
    return chatOverviewModel.state != AIChatState.waiting && chatOverviewModel.messageCount > 0;
  }
}

// session metadata model
@freezed
abstract class SelectedSessionSchemaModel with _$SelectedSessionSchemaModel {
  const factory SelectedSessionSchemaModel({
    required SessionId sessionId,
    required DatabaseModeType databaseMode,
    required List<DatabaseRef> schemas,
  }) = _SelectedSessionSchemaModel;
}

// session metadata tree model
@freezed
abstract class SessionMetadataTreeModel with _$SessionMetadataTreeModel {
  const factory SessionMetadataTreeModel({
    required SessionId sessionId,
    required TreeController<DataNode> metadataTreeCtrl,
  }) = _SessionMetadataTreeModel;
}
