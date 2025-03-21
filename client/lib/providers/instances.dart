import 'package:client/storages/storages.dart';
import 'package:client/models/instances.dart';
import 'package:flutter/material.dart';
import 'package:db_driver/db_driver.dart';

class InstancesProvider extends ChangeNotifier {
  InstancesProvider();
  
  Future<void> loadInstance() async {
    await Storage.load();
    await ConnectionFactory.init();
    notifyListeners();
  }

  void addInstance(InstanceModel instance) {
    Storage st = Storage();
    st.addInstance(instance);
    notifyListeners();
  }

  void updateInstance(InstanceModel instance){
    Storage st = Storage();
    if (instance.port == 5432) {
      instance.type = "pg";
      instance.databases = "postgres";
    }
    st.updateInstance(instance);
    notifyListeners();
  }

  void deleteInstance(InstanceModel instance) {
    Storage st = Storage();
    st.deleteInstance(instance);
    notifyListeners(); // 默认能删除成功
  }

  bool isInstanceExist(String name) {
    Storage st = Storage();
    return st.isInstanceExist(name);
  }

  List<InstanceModel> instances(String key, int pageSize, int pageNumber) {
    Storage st = Storage();
    return st.searchInstances(key, pageNumber: pageNumber, pageSize: pageSize);
  }

  int instanceCount(String key) {
    Storage st = Storage();
    return st.instanceCount(key);
  }

  List<InstanceModel> activeInstances() {
    Storage st = Storage();
    return st.getActiveInstances();
  }
}
