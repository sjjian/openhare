import 'package:client/models/session_sql_result.dart';
import 'package:client/repositories/session_conn.dart';
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
        : sessionSqlResults(sessionId).fold(
                0,
                (previousId, element) =>
                    previousId < element.id ? element.id : previousId) +
            1;
  }

  SQLResult _getSQLResult(int sessionId, int resultId) {
    return sessionSqlResults(sessionId).firstWhere(
      (element) => element.id == resultId,
    );
  }

  SQLResultModel _toModel(int sessionId, SQLResult result) {
    return SQLResultModel(
      sessionId: sessionId,
      resultId: result.id,
      query: result.query,
      state: result.state,
      executeTime: result.executeTime,
      error: result.error,
      data: result.data,
    );
  }

  @override
  SQLResultListModel getSqlResults(int sessionId) {
    if (!sqlResults.containsKey(sessionId)) {
      sqlResults[sessionId] = ReorderSelectedList();
    }
    return SQLResultListModel(
        sessionId: sessionId,
        results: sqlResults[sessionId]!.map((m) {
          return _toModel(sessionId, m);
        }).toList(),
        selected: sqlResults[sessionId]!.selected() != null
            ? _toModel(sessionId, sqlResults[sessionId]!.selected()!)
            : null);
  }

  @override
  SQLResultModel getSQLReuslt(int sessionId, int resultId) {
    final result = _getSQLResult(sessionId, resultId);
    return _toModel(sessionId, result);
  }

  @override
  void selectSQLResult(int sessionId, int resultId) {
    final result = _getSQLResult(sessionId, resultId);
    sessionSqlResults(sessionId)
        .select(sessionSqlResults(sessionId).indexOf(result));
  }

  @override
  void reorderSQLResult(int sessionId, int oldIndex, int newIndex) {
    sessionSqlResults(sessionId).reorder(oldIndex, newIndex);
  }

  @override
  SQLResultModel? selectedSQLResult(int sessionId) {
    final selectedResult = sessionSqlResults(sessionId).selected();
    if (selectedResult != null) {
      return _toModel(sessionId, selectedResult);
    }
    return null;
  }

  @override
  void updateSQLResult(int sessionId, int resultId, SQLResultModel result) {
    final orginResult = _getSQLResult(sessionId, resultId);
    orginResult.query = result.query;
    orginResult.data = result.data;
    orginResult.error = result.error;
    orginResult.executeTime = result.executeTime;
    orginResult.state = result.state;
  }

  @override
  SQLResultModel addSQLResult(int sessionId) {
    SQLResult result = SQLResult(genSQLResultId(sessionId), sessionId);
    sessionSqlResults(sessionId).add(result);
    return _toModel(sessionId, result);
  }

  @override
  void deleteSQLResult(int sessionId, int resultId) {
    final result = _getSQLResult(sessionId, resultId);
    sessionSqlResults(sessionId)
        .removeAt(sessionSqlResults(sessionId).indexOf(result));
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
}

@Riverpod(keepAlive: true)
SQLResultRepo sqlResultsRepo(Ref ref) {
  return SQLResultRepoImpl();
}
