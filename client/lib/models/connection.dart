// import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:pluto_grid/pluto_grid.dart';

class SessionModel with ChangeNotifier {
  // CodeController? codeCtr;

  // MySQLConnection conn;

  // List<Future<SQLResultModel>>? results;
  SQLResultModel? result;

  // SessionModel(this.conn, this.codeCtr);

  SessionModel();

  Future<void> query(String query) async {
    result = SQLResultModel(query);
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
      result?.setDone(columns, rows);
    } catch (e) {
      result?.setError(e);
    } finally {
      notifyListeners();
    }
  }
}

enum SQLResultState { padding, done, error }

class SQLResultModel with ChangeNotifier {
  SQLResultState state = SQLResultState.padding;
  String query;
  Exception? error;
  List<PlutoColumn>? columns;
  List<PlutoRow>? rows;

  SQLResultModel(this.query);

  void setDone(columns, rows) {
    state = SQLResultState.done;
    this.columns = columns;
    this.rows = rows;
  }

  void setError(error) {
    state = SQLResultState.error;
    this.error = error;
  }
}

class ConnMetaModel {
  String host;
  int port;
  String user;
  String password;

  ConnMetaModel(this.host, this.port, this.user, this.password);
}
