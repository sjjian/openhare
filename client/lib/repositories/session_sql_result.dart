import 'package:client/models/session_sql_result.dart';
import 'package:client/repositories/session_conn.dart';
import 'package:excel/excel.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_sql_result.g.dart';

class SQLResultRepoImpl extends SQLResultRepo {
  Map<int, ReorderSelectedList<SQLResult>> sqlResults = {};

  ReorderSelectedList<SQLResult> sessionSqlResults(int sessionId) {
    if (!sqlResults.containsKey(sessionId)) {
      sqlResults[sessionId] = ReorderSelectedList();
    }
    return sqlResults[sessionId]!;
  }

  int genSQLResultId(int sessionId) {
    return !sqlResults.containsKey(sessionId)
        ? 0
        : sqlResults[sessionId]!.fold(
                0,
                (previousId, element) =>
                    previousId < element.id ? element.id : previousId) +
            1;
  }

  @override
  SQLResultListModel getSqlResults(int sessionId) {
    if (!sqlResults.containsKey(sessionId)) {
      sqlResults[sessionId] = ReorderSelectedList();
    }
    return SQLResultListModel(
        sessionId: sessionId,
        results: sqlResults[sessionId]!.map((m) {
          return SQLResultModel(
            sessionId: sessionId,
            index: sqlResults[sessionId]!.indexOf(m),
            result: m,
          );
        }).toList(),
        selected: sqlResults[sessionId]!.selected() != null
            ? SQLResultModel(
                sessionId: sessionId,
                index: sqlResults[sessionId]!
                    .indexOf(sqlResults[sessionId]!.selected()!),
                result: sqlResults[sessionId]!.selected()!)
            : null);
  }

  @override
  SQLResultModel getSQLReuslt(int sessionId, int resultId) {
    final result = sessionSqlResults(sessionId)
        .where(
          (element) => element.id == resultId,
        )
        .first;

    return SQLResultModel(
        sessionId: sessionId,
        index: sessionSqlResults(sessionId).indexOf(result),
        result: result);
  }

  @override
  void selectSQLResult(int sessionId, int index) {
    sessionSqlResults(sessionId).select(index);
  }

  @override
  void reorderSQLResult(int sessionId, int oldIndex, int newIndex) {
    sessionSqlResults(sessionId).reorder(oldIndex, newIndex);
  }

  @override
  SQLResultModel? selectedSQLReuslt(int sessionId) {
    final selectedResult = sessionSqlResults(sessionId).selected();
    if (selectedResult != null) {
      return SQLResultModel(
          sessionId: sessionId,
          index: sessionSqlResults(sessionId).indexOf(selectedResult),
          result: selectedResult);
    }
    return null;
  }

  @override
  void updateSQLResult(int sessionId, int index, SQLResult result) {
    sessionSqlResults(sessionId)[index] = result;
  }

  @override
  SQLResultModel addSQLResult(int sessionId) {
    SQLResult result = SQLResult(genSQLResultId(sessionId), sessionId);
    sessionSqlResults(sessionId).add(result);
    return SQLResultModel(
        sessionId: sessionId,
        index: sessionSqlResults(sessionId).indexOf(result),
        result: result);
  }

  @override
  void deleteSQLResult(int sessionId, int index) {
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
  return SQLResultRepoImpl();
}
