import 'package:client/models/sessions.dart';
import 'package:client/repositories/session_conn.dart';
import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'session_sql_result.freezed.dart';

@freezed
abstract class ResultId with _$ResultId {
  const factory ResultId({
    required SessionId sessionId,
    required int value,
  }) = _ResultId;
}

@freezed
abstract class SQLResultModel with _$SQLResultModel {
  const factory SQLResultModel({
    required ResultId resultId,
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
    required SessionId sessionId,
    required List<SQLResultModel> results,
    SQLResultModel? selected,
  }) = _SQLResultListModel;
}

abstract class SQLResultRepo {
  SQLResultListModel getSqlResults(SessionId sessionId);
  void deleteSQLResults(SessionId sessionId);
  SQLResultModel getSQLReuslt(ResultId resultId);
  void selectSQLResult(ResultId resultId);
  SQLResultModel? selectedSQLResult(SessionId sessionId);
  void reorderSQLResult(SessionId sessionId, int oldIndex, int newIndex);
  SQLResultModel addSQLResult(SessionId sessionId);
  void deleteSQLResult(ResultId resultId);
  void updateSQLResult(ResultId resultId, SQLResultModel result);
}
