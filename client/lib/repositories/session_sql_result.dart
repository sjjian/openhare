import 'package:client/core/conn.dart';
import 'package:excel/excel.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_sql_result.g.dart';

class SQLResultRepo {
  Map<int, ReorderSelectedList<SQLResult>> sqlResults = {};

  @override
  ReorderSelectedList<SQLResult> sessionSqlResults(int sessionId) {
    if (!sqlResults.containsKey(sessionId)) {
      sqlResults[sessionId] = ReorderSelectedList();
    }
    return sqlResults[sessionId]!;
  }

  @override
  SQLResult? current(int sessionId) {
    return sessionSqlResults(sessionId).selected();
  }

  void updateSQLResult(int sessionId, int index, SQLResult result) {
    sessionSqlResults(sessionId).replace(origin, target)
  }

  @override
  void add(int sessionId, SQLResult sqlResult) {
    sessionSqlResults(sessionId).add(sqlResult);
  }
}

class SQLResult {
  int id;
  SQLExecuteState state = SQLExecuteState.executing;
  String query;
  String? error;
  List<BaseQueryColumn>? columns;
  List<QueryResultRow>? rows;
  Duration? executeTime;
  int affectedRows = 0;

  SQLResult(this.id, this.query);

  void setDone(List<BaseQueryColumn> columns, List<QueryResultRow> rows, Duration executeTime, int affectedRows) {
    this.columns = columns;
    this.rows = rows;
    this.executeTime = executeTime;
    this.affectedRows = affectedRows;
    state = SQLExecuteState.done;
  }

  void setError(String error) {
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

@Riverpod(keepAlive: true)
SQLResultRepo sqlResultsRepo(Ref ref) {
  return SQLResultRepo();
}