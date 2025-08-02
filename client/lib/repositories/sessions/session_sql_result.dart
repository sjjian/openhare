import 'package:client/models/sessions.dart';
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

  SQLResultDetailModel _toModelDetail(SQLResult result) {
    return SQLResultDetailModel(
      resultId: ResultId(
          sessionId: SessionId(value: result.sessionId), value: result.id),
      query: result.query,
      state: result.state,
      executeTime: result.executeTime,
      error: result.error,
      data: result.data,
    );
  }

  SQLResultModel _toModel(SQLResult result) {
    return SQLResultModel(
      resultId: ResultId(
          sessionId: SessionId(value: result.sessionId), value: result.id),
      state: result.state,
    );
  }

  @override
  SQLResultsModel getSqlResults() {
    // 遍历 sqlResults，组装成 Map<SessionId, SQLResultListModel>
    final Map<SessionId, SessionSQLResultsModel> cache = {};
    sqlResults.forEach((sessionId, resultList) {
      final sessionIdObj = SessionId(value: sessionId);
      cache[sessionIdObj] = SessionSQLResultsModel(
        sessionId: sessionIdObj,
        results: resultList.map((r) => _toModel(r)).toList(),
        selected: resultList.selected() != null
            ? _toModel(resultList.selected()!)
            : null,
      );
    });
    return SQLResultsModel(cache: cache);
  }

  @override
  void deleteSQLResults(SessionId sessionId) {
    sqlResults.remove(sessionId.value);
  }

  @override
  SQLResultDetailModel getSQLResult(ResultId resultId) {
    final result = _getSQLResult(resultId.sessionId.value, resultId.value);
    return _toModelDetail(result);
  }

  @override
  void selectSQLResult(ResultId resultId) {
    final result = _getSQLResult(resultId.sessionId.value, resultId.value);
    sessionSqlResults(resultId.sessionId.value)
        .select(sessionSqlResults(resultId.sessionId.value).indexOf(result));
  }

  @override
  void reorderSQLResult(SessionId sessionId, int oldIndex, int newIndex) {
    sessionSqlResults(sessionId.value).reorder(oldIndex, newIndex);
  }

  @override
  SQLResultModel? selectedSQLResult(SessionId sessionId) {
    final selectedResult = sessionSqlResults(sessionId.value).selected();
    if (selectedResult != null) {
      return _toModel(selectedResult);
    }
    return null;
  }

  @override
  void updateSQLResult(ResultId resultId, SQLResultDetailModel result) {
    final orginResult = _getSQLResult(resultId.sessionId.value, resultId.value);
    orginResult.query = result.query;
    orginResult.data = result.data;
    orginResult.error = result.error;
    orginResult.executeTime = result.executeTime;
    orginResult.state = result.state;
  }

  @override
  SQLResultModel addSQLResult(SessionId sessionId) {
    SQLResult result =
        SQLResult(genSQLResultId(sessionId.value), sessionId.value);
    sessionSqlResults(sessionId.value).add(result);
    return _toModel(result);
  }

  @override
  void deleteSQLResult(ResultId resultId) {
    final result = _getSQLResult(resultId.sessionId.value, resultId.value);
    sessionSqlResults(resultId.sessionId.value)
        .removeAt(sessionSqlResults(resultId.sessionId.value).indexOf(result));
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
