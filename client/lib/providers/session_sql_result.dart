import 'package:client/models/session_sql_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/utils/reorder_list.dart';

part 'session_sql_result.g.dart';

@Riverpod(keepAlive: true)
class SQLResultController extends _$SQLResultController {
  @override
  SQLResultModel? build() {
    return ref.watch(currentSQLResultProvider);
  }
}

@Riverpod(keepAlive: true)
class SQLResultTabController extends _$SQLResultTabController {
  @override
  ReorderSelectedList<SQLResultModel> build() {
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