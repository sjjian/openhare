import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'instances.freezed.dart';

abstract class InstanceRepo {
  Future<void> add(InstanceModel model);
  Future<void> update(InstanceModel model);
  Future<void> delete(InstanceId id);
  bool isInstanceExist(String name);
  InstanceModel? getInstanceByName(String name);
  InstanceModel? getInstanceById(InstanceId id);
  List<InstanceModel> search(String key, {int? pageNumber, int? pageSize});
  int count(String key);
  List<InstanceModel> getActiveInstances(int top);
  Future<void> addActiveInstance(InstanceId id);
  Future<void> addInstanceActiveSchema(InstanceId id, String schema);
}

abstract class InstanceMetadataRepo {
  InstanceMetadataModel getMetadata(InstanceId instanceId);
  void updateMetadata(InstanceId instanceId, MetaDataNode metadata);
  void addMetadata(InstanceId instanceId, MetaDataNode metadata);
}

// instances model

@freezed
abstract class InstanceId with _$InstanceId {
  const factory InstanceId({
    required int value,
  }) = _InstanceId;
}

@freezed
abstract class InstanceModel with _$InstanceModel {
  const factory InstanceModel({
    required InstanceId id,
    required DatabaseType dbType,
    required String name,
    required String host,
    int? port,
    required String user,
    required String password,
    required String desc,
    required Map<String, String> custom,
    required List<String> initQuerys,
    required List<String> activeSchemas,
    required DateTime createdAt,
    DateTime? latestOpenAt,
  }) = _InstanceModel;

  const InstanceModel._();

  ConnectValue get connectValue => ConnectValue(
      name: name,
      host: host,
      port: port,
      user: user,
      password: password,
      desc: desc,
      custom: custom,
      initQuerys: initQuerys);
}

@freezed
abstract class PaginationInstanceListModel with _$PaginationInstanceListModel {
  const factory PaginationInstanceListModel({
    required List<InstanceModel> instances,
    required int currentPage,
    required int pageSize,
    required int count,
    required String key,
  }) = _PaginationInstanceListModel;
}

// instances metadata model

@freezed
abstract class InstanceMetadataModel with _$InstanceMetadataModel {
  const factory InstanceMetadataModel({
    required InstanceId instanceId,
    MetaDataNode? metadata,
  }) = _InstanceMetadataModel;
}
