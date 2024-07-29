import 'package:client/core/connection/sql.dart';
import 'package:client/models/sessions.dart';
import 'package:client/models/sql_result.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:mysql_client/mysql_client.dart';

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

  void setConn(SQLConnection conn) {
    if (_session == null) {
      _session = SessionModel(conn: conn);
    } else {
      _session!.conn = conn;
    }
    notifyListeners();
  }

  SessionModel? get session => _session;

  Future<void> query(String query) async {
    if (_session == null) {
      return;
    }
    if (_session!.conn?.state != SQLConnectState.connected) {
      return;
    }

    final result = SQLResultModel(_session!.genSQLResultId(), query);
    _session!.sqlResults.add(result);
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
      print(
          "effect rows: ${result.effectRows}, execute time: ${result.executeTime}");
      notifyListeners();
    }
  }

  CodeController getSQLEditCode() => _session!.code;
}
