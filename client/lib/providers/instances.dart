import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:client/storages/storages.dart';
import 'package:client/models/instances.dart';
import 'package:db_driver/db_driver.dart';

class InstancesProvider extends ChangeNotifier {
  String page = "instances";
  InstanceModel? willUpdatedInstance;

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

  void updateInstance(InstanceModel instance) {
    Storage st = Storage();
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

  void goPage(String page) {
    this.page = page;
    notifyListeners();
  }

  void tryUpdateInstance(InstanceModel instance) {
    page = "update_instance";
    willUpdatedInstance = instance;
    notifyListeners();
  }
}

class FormValidState {
  GlobalKey<FormFieldState> state = GlobalKey<FormFieldState>();
  bool isValid = true;
}

class AddInstanceProvider extends ChangeNotifier {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController addrCtrl = TextEditingController();
  final TextEditingController portCtrl = TextEditingController();
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final Map<CustomMeta, TextEditingController> customCtrl = {};

  final formKey = GlobalKey<FormState>();
  final Map<CustomMeta, FormValidState> states = {};

  DatabaseType selectedDatabaseType = DatabaseType.mysql;

  int _selectedGroup = 0;

  AddInstanceProvider() {
    for (var connMeta in connectionMetas) {
      for (var meta in connMeta.connMeta) {
        if (meta is CustomMeta) {
          customCtrl[meta] = TextEditingController(text: meta.defaultValue);
          states[meta] = FormValidState();
        }
      }
    }
    portCtrl.text = defaultPort;
  }

  void onDatabaseTypeChange(DatabaseType type) {
    final isPortDefault = (portCtrl.text == defaultPort);
    selectedDatabaseType = type;
    _selectedGroup = 0;
    // 数据库切换则port 默认值要切换，除非用户自己编辑了特殊端口
    if (isPortDefault) {
      portCtrl.text = defaultPort;
    }
    notifyListeners();
  }

  void clear() {
    nameCtrl.clear();
    descCtrl.clear();
    addrCtrl.clear();
    userCtrl.clear();
    passwordCtrl.clear();
    for (var connMeta in connectionMetas) {
      for (var meta in connMeta.connMeta) {
        if (meta is CustomMeta) {
          customCtrl[meta]!.clear();
          customCtrl[meta]!.text = meta.defaultValue ?? "";
        }
      }
    }
    portCtrl.text = defaultPort;
  }

  String get defaultPort {
    for (var connMeta in connectionMetaMap[selectedDatabaseType]!.connMeta) {
      if (connMeta is AddressMeta) {
        return connMeta.defaultPort;
      }
    }
    return "";
  }

  bool isGroupValid(String group) {
    for (var connMeta in connectionMetaMap[selectedDatabaseType]!.connMeta) {
      if (connMeta.group == group) {
        if (states[connMeta]!.isValid == false) {
          return false;
        }
      }
    }
    return true;
  }

  bool validate() {
    var isValid = true;
    for (var connMeta in connectionMetaMap[selectedDatabaseType]!.connMeta) {
      if (connMeta is CustomMeta) {
        if (!states[connMeta]!.state.currentState!.validate()) {
          isValid = false;
        }
      }
    }
    if (!formKey.currentState!.validate()) {
      isValid = false;
    }
    return isValid;
  }

  void updateValidState(CustomMeta meta, bool isValid) {
    if (states[meta]!.isValid == isValid) {
      return;
    }
    states[meta]!.isValid = isValid;
    notifyListeners();
  }

  List<String> get customSettingGroup {
    final connMeta = connectionMetaMap[selectedDatabaseType]?.connMeta;
    if (connMeta == null) {
      return [];
    }
    return connMeta
        .groupFoldBy<String, List<String>>(
          (meta) => meta.group,
          (previous, meta) => (previous ?? [])..add(meta.group),
        )
        .keys
        .whereNot((e) => e == "base")
        .toList();
  }

  int get selectedGroup {
    if (customSettingGroup.isEmpty) {
      return 0;
    }
    return _selectedGroup;
  }

  void onGroupChange(int group) {
    _selectedGroup = group;
    notifyListeners();
  }

  List<SettingMeta> getSettingMeta(String group) {
    final connMeta = connectionMetaMap[selectedDatabaseType]?.connMeta;
    if (connMeta == null) {
      return [];
    }
    return connMeta
        .groupListsBy((meta) => meta.group)
        .entries
        .where((entry) => entry.key == group)
        .expand((entry) => entry.value)
        .toList();
  }

  ConnectValue getConnectValue() {
    final name = nameCtrl.text;
    final addr = addrCtrl.text;
    final port = int.tryParse(portCtrl.text);
    final user = userCtrl.text;
    final password = passwordCtrl.text;
    final desc = descCtrl.text;

    final custom = {
      for (final meta in connectionMetaMap[selectedDatabaseType]!.connMeta)
        if (meta is CustomMeta) meta.name: customCtrl[meta]!.text
    };

    return ConnectValue(
      name: name,
      host: addr,
      port: port,
      user: user,
      password: password,
      desc: desc,
      custom: custom,
    );
  }
}

class UpdateInstanceProvider extends AddInstanceProvider {
  InstanceModel? instance;
  
  @override
  DatabaseType get selectedDatabaseType => instance?.dbType ?? DatabaseType.mysql;

  @override
  void onDatabaseTypeChange(DatabaseType type) {
    return;
  }

  UpdateInstanceProvider():super();

  void loadFromMeta(ConnectValue connectValue) {
    nameCtrl.text = connectValue.name;
    descCtrl.text = connectValue.desc;
    addrCtrl.text = connectValue.host;
    portCtrl.text = connectValue.port.toString();
    userCtrl.text = connectValue.user;
    passwordCtrl.text = connectValue.password;

    for (final meta in customCtrl.keys) {
      customCtrl[meta]!.text = connectValue.getValue(meta.name);
    }
  }

  void tryUpdateInstance(InstanceModel instance) {
    this.instance = instance;
    loadFromMeta(instance.connectValue);
    notifyListeners();
  }
}