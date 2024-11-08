import 'package:client/models/instances.dart';
import 'package:client/utils/list_extend.dart';
import 'package:path_provider/path_provider.dart';

import 'package:json_annotation/json_annotation.dart';

import 'dart:io';
import 'dart:convert';

part 'storages.g.dart';

@JsonSerializable(constructor: "_internal")
class Storage {
  @JsonKey(name: "instances")
  List<InstanceModel> instances;

  @JsonKey(name: "active_instances")
  ActiveNameSet activeInstances;

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
      : instances = instances ?? List.empty(growable: true),
        activeInstances = activeInstances ?? ActiveNameSet.empty();

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

  void addInstance(InstanceModel instance) {
    instances.add(instance);
    _save();
  }

  void updateInstance(InstanceModel target) {
    for (int i = 0; i < instances.length; i++) {
      if (instances[i].name == target.name) {
        instances[i] = target;
        break;
      }
    }
    _save();
  }

  void deleteInstance(InstanceModel instance) {
    instances.removeWhere((element) => element.name == instance.name);
    removeActiveInstance(instance);
    _save();
  }

  bool isInstanceExist(String name) {
    for (var instance in instances) {
      if (instance.name == name) {
        return true;
      }
    }
    return false;
  }

  InstanceModel? getInstance(String name) {
    for (var instance in instances) {
      if (instance.name == name) {
        return instance;
      }
    }
    return null;
  }

  //todo: 简化
  List<InstanceModel> searchInstances(String key,
      {int? pageNumber, int? pageSize}) {
    List<InstanceModel> filterList = key.isEmpty
        ? instances
        : instances.where((instance) {
            return instance.name.contains(key) ||
                instance.addr.contains(key) ||
                (instance.desc ?? "").contains(key) ||
                instance.port.toString().contains(key);
          }).toList();

    if (pageNumber == null || pageSize == null) {
      return filterList;
    }
    return filterList.limit(pageSize * (pageNumber - 1), pageSize);
  }

  //todo: 简化
  int instanceCount(String key) {
    return searchInstances(key).length;
  }

  List<InstanceModel> getActiveInstances() {
    return activeInstances
        .toList()
        .where((name) => isInstanceExist(name)) //todo: 降低判断instance存在的复杂度
        .map<InstanceModel>((name) {
      return getInstance(name)!;
    }).toList();
  }

  void addActiveInstance(InstanceModel instance) {
    activeInstances.add(instance.name);
    _save();
  }

  void removeActiveInstance(InstanceModel instance) {
    activeInstances.remove(instance.name);
  }

  void addInstanceActiveSchema(InstanceModel instance, String schema) {
    _save();
    if (instances.contains(instance)) instance.activeSchemas.add(schema);
  }
}
