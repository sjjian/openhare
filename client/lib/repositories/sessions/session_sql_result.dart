import 'package:client/models/sessions.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_sql_result.g.dart';

class SQLResultRepoImpl extends SQLResultRepo {
  Map<SessionId, ReorderSelectedList<SQLResultDetailModel>> sqlResults = {};

  ReorderSelectedList<SQLResultDetailModel> sessionSqlResults(
      SessionId sessionId) {
    if (!sqlResults.containsKey(sessionId)) {
      sqlResults[sessionId] = ReorderSelectedList();
    }
    return sqlResults[sessionId]!;
  }

  int genSQLResultId(SessionId sessionId) {
    return !sqlResults.containsKey(sessionId)
        ? 0
        : sessionSqlResults(sessionId).fold(
                0,
                (previousId, element) => previousId < element.resultId.value
                    ? element.resultId.value
                    : previousId) +
            1;
  }

  @override
  SQLResultDetailModel getSQLResult(ResultId resultId) {
    return sessionSqlResults(resultId.sessionId).firstWhere(
      (element) => element.resultId == resultId,
    );
  }

  SQLResultModel _toModel(SQLResultDetailModel result) {
    return SQLResultModel(
      resultId: result.resultId,
      state: result.state,
      queryId: result.queryId ?? "",
    );
  }

  @override
  SQLResultsModel getSqlResults() {
    // 遍历 sqlResults，组装成 Map<SessionId, SQLResultListModel>
    final Map<SessionId, SessionSQLResultsModel> cache = {};
    sqlResults.forEach((sessionId, resultList) {
      final sessionIdObj = sessionId;
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
  void selectSQLResult(ResultId resultId) {
    final result = getSQLResult(resultId);
    sessionSqlResults(resultId.sessionId)
        .select(sessionSqlResults(resultId.sessionId).indexOf(result));
  }

  @override
  void reorderSQLResult(SessionId sessionId, int oldIndex, int newIndex) {
    sessionSqlResults(sessionId).reorder(oldIndex, newIndex);
  }

  @override
  SQLResultModel? selectedSQLResult(SessionId sessionId) {
    final selectedResult = sessionSqlResults(sessionId).selected();
    if (selectedResult != null) {
      return _toModel(selectedResult);
    }
    return null;
  }

  @override
  void updateSQLResult(ResultId resultId, SQLResultDetailModel result) {
    sessionSqlResults(resultId.sessionId)
        .replace(getSQLResult(resultId), result);
  }

  @override
  SQLResultModel addSQLResult(SessionId sessionId) {
    SQLResultDetailModel result = SQLResultDetailModel(
      resultId: ResultId(
        sessionId: sessionId,
        value: genSQLResultId(sessionId),
      ),
      state: SQLExecuteState.init,
    );
    sessionSqlResults(sessionId).add(result);
    return _toModel(result);
  }

  @override
  void deleteSQLResult(ResultId resultId) {
    final result = getSQLResult(resultId);
    sessionSqlResults(resultId.sessionId)
        .removeAt(sessionSqlResults(resultId.sessionId).indexOf(result));
  }
}

@Riverpod(keepAlive: true)
SQLResultRepo sqlResultsRepo(Ref ref) {
  return SQLResultRepoImpl();
}
