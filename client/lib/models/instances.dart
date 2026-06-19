import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'instances.freezed.dart';
part 'instances.g.dart';

abstract class InstanceRepo {
  void add(InstanceModel model);
  void update(InstanceModel model);
  void delete(InstanceId id);
  bool isInstanceExist(String name);
  InstanceModel? getInstanceByName(String name);
  InstanceModel? getInstanceById(InstanceId id);
  InstanceListModel isntances(String key, {int? pageNumber, int? pageSize});
  List<InstanceModel> getActiveInstances(int top);
  void addActiveInstance(InstanceId id);
  void addInstanceActiveSchema(InstanceId id, DatabaseRef schema);
  Future<InstanceMetadataModel> getMetadata(InstanceId instanceId);
  Future<void> refreshMetadata(InstanceId instanceId);
}

// instances model

@freezed
abstract class InstanceId with _$InstanceId {
  const factory InstanceId({
    required int value,
  }) = _InstanceId;

  factory InstanceId.fromJson(Map<String, dynamic> json) => _$InstanceIdFromJson(json);
}

@freezed
abstract class InstanceModel with _$InstanceModel {
  const factory InstanceModel({
    required InstanceId id,
    required DatabaseType dbType,
    required String name,
    required ConnectTarget target,
    SshTunnelConfig? sshTunnel,
    required String user,
    required String password,
    required String desc,
    required Map<String, String> custom,
    required List<String> initQuerys,
    required List<DatabaseRef> activeSchemas,
    required DateTime createdAt,
    required DateTime latestOpenAt,
  }) = _InstanceModel;

  const InstanceModel._();

  ConnectValue get connectValue {
    return ConnectValue(
      name: name,
      target: target,
      user: user,
      password: password,
      desc: desc,
      custom: custom,
      initQuerys: initQuerys,
      sshTunnel: sshTunnel,
    );
  }
}

@freezed
abstract class InstanceListModel with _$InstanceListModel {
  const factory InstanceListModel({
    required List<InstanceModel> instances,
    required int count,
    required int filteredCount,
  }) = _InstanceListModel;
}

@freezed
abstract class PaginationInstanceListModel with _$PaginationInstanceListModel {
  const factory PaginationInstanceListModel({
    required InstanceListModel instances,
    required int currentPage,
    required int pageSize,
    required String key,
  }) = _PaginationInstanceListModel;
}

// instances metadata model
@freezed
abstract class InstanceMetadataModel with _$InstanceMetadataModel {
  const factory InstanceMetadataModel({
    required String version,
    required DatabaseModeType databaseMode,
    required List<DatabaseRef> schemas,
    required List<MetaDataNode> metadata,
  }) = _InstanceMetadataModel;
}
