import 'package:client/core/storages/storages.dart';
import 'package:client/models/instances.dart';
import 'package:flutter/material.dart';

class InstancesProvider extends ChangeNotifier {
  late Storage st = Storage.init();

  InstancesProvider();

  Future<void> loadInstance() async {
    st = await Storage.load();
    notifyListeners();
  }

  void addInstance(InstanceModel instance) {
    st.instances?.add(instance);
    st.save();
    notifyListeners();
  }

  void deleteInstance(String name) {
    st.instances?.removeWhere((element) => element.name == name);
    st.save();
    notifyListeners(); // 默认能删除成功
  }

  bool isInstanceExist(String name) {
    for (var instance in st.instances!) {
      if (instance.name == name) {
        return true;
      }
    }
    return false;
  }
}
