import 'package:client/models/instances.dart';
import 'package:client/providers/instances.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:db_driver/db_driver.dart';

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

class InstanceAdd extends StatefulWidget {
  final InstanceAddFormController controller =
      InstanceAddFormController.controller;

  InstanceAdd({Key? key}) : super(key: key);

  @override
  State<InstanceAdd> createState() => _InstanceAddState();
}

class _InstanceAddState extends State<InstanceAdd> {
  get title => "添加数据源";

  final formKey = GlobalKey<FormState>();

  DatabaseType selectedDatabaseType = DatabaseType.mysql;

  String _selectedGroup = "";

  void onDatabaseTypeChange(DatabaseType type) {
    setState(() {
      selectedDatabaseType = type;
      _selectedGroup = "";
    });
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
    context.read<InstancesProvider>().addInstance(InstanceModel(
        dbType: selectedDatabaseType, connectValue: getConnectValue()));
  }

  FormFieldValidator validatorName(BuildContext context) {
    return (value) {
      if (value == null || value.isEmpty) {
        return "名称不能为空";
      }
      if (context.read<InstancesProvider>().isInstanceExist(value)) {
        return "名称已存在";
      }
      return null;
    };
  }

  Widget buildBaseFormField(SettingMeta connMeta) {
    return switch (connMeta) {
      NameMeta() => CommonFormField(
          label: "名称",
          controller: widget.controller.nameCtrl,
          validator: validatorName(context)),
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
                              }
                            },
                            child: const Text("提交并继续添加")),
                        TextButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                onSubmit(context);
                                widget.controller.clear();
                                instancesProvider.goPage("instances");
                              }
                            },
                            child: const Text("提交")),
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
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        for (final connMeta in connectionMetas)
                                          DatabaseTypeCard(
                                            name: connMeta.displayName,
                                            type: connMeta.type,
                                            logoPath: connMeta.logoAssertPath,
                                            selected: connMeta.type ==
                                                selectedDatabaseType,
                                            onTap: (type) =>
                                                onDatabaseTypeChange(type),
                                          ),
                                      ],
                                    ),
                                  ),
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
                                    width: 40,
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

class DatabaseTypeCard extends StatelessWidget {
  final DatabaseType type;
  final String name;
  final String logoPath;
  final bool selected;
  final Function(DatabaseType type)? onTap;

  const DatabaseTypeCard(
      {Key? key,
      required this.type,
      required this.name,
      required this.logoPath,
      this.selected = false,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80, minWidth: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: selected
            ? Theme.of(context)
                .colorScheme
                .surfaceContainerHighest // db type card selected color
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (!selected && onTap != null) {
            onTap!(type);
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Image.asset(logoPath),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
            ),
            if (selected)
              Container(
                padding: const EdgeInsets.only(bottom: 5),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green, // Green when selected, grey when not
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PasswordFormField extends StatelessWidget {
  final TextEditingController controller;
  const PasswordFormField({Key? key, required this.controller})
      : super(key: key);

  FormFieldValidator validatorPassword() {
    return (value) {
      if (value == null || value.isEmpty) {
        return "密码不能为空";
      }
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUnfocus,
        obscureText: true,
        controller: controller,
        validator: validatorPassword(),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          labelText: "密码",
          contentPadding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}

class AddressFormField extends StatelessWidget {
  final TextEditingController addrController;
  final TextEditingController portController;
  const AddressFormField(
      {Key? key, required this.addrController, required this.portController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: addrController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  labelText: "地址",
                  contentPadding: const EdgeInsets.all(10)),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 120),
            child: TextFormField(
              controller: portController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  labelText: "端口",
                  contentPadding: const EdgeInsets.all(10)),
            ),
          )
        ],
      ),
    );
  }
}

class CommonFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FormFieldValidator? validator;
  final bool readOnly;

  const CommonFormField(
      {Key? key,
      required this.label,
      required this.controller,
      this.validator,
      this.readOnly = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: TextFormField(
        readOnly: readOnly,
        autovalidateMode: AutovalidateMode.onUnfocus,
        controller: controller,
        validator: (readOnly) ? null : validator,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            labelText: label,
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }
}

class DescFormField extends StatelessWidget {
  final TextEditingController controller;

  const DescFormField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      child: TextFormField(
        controller: controller,
        maxLength: 50,
        maxLines: 4,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            labelText: "描述",
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }
}
