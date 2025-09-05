import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/repositories/sessions/session_sql_result.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:excel/excel.dart' as excel;

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

  Future<void> _query(ResultId resultId, String query) async {
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
          state: SQLExecuteState.done,
        ),
      );
    } catch (e) {
      repo.updateSQLResult(
        resultId,
        SQLResultDetailModel(
          resultId: resultId,
          query: query,
          state: SQLExecuteState.error,
          error: e.toString(),
        ),
      );
    } finally {
      // sleep 100ms, 不然当界面刷新太快时，无法感知结果是没变还是没执行.
      await Future.delayed(const Duration(milliseconds: 100));
      ref.invalidateSelf();
    }
  }

  Future<void> queryAddResult(SessionId sessionId, String query) async {
    final resultModel = addSQLResult(sessionId);
    _query(resultModel.resultId, query);
  }

  Future<void> query(SessionId sessionId, String query) async {
    SQLResultModel? resultModel = selectedSQLResult(sessionId);
    resultModel ??= addSQLResult(sessionId);
    _query(resultModel.resultId, query);
  }

  SQLResultDetailModel? getSQLResult(ResultId resultId) {
    final repo = ref.read(sqlResultsRepoProvider);
    return repo.getSQLResult(resultId);
  }
}


@Riverpod(keepAlive: true)
class SelectedSQLResultTabNotifier extends _$SelectedSQLResultTabNotifier {
  @override
  SessionSQLResultsModel? build() {
    SessionModel? sessionModel = ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null) {
      return null;
    }
    return ref.watch(sQLResultsServicesProvider.select((m) {
      return m.cache[sessionModel.sessionId];
    }));
  }
}

@Riverpod(keepAlive: true)
class SelectedSQLResultNotifier extends _$SelectedSQLResultNotifier {
  @override
  SQLResultDetailModel? build() {
    SessionModel? sessionModel = ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null) {
      return null;
    }
    SQLResultModel? sqlResultModel =
        ref.watch(sQLResultsServicesProvider.select((m) {
      return m.cache[sessionModel.sessionId]?.selected;
    }));
    if (sqlResultModel == null) {
      return null;
    }
    return ref
        .read(sQLResultsServicesProvider.notifier)
        .getSQLResult(sqlResultModel.resultId);
  }

  excel.Excel toExcel() {
    final data = excel.Excel.createExcel();
    final sheet = data["Sheet1"];
    sheet.appendRow(state!.data!.columns
        .map<excel.TextCellValue>((e) => excel.TextCellValue(e.name))
        .toList());
    for (final row in state!.data!.rows) {
      sheet.appendRow(row.values
          .map<excel.TextCellValue>(
              (e) => excel.TextCellValue(e.getString() ?? ''))
          .toList());
    }
    return data;
  }
}