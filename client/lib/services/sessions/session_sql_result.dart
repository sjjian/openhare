import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/repositories/sessions/session_sql_result.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_sql_result.g.dart';

@Riverpod(keepAlive: true)
class SQLResultsServices extends _$SQLResultsServices {
  @override
  SQLResultsModel build() {
    return ref.watch(sqlResultsRepoProvider).getSqlResults();
  }

  SQLResultModel? selectedSQLResult(SessionId sessionId) {
    SQLResultRepo repo = ref.read(sqlResultsRepoProvider);
    return repo.selectedSQLResult(sessionId);
  }

  void deleteSQLResult(ResultId resultId) {
    SQLResultRepo repo = ref.read(sqlResultsRepoProvider);
    repo.deleteSQLResult(resultId);
    ref.invalidateSelf();
  }

  void selectSQLResult(ResultId resultId) {
    SQLResultRepo repo = ref.read(sqlResultsRepoProvider);
    repo.selectSQLResult(resultId);
    ref.invalidateSelf();
  }

  void reorderSQLResult(SessionId sessionId, int oldIndex, int newIndex) {
    SQLResultRepo repo = ref.read(sqlResultsRepoProvider);
    repo.reorderSQLResult(sessionId, oldIndex, newIndex);
    ref.invalidateSelf();
  }

  SQLResultModel addSQLResult(SessionId sessionId) {
    SQLResultRepo repo = ref.read(sqlResultsRepoProvider);
    final result = repo.addSQLResult(sessionId);
    ref.invalidateSelf();
    return result;
  }

  Future<void> loadFromQuery(ResultId resultId, String query) async {
    final repo = ref.read(sqlResultsRepoProvider);

    repo.updateSQLResult(
        resultId,
        SQLResultDetailModel(
            resultId: resultId, query: query, state: SQLExecuteState.init));
    ref.invalidateSelf();

    // todo
    final sessionModel = ref
        .read(sessionsServicesProvider.notifier)
        .getSession(resultId.sessionId);

    try {
      DateTime start = DateTime.now();
      final connServices = ref.read(sessionConnsServicesProvider.notifier);
      BaseQueryResult? queryResult =
          await connServices.query(sessionModel!.connId!, query);
      DateTime end = DateTime.now();

      repo.updateSQLResult(
          resultId,
          SQLResultDetailModel(
              resultId: resultId,
              query: query,
              data: queryResult,
              executeTime: end.difference(start),
              state: SQLExecuteState.done));
    } catch (e) {
      repo.updateSQLResult(
          resultId,
          SQLResultDetailModel(
              resultId: resultId,
              query: query,
              state: SQLExecuteState.error,
              error: e.toString()));
    } finally {
      ref.invalidateSelf();
    }
  }

  SQLResultDetailModel? getSQLResult(ResultId resultId) {
    final repo = ref.read(sqlResultsRepoProvider);
    return repo.getSQLResult(resultId);
  }
}
