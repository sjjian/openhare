import 'package:client/repositories/session_sql_result.dart';
import 'package:client/models/interface.dart';
import 'package:client/providers/sessions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/utils/reorder_list.dart';

part 'session_sql_result.g.dart';

@Riverpod(keepAlive: true)
ReorderSelectedList<SQLResult> currentSQLResults(Ref ref) {
   SelectedSessionId? sessionIdModel = ref.watch(selectedSessionIdControllerProvider);
  if (sessionIdModel == null) {
    return ReorderSelectedList();
  }
  SQLResultRepo sqlResults = ref.watch(sqlResultsRepoProvider);
  return sqlResults.sessionSqlResults(sessionIdModel.sessionId);
}


@Riverpod(keepAlive: true)
SQLResult? currentSQLResult(Ref ref) {
  SelectedSessionId? sessionIdModel = ref.watch(selectedSessionIdControllerProvider);
  if (sessionIdModel == null) {
    return null;
  }
  SQLResultRepo sqlResults = ref.watch(sqlResultsRepoProvider);
  return sqlResults.current(sessionIdModel.sessionId);
}


@Riverpod(keepAlive: true)
class SQLResultController extends _$SQLResultController {
  @override
  SQLResult? build() {
    return ref.watch(currentSQLResultProvider);
  }
}

@Riverpod(keepAlive: true)
class SQLResultTabController extends _$SQLResultTabController {
  @override
  ReorderSelectedList<SQLResult> build() {
    return ref.watch(currentSQLResultsProvider);
  }

  void deleteSQLResultByIndex(int index) {
    state = state..removeAt(index);
  }

  void selectSQLResultByIndex(int index) {
    state = state..select(index);
  }

  void reorderSQLResult(int oldIndex, int newIndex) {
    state = state..reorder(oldIndex, newIndex);
  }
}