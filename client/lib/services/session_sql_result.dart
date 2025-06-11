import 'package:client/models/session_sql_result.dart';
import 'package:client/services/session_conn.dart';
import 'package:client/repositories/session_sql_result.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:excel/excel.dart';

part 'session_sql_result.g.dart';

@Riverpod(keepAlive: true)
class SQLResultServices extends _$SQLResultServices {
  @override
  SQLResultModel build(int sessionId, int resultId) {
    return ref.watch(sqlResultsRepoProvider).getSQLReuslt(sessionId, resultId);
  }

  Future<void> loadFromQuery(String query) async {
    SQLResult result = state.result;
    try {
      DateTime start = DateTime.now();
      BaseQueryResult? queryResult = await ref
          .read(sessionConnServicesProvider(sessionId).notifier)
          .query(query);
      DateTime end = DateTime.now();
      result.setDone(queryResult!, end.difference(start));
    } catch (e) {
      result.setError(e.toString());
    } finally {
      ref
          .read(sqlResultsRepoProvider)
          .updateSQLResult(sessionId, state.index, result);
      ref.invalidateSelf();
    }
  }

  Excel toExcel() {
    return state.result.toExcel();
  }
}

@Riverpod(keepAlive: true)
class SQLResultsServices extends _$SQLResultsServices {
  @override
  SQLResultListModel build(int sessionId) {
    return ref.watch(sqlResultsRepoProvider).getSqlResults(sessionId);
  }

  void deleteSQLResult(int index) {
    SQLResultRepo repo = ref.read(sqlResultsRepoProvider);
    repo.deleteSQLResult(state.sessionId, index);
    ref.invalidateSelf();
  }

  void selectSQLResultByIndex(int index) {
    SQLResultRepo repo = ref.read(sqlResultsRepoProvider);
    repo.selectSQLResult(state.sessionId, index);
    ref.invalidateSelf();
  }

  void reorderSQLResult(int oldIndex, int newIndex) {
    SQLResultRepo repo = ref.read(sqlResultsRepoProvider);
    repo.reorderSQLResult(state.sessionId, oldIndex, newIndex);
    ref.invalidateSelf();
  }

  SQLResultModel addSQLResult() {
    SQLResultRepo repo = ref.read(sqlResultsRepoProvider);
    final result = repo.addSQLResult(state.sessionId);
    ref.invalidateSelf();
    return result;
  }
}
