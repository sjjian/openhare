import 'package:client/models/instances.dart';
import 'package:client/repositories/instances/instances.dart';
import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'session_conn.freezed.dart';

@freezed
abstract class ConnId with _$ConnId {
  const factory ConnId({
    required int value,
  }) = _ConnId;
}

@freezed
abstract class SessionConnModel with _$SessionConnModel {
  const factory SessionConnModel({
    required ConnId connId,
    required String currentSchema,
    required bool canQuery,
  }) = _SessionConnModel;
}

abstract class SessionConnRepo {
  SessionConnModel getConn(ConnId connId);
  SessionConnModel createConn(InstanceModel model,
      {String? currentSchema});
  void removeConn(ConnId connId);
  Future<void> connect(ConnId connId);
  Future<void> close(ConnId connId);
  Future<void> onSchemaChanged(ConnId connId, String schema);
  Future<void> setCurrentSchema(ConnId connId, String schema);
  Future<List<String>> getSchemas(ConnId connId);
  Future<MetaDataNode> getMetadata(ConnId connId);
  Future<BaseQueryResult?> query(ConnId connId, String query);
}
