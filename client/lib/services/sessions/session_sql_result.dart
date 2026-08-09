import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/repositories/sessions/session_sql_result.dart';
import 'package:client/services/sessions/session_controller.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> _query(ResultId resultId, String query) async {
    final repo = ref.read(sqlResultsRepoProvider);
    // todo: remove sql result controller 不确认全局cache controller 是不是好的设计，导致两处维护状态.
    SQLResultController.removeSQLResultController(resultId);

    final sessionModel = ref.read(sessionsServicesProvider.notifier).getSession(resultId.sessionId);
    final connServices = ref.read(sessionConnsServicesProvider.notifier);
    final ConnId? connId = sessionModel?.connId;
    final bool canKill = connId != null && connServices.supportsKillQuery(connId);

    repo.updateSQLResult(
      resultId,
      SQLResultDetailModel(
        resultId: resultId,
        query: query,
        state: SQLExecuteState.init,
        connId: connId,
        canKill: canKill,
      ),
    );
    ref.invalidateSelf();

    try {
      DateTime start = DateTime.now();
      BaseQueryResult? queryResult = await connServices.query(
        sessionModel!.connId!,
        query,
        limit: sessionModel.config.queryLimit,
      );
      DateTime end = DateTime.now();
      // sleep 100ms, 不然当界面刷新太快时，无法感知结果是没变还是没执行.
      await Future.delayed(const Duration(milliseconds: 100));
      repo.updateSQLResult(
        resultId,
        SQLResultDetailModel(
          resultId: resultId,
          query: query,
          queryId: queryResult?.queryId,
          data: queryResult,
          executeTime: end.difference(start),
          state: SQLExecuteState.done,
          connId: connId,
          canKill: canKill,
        ),
      );
    } on QueryCancelledException {
      repo.updateSQLResult(
        resultId,
        SQLResultDetailModel(
          resultId: resultId,
          query: query,
          state: SQLExecuteState.cancel,
          connId: connId,
          canKill: canKill,
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
          connId: connId,
          canKill: canKill,
        ),
      );
    } finally {
      ref.invalidateSelf();
    }
  }

  Future<void> _explain(ResultId resultId, String query) async {
    final repo = ref.read(sqlResultsRepoProvider);
    SQLResultController.removeSQLResultController(resultId);

    final sessionModel = ref.read(sessionsServicesProvider.notifier).getSession(resultId.sessionId);
    final connServices = ref.read(sessionConnsServicesProvider.notifier);
    final ConnId? connId = sessionModel?.connId;
    final bool canKill = connId != null && connServices.supportsKillQuery(connId);

    repo.updateSQLResult(
      resultId,
      SQLResultDetailModel(
        resultId: resultId,
        query: query,
        state: SQLExecuteState.init,
        connId: connId,
        canKill: canKill,
      ),
    );
    ref.invalidateSelf();

    try {
      DateTime start = DateTime.now();
      BaseQueryResult? queryResult = await connServices.explain(
        sessionModel!.connId!,
        query,
      );
      DateTime end = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 100));
      repo.updateSQLResult(
        resultId,
        SQLResultDetailModel(
          resultId: resultId,
          query: query,
          queryId: queryResult?.queryId,
          data: queryResult,
          executeTime: end.difference(start),
          state: SQLExecuteState.done,
          connId: connId,
          canKill: canKill,
        ),
      );
    } on QueryCancelledException {
      repo.updateSQLResult(
        resultId,
        SQLResultDetailModel(
          resultId: resultId,
          query: query,
          state: SQLExecuteState.cancel,
          connId: connId,
          canKill: canKill,
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
          connId: connId,
          canKill: canKill,
        ),
      );
    } finally {
      ref.invalidateSelf();
    }
  }

  Future<ResultId> queryAddResult(SessionId sessionId, String query) async {
    final resultModel = addSQLResult(sessionId);
    await _query(resultModel.resultId, query);
    return resultModel.resultId;
  }

  Future<ResultId> explainAddResult(SessionId sessionId, String query) async {
    final resultModel = addSQLResult(sessionId);
    await _explain(resultModel.resultId, query);
    return resultModel.resultId;
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
    SessionModel? sessionModel = ref.watch(selectedSessionProvider);
    if (sessionModel == null) {
      return null;
    }
    return ref.watch(
      sQLResultsServicesProvider.select((m) {
        return m.cache[sessionModel.sessionId];
      }),
    );
  }
}

@Riverpod(keepAlive: true)
class SelectedSQLResultNotifier extends _$SelectedSQLResultNotifier {
  @override
  SQLResultDetailModel? build() {
    SessionModel? sessionModel = ref.watch(selectedSessionProvider);
    if (sessionModel == null) {
      return null;
    }
    SQLResultModel? sqlResultModel = ref.watch(
      sQLResultsServicesProvider.select((m) {
        return m.cache[sessionModel.sessionId]?.selected;
      }),
    );
    if (sqlResultModel == null) {
      return null;
    }
    return ref.read(sQLResultsServicesProvider.notifier).getSQLResult(sqlResultModel.resultId);
  }
}
