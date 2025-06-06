import 'package:client/repositories/instances.dart';
import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'session_conn.freezed.dart';

@freezed
abstract class SessionConnModel with _$SessionConnModel {
  const factory SessionConnModel({
    required int sessionId,
    required String currentSchema,
    required bool canQuery,
  }) = _SessionConnModel;
}

abstract class SessionConnRepo {
  SessionConnModel getSessionConn(int sessionId);
  SessionConnModel createConn(int sessionId, InstanceModel model,
      {String? currentSchema});
  void removeConn(int sessionId);
  Future<void> connect(int sessionId);
  Future<void> close(int sessionId);
  Future<void> onSchemaChanged(int sessionId, String schema);
  Future<void> setCurrentSchema(int sessionId, String schema);
  Future<List<String>> getSchemas(int sessionId);
  Future<BaseQueryResult?> query(int sessionId, String query);
}
