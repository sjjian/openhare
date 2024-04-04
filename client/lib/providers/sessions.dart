import 'package:client/models/connection.dart';
import 'package:client/models/sessions.dart';
import 'package:client/models/sql_result.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:mysql_client/mysql_client.dart';

class InitializedProvider with ChangeNotifier {}

class SessionTileProvider with ChangeNotifier {
  SessionsModel sessions;

  SessionTileProvider(this.sessions);

  Future<void> connect(int sessionId) async {
    // todo
    for (final session in sessions.data) {
     if (session.id == sessionId) {
        await session.conn.connect();
        notifyListeners();
        return;
      }
    }
  }

  Future<void> close(int sessionId) async {
    // todo
    for (final session in sessions.data) {
     if (session.id == sessionId) {
        await session.conn.close();
        notifyListeners();
        return;
      }
    }
  }
}

class SessionProvider with ChangeNotifier {
  final SessionsModel _sessions;

  SessionProvider(this._sessions);

  void deleteSQLResultByIndex(int index) {
    if (_sessions.current == null) {
      return;
    }
    _sessions.current!.deleteResultByIndex(index);
    notifyListeners();
  }

  void selectSQLResultByIndex(int index) {
    if (_sessions.current == null) {
      return;
    }
    _sessions.current!.selectResultByIndex(index);
    notifyListeners();
  }

  void reorderSQLResult(int oldIndex, int newIndex) {
    if (_sessions.current == null) {
      return;
    }
    _sessions.current!.reorderResult(oldIndex, newIndex);
    notifyListeners();
  }

  SQLResultModel? getCurrentSQLResult() {
    if (_sessions.current == null) {
      return null;
    }
    return _sessions.current!.getCurrentSQLResult();
  }

  List<SQLResultModel>? getAllSQLResult() {
    if (_sessions.current == null) {
      return null;
    }
    return _sessions.current!.results;
  }

  bool canQuery() {
    if (_sessions.current == null) {
      return false;
    }
    return (_sessions.current!.state != SQLExecuteState.executing &&
        _sessions.current!.conn.state == SQLConnectState.connected);
  }

  Future<void> query(String query) async {
    if (_sessions.current == null) {
      return;
    }
    final current = _sessions.current!;
    if (current.conn.state != SQLConnectState.connected) {
      return;
    }

    final result = SQLResultModel(current.genSQLResultId(), query);
    current.addSQLResult(result);
    current.state = SQLExecuteState.executing;
    notifyListeners();

    try {
      IResultSet resultSet = await current.conn.conn!.execute(query);

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
      result.setDone(columns, rows);
      current.state = SQLExecuteState.done;
    } catch (e) {
      result.setError(e);
      current.state = SQLExecuteState.error;
    } finally {
      notifyListeners();
    }
  }
}
