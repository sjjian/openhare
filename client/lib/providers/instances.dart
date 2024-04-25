import 'package:client/models/instances.dart';
import 'package:flutter/material.dart';

class InstancesProvider extends ChangeNotifier {
  List<InstanceModel> get instancesModel => instances;

  void addInstance(InstanceModel instance) {
    instancesModel.add(instance);
    notifyListeners();
  }

  void deleteInstance(String name) {
    instances.removeWhere((element) => element.name == name);
    notifyListeners(); // 默认能删除成功
  }

  bool isInstanceExist(String name) {
    for (var instance in instances) {
      if (instance.name == name) {
        return true;
      }
    }
    return false;
  }
}
