import 'package:client/models/instances.dart';
import 'package:client/providers/instances.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/screens/instances/instance_add.dart';

class InstanceAddFormController {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController addrCtrl = TextEditingController();
  final TextEditingController portCtrl = TextEditingController(text: "3306");
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final Map<CustomMeta, TextEditingController> customCtrl = {};

  InstanceAddFormController.fromConnectMeta() {
    for (var connMeta in connectionMetas) {
      for (var meta in connMeta.connMeta) {
        if (meta is CustomMeta) {
          customCtrl[meta] = TextEditingController();
        }
      }
    }
  }

  void clear() {
    nameCtrl.clear();
    descCtrl.clear();
    addrCtrl.clear();
    portCtrl.clear();
    userCtrl.clear();
    passwordCtrl.clear();
    for (final ctrl in customCtrl.values) {
      ctrl.clear();
    }
  }

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

  static InstanceAddFormController controller =
      InstanceAddFormController.fromConnectMeta();
}

class UpdateInstancePage extends StatefulWidget {
  final InstanceModel instance;
  final InstanceAddFormController controller =
      InstanceAddFormController.controller;

  UpdateInstancePage({Key? key, required this.instance}) : super(key: key) {
    controller.loadFromMeta(instance.connectValue);
  }

  @override
  State<UpdateInstancePage> createState() => _InstanceUpdateState();
}

class _InstanceUpdateState extends State<UpdateInstancePage> {
  get title => "更新数据源";

  final formKey = GlobalKey<FormState>();

  DatabaseType get selectedDatabaseType => widget.instance.dbType;

  String _selectedGroup = "";

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

  String? get selectedGroup {
    if (customSettingGroup.isEmpty) {
      return null;
    }
    if (_selectedGroup.isEmpty) {
      return customSettingGroup.first;
    }
    return _selectedGroup;
  }

  void onGroupChange(String group) {
    setState(() {
      _selectedGroup = group;
    });
  }

  List<SettingMeta> getSettingMeta(String? group) {
    final connMeta = connectionMetaMap[selectedDatabaseType]?.connMeta;
    if (connMeta == null) {
      return [];
    }
    if (group == null || group.isEmpty) {
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
    final name = widget.controller.nameCtrl.text;
    final addr = widget.controller.addrCtrl.text;
    final port = int.tryParse(widget.controller.portCtrl.text ?? "3306");
    final user = widget.controller.userCtrl.text;
    final password = widget.controller.passwordCtrl.text;
    final desc = widget.controller.descCtrl.text;

    final custom = {
      for (final meta in connectionMetaMap[selectedDatabaseType]!.connMeta)
        if (meta is CustomMeta)
          meta.name: widget.controller.customCtrl[meta]!.text
    };

    return ConnectValue(
      name: name,
      host: addr,
      port: port ?? 3306,
      user: user,
      password: password,
      desc: desc,
      custom: custom,
    );
  }

  void onSubmit(BuildContext context) {
    context.read<InstancesProvider>().updateInstance(InstanceModel(
        dbType: selectedDatabaseType, connectValue: getConnectValue()));
  }

  FormFieldValidator validatorName(BuildContext context) {
    return (value) {
      if (value == null || value.isEmpty) {
        return "名称不能为空";
      }
      return null;
    };
  }

  Widget nameFormField(TextEditingController ctrl,
      {FormFieldValidator? validator}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: TextFormField(
        readOnly: true,
        controller: ctrl,
        validator: validator,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            labelText: "名称",
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }

  Widget buildBaseFormField(SettingMeta connMeta) {
    return switch (connMeta) {
      NameMeta() => CommonFormField(
          label: "名称", controller: widget.controller.nameCtrl, readOnly: true),
      AddressMeta() => AddressFormField(
          addrController: widget.controller.addrCtrl,
          portController: widget.controller.portCtrl),
      UserMeta() =>
        CommonFormField(label: "账号", controller: widget.controller.userCtrl),
      PasswordMeta() =>
        PasswordFormField(controller: widget.controller.passwordCtrl),
      DescMeta() => DescFormField(controller: widget.controller.descCtrl),
      CustomMeta() => CommonFormField(
          label: connMeta.name,
          controller: widget.controller.customCtrl[connMeta]!,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
          child: Consumer<InstancesProvider>(
            builder: (context, instancesProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    decoration: BoxDecoration(
                        border:
                            Border(bottom: Divider.createBorderSide(context))),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        TextButton(
                            onPressed: () {
                              // showAddInstanceDialog(context);
                            },
                            child: const Text("测试连接")),
                        TextButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                onSubmit(context);
                                widget.controller.clear();
                                instancesProvider.goPage("instances");
                              }
                            },
                            child: const Text("更新")),
                      ],
                    ),
                  ),
                  Expanded(
                      child: SizedBox(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                DatabaseTypeCard(
                                  name: connectionMetaMap[selectedDatabaseType]!
                                      .displayName,
                                  type: selectedDatabaseType,
                                  logoPath:
                                      connectionMetaMap[selectedDatabaseType]!
                                          .logoAssertPath,
                                  selected: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 500),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(
                                              "基础配置",
                                              textAlign: TextAlign.left,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        Form(
                                            key: formKey,
                                            child: Column(
                                              children: [
                                                for (final w
                                                    in getSettingMeta("base"))
                                                  buildBaseFormField(w),
                                              ],
                                            ))
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                      child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 500),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            for (var group
                                                in customSettingGroup)
                                              TextButton(
                                                onPressed: () {
                                                  onGroupChange(group);
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor: selectedGroup ==
                                                          group
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .surfaceContainerHighest // custom config tab selected color
                                                      : null,
                                                ),
                                                child: Text(
                                                  group,
                                                  textAlign: TextAlign.left,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Form(
                                            // key: formKey,
                                            child: Column(
                                          children: [
                                            for (final meta in getSettingMeta(
                                                selectedGroup))
                                              buildBaseFormField(meta),
                                          ],
                                        ))
                                      ],
                                    ),
                                  ))
                                ],
                              ),
                            )
                          ]),
                    ),
                  )),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: const Row(
                      children: [],
                    ),
                  )
                ],
              );
            },
          ),
        )),
      ],
    );
  }
}
