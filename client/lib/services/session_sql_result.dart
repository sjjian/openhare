import 'package:client/models/session_sql_result.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/session_conn.dart';
import 'package:client/services/session_conn.dart';
import 'package:client/repositories/session_sql_result.dart';
import 'package:client/services/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:excel/excel.dart';

part 'session_sql_result.g.dart';

@Riverpod()
class SQLResultServices extends _$SQLResultServices {
  @override
  SQLResultModel build(ResultId resultId) {
    return ref.watch(sqlResultsRepoProvider).getSQLReuslt(resultId);
  }

  Future<void> loadFromQuery(String query) async {
    final repo = ref.read(sqlResultsRepoProvider);

    repo.updateSQLResult(resultId, state.copyWith(query: query));
    ref.invalidateSelf();

    // todo
    final sessionModel = ref
        .read(sessionsServicesProvider.notifier)
        .getSession(state.resultId.sessionId);

    try {
      DateTime start = DateTime.now();
      BaseQueryResult? queryResult = await ref
          .read(sessionConnServicesProvider(sessionModel!.connId!).notifier)
          .query(query);
      DateTime end = DateTime.now();
      repo.updateSQLResult(
          resultId,
          state.copyWith(
              data: queryResult,
              executeTime: end.difference(start),
              state: SQLExecuteState.done));
    } catch (e) {
      repo.updateSQLResult(resultId,
          state.copyWith(state: SQLExecuteState.error, error: e.toString()));
    } finally {
      ref.invalidateSelf();
    }
  }

  Excel toExcel() {
    Excel excel = Excel.createExcel();
    Sheet sheet = excel["Sheet1"];
    sheet.appendRow(state.data!.columns
        .map<TextCellValue>((e) => TextCellValue(e.name))
        .toList());
    for (final row in state.data!.rows) {
      sheet.appendRow(row.values
          .map<TextCellValue>((e) => TextCellValue(e.getString() ?? ''))
          .toList());
    }
    return excel;
  }
}

@Riverpod()
class SQLResultsServices extends _$SQLResultsServices {
  @override
  SQLResultListModel build(SessionId sessionId) {
    return ref.watch(sqlResultsRepoProvider).getSqlResults(sessionId);
  }

  SQLResultModel? selectedSQLResult() {
    SQLResultRepo repo = ref.read(sqlResultsRepoProvider);
    return repo.selectedSQLResult(state.sessionId);
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
