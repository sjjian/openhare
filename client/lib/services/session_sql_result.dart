import 'package:client/services/session_conn.dart';
import 'package:client/repositories/session_sql_result.dart';
import 'package:client/models/interface.dart';
import 'package:client/services/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:excel/excel.dart';

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
class SQLResultServices extends _$SQLResultServices {
  @override
  SQLResultModel? build(int sessionId, int resultId) {
    return ref.watch(sqlResultProvider(sessionId, resultId));
  }

  Future<void> loadFromQuery(String query) async {
    SessionConnModel sessionConnModel =
        ref.read(sessionConnServicesProvider(state!.sessionId))!;
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
      state = state!.copyWith(
        result: result,
      );
    }
  }

  Excel toExcel() {
    if (state == null) {
      return Excel.createExcel();
    }
    return state!.result.toExcel();
  }
}

@Riverpod(keepAlive: true)
class SQLResultsServices extends _$SQLResultsServices {
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
    SelectedSessionId? sessionIdModel =
        ref.watch(selectedSessionIdServicesProvider);
    if (sessionIdModel == null) {
      return null;
    }
    return ref.watch(sQLResultsServicesProvider(sessionIdModel.sessionId));
  }
}

@Riverpod(keepAlive: true)
class SelectedSQLResultController extends _$SelectedSQLResultController {
  @override
  SQLResultModel? build() {
    SelectedSessionId? sessionIdModel =
        ref.watch(selectedSessionIdServicesProvider);
    if (sessionIdModel == null) {
      return null;
    }

    int? resultId = ref.watch(
        sQLResultsServicesProvider(sessionIdModel.sessionId)
            .select((model) {
      if (model == null || model.sqlResults.isEmpty) {
        return null; // No results available
      }
      return model.sqlResults.selected()!.id;
    }));
    if (resultId == null) {
      return null; // No selected result
    }
    return ref
        .watch(sQLResultServicesProvider(sessionIdModel.sessionId, resultId));
  }
}
