import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:pluto_grid/pluto_grid.dart';

class SessionWindowNotifier with ChangeNotifier {
  String text = "select * from db1.t1;";

  List<SQLResultModel>? results;
}

class SQLResultModel {
  List<PlutoColumn> columns;
  List<PlutoRow> rows;

  SQLResultModel(this.columns, this.rows);
}

class ConnectionModel {
  Future<SQLResultModel> query(String query) async {
    final conn = await MySQLConnection.createConnection(
        host: "10.186.62.16",
        port: 3306,
        userName: "root",
        password: "mysqlpass");
    await conn.connect();
    IResultSet results = await conn.execute(query);

    List<PlutoColumn> columns = List.empty();
    for (final column in results.cols) {
      columns.add(PlutoColumn(
          title: column.name,
          field: column.name,
          type: PlutoColumnType.text()));
    }

    List<PlutoRow> rows = List.empty();
    for (final result in results) {
      // for every result set
      for (final row in result.rows) {
        Map<String, PlutoCell> cells = row
            .assoc()
            .map((key, value) => MapEntry(key, PlutoCell(value: value)));
        rows.add(PlutoRow(cells: cells));
      }
    }
    return SQLResultModel(columns, rows);
  }
}
