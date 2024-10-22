import 'package:client/models/instances.dart';
import 'package:path_provider/path_provider.dart';

import 'package:json_annotation/json_annotation.dart';

import 'dart:io';
import 'dart:convert';

part 'storages.g.dart';

@JsonSerializable()
class Storage {
  @JsonKey(name: "instances")
  List<InstanceModel>? instances;

  @JsonKey(name: "latest_instances")
  List<String>? latestInstances;

  Storage({this.instances, this.latestInstances});

  Storage.init() {
    instances = List.empty();
    latestInstances = List.empty();
  }

  // json
  factory Storage.fromJson(Map<String, dynamic> json) =>
      _$StorageFromJson(json);

  // json
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

  Future<void> save() async {
    try {
      final file = await _localFile;
      await file.writeAsString(toJson().toString());
    } catch (e) {
      return;
    }
  }
}