import 'package:client/models/instances.dart';
import 'package:path_provider/path_provider.dart';

import 'package:json_annotation/json_annotation.dart';

import 'dart:io';
import 'dart:convert';

part 'storages.g.dart';

@JsonSerializable(constructor: "_internal")
class Storage {
  @JsonKey(name: "instances")
  List<InstanceModel> _instances;

  @JsonKey(name: "active_instances")
  ActiveNameSet _activeInstances;

  static Storage? _storage;

  factory Storage() {
    if (_storage == null) {
      return Storage._internal();
    } else {
      return _storage!;
    }
  }

  Storage._internal(
      {List<InstanceModel>? instances, ActiveNameSet? activeInstances})
      : _instances = instances ?? List.empty(growable: true),
        _activeInstances = activeInstances ?? ActiveNameSet.empty();

  // json interface impl
  factory Storage.fromJson(Map<String, dynamic> json) {
    _storage ??= _$StorageFromJson(json);
    return _storage!;
  }

  // json interface impl
  Map<String, dynamic> toJson() => _$StorageToJson(this);

  // 类的实际初始化方法, 从配置文件加载
  static Future<Storage> load() async {
    final file = await _localFile;
    final contents = await file.readAsString();
    return Storage.fromJson(jsonDecode(contents));
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/config');
  }

  // todo: 批量/定时, 保存？
  Future<void> _save() async {
    try {
      final file = await _localFile;
      await file.writeAsString(jsonEncode(toJson()));
    } catch (e) {
      return;
    }
  }

  List<InstanceModel> get instances => _instances;
  ActiveNameSet get activeInstances => _activeInstances;

  void addInstance(InstanceModel instance) {
    _instances.add(instance);
    _save();
  }

  void deleteInstance(InstanceModel instance) {
    _instances.removeWhere((element) => element.name == instance.name);
    _save();
  }

  bool isInstanceExist(String name) {
    for (var instance in _instances) {
      if (instance.name == name) {
        return true;
      }
    }
    return false;
  }

  void addActiveInstance(InstanceModel instance) {
    _activeInstances.add(instance.name);
    _save();
  }

  void addInstanceActiveSchema(InstanceModel instance, String schema) {
    print("instance: ${instance.name}; schema: $schema");
    _save();
    if (_instances.contains(instance)) instance.activeSchemas.add(schema);
  }
}
