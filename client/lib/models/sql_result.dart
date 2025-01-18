import 'package:client/core/connection/result_set.dart';
import 'package:excel/excel.dart';

enum SQLExecuteState { executing, done, error }

class SQLResultModel {
  int id;
  SQLExecuteState state = SQLExecuteState.executing;
  String query;
  Exception? error;
  ResultSet? resultSet;
  Duration? executeTime;

  SQLResultModel(this.id, this.query);

  void setDone(ResultSet resultSet, executeTime) {
    state = SQLExecuteState.done;
    this.resultSet = resultSet;
    this.executeTime = executeTime;
  }

  void setError(error) {
    state = SQLExecuteState.error;
    this.error = error;
  }

  Excel toExcel() {
    Excel excel = Excel.createExcel();
    Sheet sheet = excel["Sheet1"];
    sheet.appendRow(resultSet!.columns
        .map<TextCellValue>((e) => TextCellValue(e.name))
        .toList());
    for (final row in resultSet!.rows) {
      sheet.appendRow(row.cells
          .map<TextCellValue>((e) => TextCellValue(e.value.asString() ?? ""))
          .toList());
    }
    return excel;
  }
}
