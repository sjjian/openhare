import 'package:client/core/conn.dart';
import 'package:excel/excel.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_sql_result.g.dart';

abstract class SQLResultRepo {
  ReorderSelectedList<SQLResultModel> sessionSqlResults(int sessionId);
  // session
  SQLResultModel? current(int sessionId); 

  void add(int sessionId, SQLResultModel sqlResult);
}

class SQLResults implements SQLResultRepo {
  Map<int, ReorderSelectedList<SQLResultModel>> sqlResults = {};

  @override
  ReorderSelectedList<SQLResultModel> sessionSqlResults(int sessionId) {
    if (!sqlResults.containsKey(sessionId)) {
      sqlResults[sessionId] = ReorderSelectedList();
    }
    return sqlResults[sessionId]!;
  }

  @override
  SQLResultModel? current(int sessionId) {
    return sessionSqlResults(sessionId).selected();
  }

  @override
  void add(int sessionId, SQLResultModel sqlResult) {
    sessionSqlResults(sessionId).add(sqlResult);
  }
}

class SQLResultModel {
  int id;
  SQLExecuteState state = SQLExecuteState.executing;
  String query;
  String? error;
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
  return SQLResults();
}