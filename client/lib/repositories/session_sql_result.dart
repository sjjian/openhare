import 'package:client/core/conn.dart';
import 'package:excel/excel.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_sql_result.g.dart';

class SQLResultRepo {
  Map<int, ReorderSelectedList<SQLResult>> sqlResults = {};

  int genSQLResultId(int sessionId) {
    return sessionSqlResults(sessionId).isEmpty
        ? 0
        : sessionSqlResults(sessionId).fold(
                0,
                (previousId, element) =>
                    previousId < element.id ? element.id : previousId) +
            1;
  }

  ReorderSelectedList<SQLResult> sessionSqlResults(int sessionId) {
    if (!sqlResults.containsKey(sessionId)) {
      sqlResults[sessionId] = ReorderSelectedList();
    }
    return sqlResults[sessionId]!;
  }

  SQLResult getReuslt(int sessionId, int resultId) {
    return sessionSqlResults(sessionId)
        .where(
          (element) => element.id == resultId,
        )
        .first;
  }

  void select(int sessionId, int index) {
    sessionSqlResults(sessionId).select(index);
  }

  void reorder(int sessionId, int oldIndex, int newIndex) {
    sessionSqlResults(sessionId).reorder(oldIndex, newIndex);
  }

  SQLResult? selected(int sessionId) {
    return sessionSqlResults(sessionId).selected();
  }

  void update(int sessionId, int index, SQLResult result) {
    sessionSqlResults(sessionId)
        .replace(sessionSqlResults(sessionId).selected()!, result);
  }

  void newSQLResult(int sessionId) {
    SQLResult result = SQLResult(genSQLResultId(sessionId), sessionId);
    sessionSqlResults(sessionId).add(result);
  }

  void remove(int sessionId, int index) {
    sessionSqlResults(sessionId).removeAt(index);
  }
}

class SQLResult {
  int sessionId;
  int id;
  String? query;
  SQLExecuteState state = SQLExecuteState.executing;
  String? error;
  BaseQueryResult? data;
  Duration? executeTime;

  SQLResult(this.id, this.sessionId);

  void setDone(BaseQueryResult data, Duration executeTime) {
    this.data = data;
    this.executeTime = executeTime;
    state = SQLExecuteState.done;
  }

  void setError(String error) {
    state = SQLExecuteState.error;
    this.error = error;
  }

  Excel toExcel() {
    Excel excel = Excel.createExcel();
    Sheet sheet = excel["Sheet1"];
    sheet.appendRow(data!.columns
        .map<TextCellValue>((e) => TextCellValue(e.name))
        .toList());
    for (final row in data!.rows) {
      sheet.appendRow(row.values
          .map<TextCellValue>((e) => TextCellValue(e.getString() ?? ''))
          .toList());
    }
    return excel;
  }
}

@Riverpod(keepAlive: true)
SQLResultRepo sqlResultsRepo(Ref ref) {
  return SQLResultRepo();
}
