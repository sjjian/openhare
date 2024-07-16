import 'package:client/models/instances.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class Storage {
  List<InstanceModel>? instances;

  Storage() {
    instances = List<InstanceModel>.empty(growable: true);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/config');
  }

  Future<void> load() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      List<dynamic> jsonList = jsonDecode(contents);
      instances = jsonList.map((json) => InstanceModel.fromJson(json)).toList();
    } catch (e) {
      return;
    }
  }

  Future<void> save() async {
    try {
      final file = await _localFile;
      String jsonString =
          jsonEncode(instances!.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      return;
    }
  }
}
