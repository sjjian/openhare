import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/storages/storages.dart';
import 'package:client/models/instances.dart';
import 'package:db_driver/db_driver.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:sql_parser/parser.dart';
import 'package:client/utils/sql_highlight.dart';

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

class FormInfo {
  DatabaseType dbType;
  final SettingMeta meta;
  TextEditingController ctrl;
  GlobalKey<FormFieldState> state = GlobalKey<FormFieldState>();
  bool isValid = true;

  FormInfo(this.dbType, this.meta)
      : ctrl = TextEditingController(text: meta.defaultValue);
}

class AddInstanceProvider extends ChangeNotifier {
  final Map<DatabaseType, Map<String, FormInfo>> infos = {};

  final CodeLineEditingController code = CodeLineEditingController(
      spanBuilder: ({required codeLines, required context, required style}) {
    return TextSpan(
        children: Lexer(codeLines.asString(TextLineBreak.lf))
            .tokens()
            .map<TextSpan>((tok) => TextSpan(
                text: tok.content,
                style: style.merge(getStyle(tok.id) ?? style)))
            .toList());
  });

  DatabaseType selectedDatabaseType = DatabaseType.mysql;
  String? _selectedGroup;

  bool? isDatabaseConnectable;
  bool isDatabasePingDoing = false;
  String? databaseConnectError;

  AddInstanceProvider() {
    for (var connMeta in connectionMetas) {
      final dbInfos = infos.putIfAbsent(connMeta.type, () => {});
      for (var meta in connMeta.connMeta) {
        dbInfos[meta.name] = FormInfo(connMeta.type, meta);
      }
    }
    code.text = connectionMetaMap[selectedDatabaseType]!.initQueryText();
  }

  void onDatabaseTypeChange(DatabaseType type) {
    final isPortChanged =
        (infos[selectedDatabaseType]![settingMetaNamePort]!.ctrl.text !=
            defaultPort);
    final name = infos[selectedDatabaseType]![settingMetaNameName]!.ctrl.text;
    final desc = infos[selectedDatabaseType]![settingMetaNameDesc]!.ctrl.text;
    final addr = infos[selectedDatabaseType]![settingMetaNameAddr]!.ctrl.text;
    final user = infos[selectedDatabaseType]![settingMetaNameUser]!.ctrl.text;
    final password =
        infos[selectedDatabaseType]![settingMetaNamePassword]!.ctrl.text;

    selectedDatabaseType = type;
    _selectedGroup = null;

    infos[type]![settingMetaNameName]!.ctrl.text = name;
    infos[type]![settingMetaNameDesc]!.ctrl.text = desc;
    infos[type]![settingMetaNameAddr]!.ctrl.text = addr;
    infos[type]![settingMetaNameUser]!.ctrl.text = user;
    infos[type]![settingMetaNamePassword]!.ctrl.text = password;
    // 数据库切换则port 默认值要切换，除非用户自己编辑了特殊端口
    if (!isPortChanged) {
      port = defaultPort;
    }
    code.text = connectionMetaMap[selectedDatabaseType]!.initQueryText();
    notifyListeners();
  }

  void clear() {
    for (final dbInfos in infos.values) {
      for (final info in dbInfos.values) {
        info.ctrl.text = info.meta.defaultValue ?? "";
      }
    }
  }

  Map<String, FormInfo> get dbInfos {
    return infos[selectedDatabaseType]!;
  }

  String get defaultPort {
    return infos[selectedDatabaseType]![settingMetaNamePort]!
            .meta
            .defaultValue ??
        "";
  }

  set port(String port) {
    infos[selectedDatabaseType]![settingMetaNamePort]!.ctrl.text = port;
  }

  bool isGroupValid(String group) {
    for (final info in infos[selectedDatabaseType]!.values) {
      if (info.dbType == selectedDatabaseType && info.meta.group == group) {
        if (!info.isValid) {
          return false;
        }
      }
    }
    return true;
  }

  bool validate() {
    var isValid = true;
    for (final info in infos[selectedDatabaseType]!.values) {
      if (info.dbType == selectedDatabaseType) {
        if (!info.state.currentState!.validate()) {
          isValid = false;
        }
      }
    }
    return isValid;
  }

  void updateValidState(FormInfo info, bool isValid) {
    if (info.isValid == isValid) {
      return;
    }
    info.isValid = isValid;
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
        .whereNot((e) => e == settingMetaGroupBase)
        .toList();
  }

  String? get selectedGroup {
    return _selectedGroup;
  }

  void onGroupChange(String group) {
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
    String name = "";
    String addr = "";
    int? port = 0;
    String user = "";
    String password = "";
    String desc = "";
    Map<String, String> custom = {};

    for (final info in infos[selectedDatabaseType]!.values) {
      switch (info.meta) {
        case NameMeta():
          name = info.ctrl.text;
        case AddressMeta():
          addr = info.ctrl.text;
        case PortMeta():
          port = int.tryParse(info.ctrl.text);
        case UserMeta():
          user = info.ctrl.text;
        case PasswordMeta():
          password = info.ctrl.text;
        case DescMeta():
          desc = info.ctrl.text;
        case CustomMeta():
          custom[(info.meta as CustomMeta).name] = info.ctrl.text;
      }
    }
    List<String> querys = Splitter(code.text.trim(), ";")
        .split()
        .map((e) => e.content.trim())
        .whereNot((e) => e.trim() == "")
        .toList();
    return ConnectValue(
      name: name,
      host: addr,
      port: port,
      user: user,
      password: password,
      desc: desc,
      custom: custom,
      initQuerys: querys,
    );
  }

  void onSubmit(BuildContext context) {
    context.read<InstancesProvider>().addInstance(InstanceModel(
        dbType: selectedDatabaseType, connectValue: getConnectValue()));
  }

  Future<void> databasePing() async {
    final connectValue = getConnectValue();
    BaseConnection? conn;
    try {
      isDatabasePingDoing = true;
      notifyListeners();
      conn = await ConnectionFactory.open(
          type: selectedDatabaseType, meta: connectValue);
      isDatabaseConnectable = true;
      databaseConnectError = null;
      conn.close();
    } catch (e) {
      isDatabaseConnectable = false;
      databaseConnectError = e.toString();
    } finally {
      isDatabasePingDoing = false;
      notifyListeners();
    }
  }
}

class UpdateInstanceProvider extends AddInstanceProvider {
  InstanceModel? instance;

  @override
  DatabaseType get selectedDatabaseType =>
      instance?.dbType ?? DatabaseType.mysql;

  @override
  void onDatabaseTypeChange(DatabaseType type) {
    return;
  }

  UpdateInstanceProvider() : super();

  void loadFromMeta(ConnectValue connectValue) {
    for (final info in infos[selectedDatabaseType]!.values) {
      if (info.dbType == selectedDatabaseType) {
        switch (info.meta) {
          case NameMeta():
            info.ctrl.text = connectValue.name;
          case AddressMeta():
            info.ctrl.text = connectValue.host;
          case PortMeta():
            info.ctrl.text = connectValue.port.toString();
          case UserMeta():
            info.ctrl.text = connectValue.user;
          case PasswordMeta():
            info.ctrl.text = connectValue.password;
          case DescMeta():
            info.ctrl.text = connectValue.desc;
          case CustomMeta():
            info.ctrl.text = connectValue.getValue(info.meta.name);
        }
      }
    }
    code.text = connectValue.initQueryText();
  }

  void tryUpdateInstance(InstanceModel instance) {
    this.instance = instance;
    loadFromMeta(instance.connectValue);
    notifyListeners();
  }

  @override
  void onSubmit(BuildContext context) {
    context.read<InstancesProvider>().updateInstance(InstanceModel(
        dbType: selectedDatabaseType, connectValue: getConnectValue()));
  }
}
