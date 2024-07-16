import 'package:client/core/storages/instances.dart';
import 'package:client/models/instances.dart';
import 'package:flutter/material.dart';

class InstancesProvider extends ChangeNotifier {
  Storage st;

  InstancesProvider(this.st);

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
