import 'package:client/core/connection/metadata.dart';
import 'package:client/core/connection/sql.dart';
import 'package:client/models/sessions.dart';
import 'package:client/models/sql_result.dart';
import 'package:client/screens/sessions/session_sql_editor.dart';
import 'package:client/storages/storages.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:client/models/instances.dart';
import 'package:re_editor/re_editor.dart';

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

  String drawerPage = "tree";

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

    SQLConnection conn =
        SQLConnection(instance, onConnClose, currentSchema: schema, (schema) {
      Storage().addInstanceActiveSchema(instance, schema);
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
      IResultSet resultSet = await _session!.conn!.execute(query);
      DateTime end = DateTime.now();

      List<PlutoColumn> columns = List.empty(growable: true);
      for (final column in resultSet.cols) {
        columns.add(PlutoColumn(
            title: column.name,
            field: column.name,
            type: PlutoColumnType.text()));
      }

      List<PlutoRow> rows = List.empty(growable: true);
      for (final result in resultSet) {
        for (final row in result.rows) {
          Map<String, PlutoCell> cells = row
              .assoc()
              .map((key, value) => MapEntry(key, PlutoCell(value: value)));
          rows.add(PlutoRow(cells: cells));
        }
      }
      result.setDone(
          columns, rows, resultSet.affectedRows, end.difference(start));
      _session!.state = SQLExecuteState.done;
    } catch (e) {
      result.setError(e);
      _session!.state = SQLExecuteState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> setCurrentSchema(String schema) async {
    await session!.conn!.setCurrentSchema(schema);
    notifyListeners();
  }

  Future<List<String>> getSchemas() async {
    List<String> schemas = await session!.conn!.schemas();
    return schemas;
  }

  Future<void> loadMetadata() async {
    if (session!.metadata != null) {
      return;
    }
    List<SchemaMeta> metadata = List<SchemaMeta>.empty(growable: true);
    List<String> schemas = await session!.conn!.schemas();
    for (var schema in schemas) {
      SchemaMeta schemaMeta = SchemaMeta(schema);
      metadata.add(schemaMeta);
      List<String> tables = await session!.conn!.getTables(schema);
      for (var table in tables) {
        schemaMeta.tables.add(TableMeta(table));
      }
    }
    session!.metadata = metadata;
    notifyListeners();
  }

  List<SchemaMeta>? getMetadata() {
    if (session!.metadata == null) {
      return null;
    }
    return session!.metadata;
  }

  Future<void> loadTableMeta(String schema, String table) async {
    // todo: 使用map
    for (var schemaMeta in session!.metadata!) {
      if (schemaMeta.name == schema) {
        for (var tableMeta in schemaMeta.tables) {
          if (tableMeta.name == table) {
            if (tableMeta.columns != null) {
              return;
            }
            List<TableColumnMeta> columns =
                await session!.conn!.getTableColumns(schema, table);
            tableMeta.columns = columns;

            List<TableKeyMeta> keys =
                await session!.conn!.getTableKeys(schema, table);
            tableMeta.keys = keys;
            notifyListeners();
          }
        }
      }
    }
  }

  TableMeta? getTableMeta(String schema, String table) {
    // todo: 使用map
    for (var schemaMeta in session!.metadata!) {
      if (schemaMeta.name == schema) {
        for (var tableMeta in schemaMeta.tables) {
          if (tableMeta.name == table) {
            return tableMeta;
          }
        }
      }
    }
    return null;
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
