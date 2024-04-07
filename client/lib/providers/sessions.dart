import 'package:client/models/connection.dart';
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

  Future<void> connect(int sessionId) async {
    // todo
    for (final session in sessions.data) {
      if (session.id == sessionId) {
        await session.conn.connect();
        notifyListeners();
        if (session == sessionProvider._session) {
          sessionProvider.update(session);
        }
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
}

class SessionProvider with ChangeNotifier {
  SessionModel? _session;

  SessionProvider(this._session);

  void update(SessionModel? session) {
    _session = session;
    notifyListeners();
  }

  void deleteSQLResultByIndex(int index) {
    if (_session == null) {
      return;
    }
    _session!.sqlResults.removeAt(index);
    notifyListeners();
  }

  void selectSQLResultByIndex(int index) {
    if (_session == null) {
      return;
    }
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
        _session!.conn.state == SQLConnectState.connected);
  }

  Future<void> query(String query) async {
    if (_session == null) {
      return;
    }
    if (_session!.conn.state != SQLConnectState.connected) {
      return;
    }

    final result = SQLResultModel(_session!.genSQLResultId(), query);
    _session!.sqlResults.add(result);
    _session!.state = SQLExecuteState.executing;
    notifyListeners();

    try {
      IResultSet resultSet = await _session!.conn.conn!.execute(query);

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
      _session!.state = SQLExecuteState.done;
    } catch (e) {
      result.setError(e);
      _session!.state = SQLExecuteState.error;
    } finally {
      notifyListeners();
    }
  }

  CodeController getSQLEditCode() => _session!.code;
}
