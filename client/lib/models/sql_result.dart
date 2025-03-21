import 'package:excel/excel.dart';

import 'package:db_driver/db_driver.dart';

enum SQLExecuteState { executing, done, error }

class SQLResultModel {
  int id;
  SQLExecuteState state = SQLExecuteState.executing;
  String query;
  Exception? error;
  List<BaseQueryColumn>? columns;
  List<QueryResultRow>? rows;
  Duration? executeTime;
  int affectedRows = 0;

  SQLResultModel(this.id, this.query);

  void setDone(List<BaseQueryColumn> columns, List<QueryResultRow> rows, Duration executeTime, int affectedRows) {
    this.columns = columns;
    this.rows = rows;
    this.executeTime = executeTime;
    this.affectedRows = affectedRows;
    state = SQLExecuteState.done;
  }

  void setError(error) {
    state = SQLExecuteState.error;
    this.error = error;
  }

  Excel toExcel() {
    Excel excel = Excel.createExcel();
    Sheet sheet = excel["Sheet1"];
    sheet.appendRow(columns!
        .map<TextCellValue>((e) => TextCellValue(e.name))
        .toList());
    for (final row in rows!) {
      sheet.appendRow(row.values
          .map<TextCellValue>((e) => TextCellValue(e.getString() ?? ''))
          .toList());
    }
    return excel;
  }
}
