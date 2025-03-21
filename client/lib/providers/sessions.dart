// import 'package:client/core/connection/metadata.dart';
import 'package:client/core/connection/mysql.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/models/sessions.dart';
import 'package:client/models/sql_result.dart';
import 'package:client/storages/storages.dart';
import 'package:flutter/material.dart';
import 'package:client/models/instances.dart';
import 'package:sql_editor/re_editor.dart';

class InitializedProvider with ChangeNotifier {}

class SessionListProvider with ChangeNotifier {
  SessionProvider sessionProvider;
  final SessionsModel sessions;

  SessionListProvider(this.sessionProvider, this.sessions);

  Future<void> connect(SessionModel session) async {
    // todo
    for (final s in sessions.data) {
      if (s == session) {
        await session.conn!.connect();
        notifyListeners();
        if (session == sessionProvider._session) {
          sessionProvider.update(session);
          // sessionProvider.loadMetadata();
        }
        return;
      }
    }
  }

  Future<void> close(SessionModel session) async {
    // todo
    for (final s in sessions.data) {
      if (s == session) {
        await session.conn?.close();
        notifyListeners();
        if (session == sessionProvider._session) {
          sessionProvider.update(session);
        }
        return;
      }
    }
  }

  void selectSessionByIndex(int index) {
    if (sessions.data.select(index)) {
      notifyListeners();
      sessionProvider.update(sessions.data.selected());
    }
  }

  void reorderSession(int oldIndex, int newIndex) {
    sessions.data.reorder(oldIndex, newIndex);
    notifyListeners();
  }

  void addSession(SessionModel session) {
    sessions.data.add(session);
    notifyListeners();
    sessionProvider.update(session);
  }

  void deleteSessionByIndex(int index) {
    SessionModel session = sessions.data.removeAt(index);
    session.conn?.close();
    notifyListeners();
    sessionProvider.update(sessions.data.selected());
  }

  void refresh() {
    notifyListeners();
  }

  bool exist(SessionModel session) {
    return sessions.data.contains(session);
  }
}

class SessionProvider with ChangeNotifier {
  SessionModel? _session;
  bool showRecord = true;
  bool isRightPageOpen = true;

  SessionProvider(this._session);

  void update(SessionModel? session) {
    _session = session;
    notifyListeners();
  }

  void selectToRecord() {
    showRecord = true;
    notifyListeners();
  }

  void deleteSQLResultByIndex(int index) {
    if (_session == null) {
      return;
    }
    _session!.sqlResults.removeAt(index);
    if (_session!.sqlResults.isEmpty) showRecord = true;
    notifyListeners();
  }

  void selectSQLResultByIndex(int index) {
    if (_session == null) {
      return;
    }
    showRecord = false;
    _session!.sqlResults.select(index);
    notifyListeners();
  }

  void reorderSQLResult(int oldIndex, int newIndex) {
    if (_session == null) {
      return;
    }
    _session!.sqlResults.reorder(oldIndex, newIndex);
    notifyListeners();
  }

  SQLResultModel? getCurrentSQLResult() {
    if (_session == null) {
      return null;
    }
    return _session!.sqlResults.selected();
  }

  List<SQLResultModel>? getAllSQLResult() {
    if (_session == null) {
      return null;
    }
    return _session!.sqlResults;
  }

  bool canQuery() {
    if (_session == null) {
      return false;
    }
    return (_session!.state != SQLExecuteState.executing &&
        _session!.conn?.state == SQLConnectState.connected);
  }

  bool initialized() {
    return _session != null && _session!.conn != null;
  }

  void setConn(InstanceModel instance, {String? schema}) {
    // 记录使用的数据源
    Storage().addActiveInstance(instance);

    SQLConnectionMgr conn = SQLConnectionMgr(instance, onConnClose,
        currentSchema: schema, (schema) {
      session!.conn!.currentSchema = schema;
      Storage().addInstanceActiveSchema(instance, schema);
      notifyListeners();
    });

    if (_session == null) {
      _session = SessionModel(conn: conn);
    } else {
      _session!.conn = conn;
    }
    notifyListeners();
  }

  Future<void> connect() async {
    if (_session != null) {
      await _session!.conn!.connect();
      notifyListeners();
    }
  }

  void onConnClose() {
    notifyListeners();
  }

  SessionModel? get session => _session;

  Future<void> query(String query, bool newResult) async {
    if (_session == null) {
      return;
    }

    if (_session!.conn?.state != SQLConnectState.connected) {
      return;
    }
    SQLResultModel result;

    SQLResultModel? cur = _session!.sqlResults.selected();
    if (newResult || cur == null) {
      result = SQLResultModel(_session!.genSQLResultId(), query);
      _session!.sqlResults.add(result);
    } else {
      result = SQLResultModel(cur.id, query);
      _session!.sqlResults.replace(cur, result);
    }

    showRecord = false; // 如果执行query创建了新的tab则跳转过去
    _session!.state = SQLExecuteState.executing;
    notifyListeners();

    try {
      DateTime start = DateTime.now();
      BaseQueryResult queryResult = await _session!.conn!.conn2!.query(query);
      List<QueryResultRow> rows = queryResult.rows;
      DateTime end = DateTime.now();
      result.setDone(queryResult.columns, rows, end.difference(start),
          queryResult.affectedRows.toInt());
      _session!.state = SQLExecuteState.done;
    } catch (e) {
      result.setError(e);
      _session!.state = SQLExecuteState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> setCurrentSchema(String schema) async {
    await session!.conn!.conn2!.setCurrentSchema(schema);
    notifyListeners();
  }

  String? getCurrentSchema() {
    return session!.conn!.currentSchema;
  }

  Future<List<String>> getSchemas() async {
    List<String> schemas = await session!.conn!.conn2!.schemas();
    return schemas;
  }

  Future<void> loadMetadata() async {
    if (session!.metadata != null) {
      return;
    }
    session!.metadata = await session!.conn!.conn2!.metadata();
    notifyListeners();
  }

  MetaDataNode? getMetadata() {
    if (session!.metadata == null) {
      return null;
    }
    return session!.metadata;
  }

  CodeLineEditingController getSQLEditCode() => _session!.code;

  void showRightPage() {
    isRightPageOpen = true;
    notifyListeners();
  }

  void hideRightPage() {
    isRightPageOpen = false;
    notifyListeners();
  }
}
