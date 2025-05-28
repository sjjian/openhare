import 'package:client/providers/session_conn.dart';
import 'package:client/repositories/session_sql_result.dart';
import 'package:client/models/interface.dart';
import 'package:client/providers/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/utils/reorder_list.dart';

part 'session_sql_result.g.dart';

@Riverpod(keepAlive: true)
SQLResultsModel? sqlResults(Ref ref, int sessionId) {
  SQLResultRepo sqlResults = ref.watch(sqlResultsRepoProvider);
  ReorderSelectedList<SQLResult> results =
      sqlResults.sessionSqlResults(sessionId);
  return SQLResultsModel(sessionId: sessionId, sqlResults: results);
}

@Riverpod(keepAlive: true)
SQLResultModel? sqlResult(Ref ref, int sessionId, int resultId) {
  SQLResultRepo sqlResults = ref.watch(sqlResultsRepoProvider);
  return SQLResultModel(
      sessionId: sessionId, result: sqlResults.getReuslt(sessionId, resultId));
}

@Riverpod(keepAlive: true)
class SQLResultController extends _$SQLResultController {
  @override
  SQLResultModel? build(int sessionId, int resultId) {
    return ref.watch(sqlResultProvider(sessionId, resultId));
  }

  Future<void> loadFromQuery(String query) async {
    SessionConnModel sessionConnModel =
        ref.read(sessionConnControllerProvider(state!.sessionId))!;
    state!.result.query = query;
    SQLResult result = state!.result;
    try {
      DateTime start = DateTime.now();
      BaseQueryResult? queryResult = await sessionConnModel.conn.query(query);
      DateTime end = DateTime.now();
      SQLResult result = state!.result;
      result.setDone(queryResult!, end.difference(start));
    } catch (e) {
      result.setError(e.toString());
    } finally {
      state =state!.copyWith(
        result: result,
      );
    }
  }
}

@Riverpod(keepAlive: true)
class SQLResultTabController extends _$SQLResultTabController {
  @override
  SQLResultsModel? build(int sessionId) {
    return ref.watch(sqlResultsProvider(sessionId));
  }

  void deleteSQLResultByIndex(int index) {
    if (state == null) {
      return;
    }
    SQLResultRepo sqlResults = ref.read(sqlResultsRepoProvider);
    sqlResults.remove(state!.sessionId, index);
    state = null; // Clear the state to avoid stale data
    ref.invalidate(sqlResultsProvider(state!.sessionId));
    state = state!.copyWith(
      sqlResults: state!.sqlResults,
      sessionId: state!.sessionId,
    );
  }

  void selectSQLResultByIndex(int index) {
    if (state == null) {
      return;
    }
    SQLResultRepo sqlResults = ref.read(sqlResultsRepoProvider);
    sqlResults.select(state!.sessionId, index);
        state = state!.copyWith(
      sqlResults: state!.sqlResults,
      sessionId: state!.sessionId,
    );
  }

  void reorderSQLResult(int oldIndex, int newIndex) {
    if (state == null) {
      return;
    }
    SQLResultRepo sqlResults = ref.read(sqlResultsRepoProvider);
    sqlResults.reorder(state!.sessionId, oldIndex, newIndex);
    state = state!.copyWith(
      sqlResults: state!.sqlResults,
      sessionId: state!.sessionId,
    );
  }

  SQLResult? addSQLResult() {
    if (state == null) {
      return null;
    }
    SQLResultRepo sqlResults = ref.read(sqlResultsRepoProvider);
    sqlResults.newSQLResult(state!.sessionId);
    state = state!.copyWith(
      sqlResults: state!.sqlResults,
      sessionId: state!.sessionId,
    );
    return sqlResults.selected(state!.sessionId);
  }
}

@Riverpod(keepAlive: true)
class SelectedSQLResultTabController extends _$SelectedSQLResultTabController {
  @override
  SQLResultsModel? build() {
    SelectedSessionId sessionIdModel =
        ref.watch(selectedSessionIdControllerProvider)!;
    return ref.watch(sQLResultTabControllerProvider(sessionIdModel.sessionId));
  }
}

@Riverpod(keepAlive: true)
class SelectedSQLResultController extends _$SelectedSQLResultController {
  @override
  SQLResultModel? build() {
    SelectedSessionId sessionIdModel =
        ref.watch(selectedSessionIdControllerProvider)!;
    
    int? resultId =
        ref.watch(sQLResultTabControllerProvider(sessionIdModel.sessionId).select((model) {
      if (model == null || model.sqlResults.isEmpty) {
        return null; // No results available
      }
      return model.sqlResults.selected()!.id;
    }));
    if (resultId == null) {
      return null; // No selected result
    }
    return ref.watch(sQLResultControllerProvider(sessionIdModel.sessionId, resultId));
  }
}
