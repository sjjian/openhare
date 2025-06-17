import 'package:client/repositories/instances.dart';
import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'session_conn.freezed.dart';

@freezed
abstract class SessionConnModel with _$SessionConnModel {
  const factory SessionConnModel({
    required int connId,
    required String currentSchema,
    required bool canQuery,
  }) = _SessionConnModel;
}

abstract class SessionConnRepo {
  SessionConnModel getConn(int connId);
  SessionConnModel createConn(InstanceModel model,
      {String? currentSchema});
  void removeConn(int connId);
  Future<void> connect(int connId);
  Future<void> close(int connId);
  Future<void> onSchemaChanged(int connId, String schema);
  Future<void> setCurrentSchema(int connId, String schema);
  Future<List<String>> getSchemas(int connId);
  Future<MetaDataNode> getMetadata(int connId);
  Future<BaseQueryResult?> query(int connId, String query);
}
