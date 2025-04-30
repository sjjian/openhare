import 'package:db_driver/db_driver.dart';
import 'package:client/models/sessions.dart';
import 'package:client/models/sql_result.dart';
import 'package:flutter/material.dart';
import 'package:client/models/instances.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/models/objectbox.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:client/widgets/split_view.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:sql_parser/parser.dart';

enum SQLConnectState { pending, connecting, connected, failed }

enum DrawerPage {
  metadataTree,
  sqlResult,
}

class Sessions {
  ReorderSelectedList<BaseSession> data = ReorderSelectedList();

  Sessions() {
    data.add(UnInitSession());
  }
}

sealed class BaseSession {}

class UnInitSession extends BaseSession {}

class Session extends BaseSession {
  // session model
  SessionModel model;

  // connection
  BaseConnection? conn2;
  SQLConnectState connState = SQLConnectState.pending;
  void Function()? _onClose;
  void Function(String)? _onSchemaChanged;
  SQLExecuteState? queryState;

  // metadata
  MetaDataNode? metadata;
  TreeController<DataNode>? metadataController;

  // sql results
  ReorderSelectedList<SQLResultModel> sqlResults = ReorderSelectedList();

  // split view
  final SplitViewController multiSplitViewCtrl =
      SplitViewController(Area(), Area(min: 35, size: 500));

  final SplitViewController metaDataSplitViewCtrl =
      SplitViewController(Area(flex: 7, min: 3), Area(flex: 3, min: 3));

  // sql editor
  CodeLineEditingController code = CodeLineEditingController(
      spanBuilder: ({required codeLines, required context, required style}) {
    return TextSpan(
        children: Lexer(codeLines.asString(TextLineBreak.lf))
            .tokens()
            .map<TextSpan>((tok) => TextSpan(
                text: tok.content,
                style: style.merge(getStyle(tok.id) ?? style)))
            .toList());
  });

  // session drawer
  bool isRightPageOpen = true;
  DrawerPage drawerPage = DrawerPage.metadataTree;
  BaseQueryValue? sqlResult;
  BaseQueryColumn? sqlColumn;
  bool showRecord = true;

  Session(this.model) {
    code.text = model.text ?? "";
  }

  void init(SessionModel model) {
    this.model = model;
    code.text = model.text ?? "";
  }

  int genSQLResultId() {
    return sqlResults.isEmpty
        ? 0
        : sqlResults.fold(
                0,
                (previousId, element) =>
                    previousId < element.id ? element.id : previousId) +
            1;
  }

  Future<void> connect() async {
    try {
      conn2 = await ConnectionFactory.open(
          type: model.instance.target!.dbType,
          meta: model.instance.target!.connectValue,
          schema: model.currentSchema,
          onCloseCallback: onConnClose,
          onSchemaChangedCallback: onSchemaChanged);
      connState = SQLConnectState.connected;
    } catch (e, s) {
      print("conn error: ${e}; ${s}");
      connState = SQLConnectState.failed;
    }
  }

  Future<void> close() async {
    if (conn2 == null || connState != SQLConnectState.connected) {
      return;
    }
    try {
      conn2!.close();
      connState = SQLConnectState.pending;
      conn2 = null;
    } catch (e) {
      // todo: handler error;
    }
  }

  bool canQuery() {
    return (queryState != SQLExecuteState.executing &&
        connState == SQLConnectState.connected);
  }

  String? get currentSchema {
    return model.currentSchema;
  }

  Future<List<String>> getSchemas() async {
    List<String> schemas = await conn2!.schemas();
    return schemas;
  }

  MetaDataNode? getMetadata() {
    if (metadata == null) {
      return null;
    }
    return metadata;
  }

  List<SQLResultModel>? getAllSQLResult() {
    return sqlResults;
  }

  SQLResultModel? getCurrentSQLResult() {
    return sqlResults.selected();
  }

  CodeLineEditingController getSQLEditCode() => code;

  void onConnClose() {
    connState = SQLConnectState.pending;
    _onClose?.call();
  }

  void onSchemaChanged(String schema) {
    model.currentSchema = schema;
    _onSchemaChanged?.call(schema);
  }

  void listenCallBack(
      void Function() onClose, void Function(String) onSchemaChanged) {
    _onClose = onClose;
    _onSchemaChanged = onSchemaChanged;
  }

  void unListenCallBack() {
    _onClose = null;
    _onSchemaChanged = null;
  }
}

class SessionsProvider with ChangeNotifier {
  SessionProvider sessionProvider;
  NewSessionProvider newSessionProvider;
  final Sessions sessions;

  SessionsProvider(
      this.sessionProvider, this.newSessionProvider, this.sessions);

  Future<void> connect(Session session) async {
    // todo
    for (final s in sessions.data) {
      if (s == session) {
        await session.connect();
        notifyListeners();
        if (session == sessionProvider.session) {
          sessionProvider.update(session);
          sessionProvider.loadMetadata();
        }
        return;
      }
    }
  }

  Future<void> close(Session session) async {
    // todo
    for (final s in sessions.data) {
      if (s == session) {
        await session.close();
        notifyListeners();
        if (session == sessionProvider.session) {
          sessionProvider.update(session);
        }
        return;
      }
    }
  }

  void updateSession(BaseSession? session) {
    if (session == null) {
      newSessionProvider.update(null);
    }
    switch (session!) {
      case Session s:
        sessionProvider.update(s);
      case UnInitSession s:
        newSessionProvider.update(s);
    }
  }

  void selectSessionByIndex(int index) {
    if (sessions.data.select(index)) {
      notifyListeners();
      updateSession(sessions.data.selected());
    }
  }

  void reorderSession(int oldIndex, int newIndex) {
    sessions.data.reorder(oldIndex, newIndex);
    notifyListeners();
  }

  void addSession(Session session) {
    sessions.data.replace(sessions.data.selected()!, session);
    // todo: save model
    notifyListeners();
    updateSession(session);
  }

  void newSession() {
    final s = UnInitSession();
    sessions.data.add(s);
    notifyListeners();
    updateSession(s);
  }

  void deleteSessionByIndex(int index) {
    BaseSession session = sessions.data.removeAt(index);
    switch (session) {
      case Session s:
        session.close();
        sessionProvider.update(s);
      case UnInitSession s:
        newSessionProvider.update(s);
    }

    if (sessions.data.isEmpty) {
      final s = UnInitSession();
      sessions.data.add(s);
      newSessionProvider.update(s);
    }

    // todo: delete model
    notifyListeners();
    updateSession(sessions.data.selected());
  }

  void refresh() {
    notifyListeners();
  }

  bool exist(SessionModel session) {
    return sessions.data.contains(session);
  }
}

class SessionBaseProvider with ChangeNotifier {
  Sessions sessions;
  SessionBaseProvider(this.sessions);

  Session? get session {
    final s = sessions.data.selected();
    if (s is Session) {
      return s;
    } else {
      return null;
    }
  }

  void refresh() {
    notifyListeners();
  }
}

class SessionProvider extends SessionBaseProvider {
  SessionProvider(super.sessions);

  void update(Session? targetSession) {
    if (session != null) {
      session!.unListenCallBack();
    }
    if (targetSession != null) {
      session!.listenCallBack(onConnClose, onSchemaChanged);
    }
    notifyListeners();
  }

  bool initialized() {
    return session != null && session!.model.instance.target != null;
  }

  void setConn(InstanceModel instance, {String? schema}) {
    // 记录使用的数据源
    objectbox.addActiveInstance(instance);
    if (schema != null) {
      objectbox.addInstanceActiveSchema(instance, schema);
    }
    session!.model.instance.target = instance;
    session!.model.currentSchema = schema;
    notifyListeners();
  }

  Future<void> connect() async {
    if (session != null) {
      await session!.connect();
      notifyListeners();
    }
  }

  void onConnClose() {
    notifyListeners();
  }

  void onSchemaChanged(String schema) {
    objectbox.addInstanceActiveSchema(session!.model.instance.target!, schema);
    notifyListeners();
  }

  Future<void> query(String query, bool newResult) async {
    if (session == null) {
      return;
    }

    if (session!.connState != SQLConnectState.connected) {
      return;
    }
    SQLResultModel result;

    SQLResultModel? cur = session!.sqlResults.selected();
    if (newResult || cur == null) {
      result = SQLResultModel(session!.genSQLResultId(), query);
      session!.sqlResults.add(result);
    } else {
      result = SQLResultModel(cur.id, query);
      session!.sqlResults.replace(cur, result);
    }

    session!.showRecord = false; // 如果执行query创建了新的tab则跳转过去
    session!.queryState = SQLExecuteState.executing;
    notifyListeners();

    try {
      DateTime start = DateTime.now();
      BaseQueryResult queryResult = await session!.conn2!.query(query);
      List<QueryResultRow> rows = queryResult.rows;
      DateTime end = DateTime.now();
      result.setDone(queryResult.columns, rows, end.difference(start),
          queryResult.affectedRows.toInt());
      session!.queryState = SQLExecuteState.done;
    } catch (e) {
      result.setError(e.toString());
      session!.queryState = SQLExecuteState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> setCurrentSchema(String schema) async {
    await session!.conn2!.setCurrentSchema(schema);
    notifyListeners();
  }

  // SQL Result
  void deleteSQLResultByIndex(int index) {
    if (session == null) {
      return;
    }
    session!.sqlResults.removeAt(index);
    if (session!.sqlResults.isEmpty) session!.showRecord = true;
    notifyListeners();
  }

  void selectSQLResultByIndex(int index) {
    if (session == null) {
      return;
    }
    session!.showRecord = false;
    session!.sqlResults.select(index);
    notifyListeners();
  }

  void reorderSQLResult(int oldIndex, int newIndex) {
    if (session == null) {
      return;
    }
    session!.sqlResults.reorder(oldIndex, newIndex);
    notifyListeners();
  }

  // Drawer
  Future<void> loadMetadata() async {
    if (session!.metadata != null) {
      return;
    }
    if (session!.connState != SQLConnectState.connected) {
      return;
    }
    session!.metadata = await session!.conn2!.metadata();
    notifyListeners();
  }

  void selectToRecord() {
    session!.showRecord = true;
    notifyListeners();
  }

  void showRightPage() {
    if (session == null) {
      return;
    }
    session!.isRightPageOpen = true;
    notifyListeners();
  }

  void hideRightPage() {
    if (session == null) {
      return;
    }
    session!.isRightPageOpen = false;
    notifyListeners();
  }

  bool isRightPageOpen() {
    if (session == null) {
      return false;
    }
    return session!.isRightPageOpen;
  }

  void goToTree() {
    if (session == null) {
      return;
    }
    session!.drawerPage = DrawerPage.metadataTree;
    notifyListeners();
  }

  void showSQLResult({BaseQueryValue? result, BaseQueryColumn? column}) {
    if (session == null) {
      return;
    }
    session!.drawerPage = DrawerPage.sqlResult;
    session!.sqlColumn = column ?? session!.sqlColumn;
    session!.sqlResult = result ?? session!.sqlResult;
    notifyListeners();
  }
}

class NewSessionProvider with ChangeNotifier {
  Sessions sessions;

  NewSessionProvider(this.sessions);

  void update(UnInitSession? session) {
    // _session = session;
    notifyListeners();
  }
}
