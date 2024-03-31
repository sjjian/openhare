import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:pluto_grid/pluto_grid.dart';

enum SQLExecuteState { executing, done, error }
enum SQLConnectState {connecting, connected, failed}

class ConnMetaModel {
  String host;
  int port;
  String user;
  String password;

  ConnMetaModel(this.host, this.port, this.user, this.password);
}

class SessionModel with ChangeNotifier {
  MySQLConnection? conn;
  SQLConnectState? connState;

  SQLExecuteState? state;

  List<SQLResultModel> results = [];

  SQLResultModel? currentResult;

  SessionModel();

  void connect() {}

  void deleteResultByIndex(int index) {
    final result = results.removeAt(index);

    // 如果删除了选中的result，则默认选中前一个
    if (currentResult == result) {
      if (results.isEmpty) {
        currentResult = null;
      } else {
        currentResult = index > 0 ? results[index - 1] : null;
      }
    }

    notifyListeners();
  }

  void selectResultByIndex(int index) {
    final result = results[index];
    currentResult = result;
    notifyListeners();
  }

  void reorderResult(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      // removing the item at oldIndex will shorten the list by 1.
      newIndex -= 1;
    }
    final SQLResultModel element = results.removeAt(oldIndex);
    results.insert(newIndex, element);
    notifyListeners();
  }

  SQLResultModel? getCurrentSQLResult() {
    return currentResult;
  }

  int genSQLResultId() {
    return results.isEmpty
        ? 0
        : results.fold(
                0,
                (previousId, element) =>
                    previousId < element.id ? element.id : previousId) +
            1;
  }

  Future<void> query(String query) async {
    final result = SQLResultModel(genSQLResultId(), query);
    results.add(result);
    currentResult = result;
    state = SQLExecuteState.executing;
    notifyListeners();

    try {
      final conn = await MySQLConnection.createConnection(
          host: "10.186.62.16",
          port: 3306,
          userName: "root",
          password: "mysqlpass");
      await conn.connect();
      IResultSet resultSet = await conn.execute(query);

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
      state = SQLExecuteState.done;
    } catch (e) {
      result.setError(e);
      state = SQLExecuteState.error;
    } finally {
      notifyListeners();
    }
  }
}

class SQLResultModel with ChangeNotifier {
  int id;
  SQLExecuteState state = SQLExecuteState.executing;
  String query;
  Exception? error;
  List<PlutoColumn>? columns;
  List<PlutoRow>? rows;

  SQLResultModel(this.id, this.query);

  void setDone(columns, rows) {
    state = SQLExecuteState.done;
    this.columns = columns;
    this.rows = rows;
  }

  void setError(error) {
    state = SQLExecuteState.error;
    this.error = error;
  }
}

