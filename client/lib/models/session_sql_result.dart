import 'package:client/repositories/session_conn.dart';
import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'session_sql_result.freezed.dart';

@freezed
abstract class SQLResultModel with _$SQLResultModel {
  const factory SQLResultModel({
    required int sessionId,
    required int resultId,
    required SQLExecuteState state,
    String? query,
    Duration? executeTime,
    String? error,
    BaseQueryResult? data,
  }) = _SQLResultModel;
}

@freezed
abstract class SQLResultListModel with _$SQLResultListModel {
  const factory SQLResultListModel({
    required int sessionId,
    required List<SQLResultModel> results,
    SQLResultModel? selected,
  }) = _SQLResultListModel;
}

abstract class SQLResultRepo {
  SQLResultListModel getSqlResults(int sessionId);
  SQLResultModel getSQLReuslt(int sessionId, int resultId);
  void selectSQLResult(int sessionId, int resultId);
  SQLResultModel? selectedSQLResult(int sessionId);
  void reorderSQLResult(int sessionId, int oldIndex, int newIndex);
  SQLResultModel addSQLResult(int sessionId);
  void deleteSQLResult(int sessionId, int resultId);
  void updateSQLResult(int sessionId, int resultId, SQLResultModel result);
}
