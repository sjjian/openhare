import 'package:client/models/instances.dart';
import 'package:client/providers/instances.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:db_driver/db_driver.dart';

class AddInstancePage extends StatelessWidget {
  const AddInstancePage({Key? key}) : super(key: key);

  void onSubmit(BuildContext context, InstanceModel instance) {
    context.read<InstancesProvider>().addInstance(instance);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
          child: Consumer<AddInstanceProvider>(
            builder: (context, addInstanceProvider, _) {
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
                          "添加数据源",
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
                              if (addInstanceProvider.formKey.currentState!
                                  .validate()) {
                                onSubmit(
                                    context,
                                    InstanceModel(
                                        dbType: addInstanceProvider
                                            .selectedDatabaseType,
                                        connectValue: addInstanceProvider
                                            .getConnectValue()));
                                addInstanceProvider.clear();
                              }
                            },
                            child: const Text("提交并继续添加")),
                        TextButton(
                            onPressed: () {
                              if (addInstanceProvider.validate()) {
                                onSubmit(
                                    context,
                                    InstanceModel(
                                        dbType: addInstanceProvider
                                            .selectedDatabaseType,
                                        connectValue: addInstanceProvider
                                            .getConnectValue()));
                                addInstanceProvider.clear();
                                // instancesProvider.goPage("instances");
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
                                                addInstanceProvider
                                                    .selectedDatabaseType,
                                            onTap: (type) => addInstanceProvider
                                                .onDatabaseTypeChange(type),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Expanded(
                              child: AddInstanceForm(),
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

class CommonFormField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FormFieldValidator? validator;
  final bool readOnly;
  final GlobalKey<FormFieldState>? state;
  final Function(bool isValid)? onValid;

  const CommonFormField(
      {Key? key,
      required this.label,
      required this.controller,
      this.state,
      this.validator,
      this.readOnly = false,
      this.onValid})
      : super(key: key);

  @override
  State<CommonFormField> createState() => _CommonFormFieldState();
}

class _CommonFormFieldState extends State<CommonFormField> {
  FormFieldValidator validatorName(BuildContext context) {
    return (value) {
      if (value == null || value.isEmpty) {
        widget.onValid?.call(false);
        return "值不能为空";
      }else {
        widget.onValid?.call(true);
      }
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: TextFormField(
        key: widget.state,
        readOnly: widget.readOnly,
        autovalidateMode: AutovalidateMode.onUnfocus,
        controller: widget.controller,
        validator: validatorName(context),
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            labelText: widget.label,
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

class AddInstanceForm extends StatelessWidget {
  const AddInstanceForm({Key? key}) : super(key: key);

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

  Widget buildBaseFormField(BuildContext context, SettingMeta connMeta) {
    AddInstanceProvider addInstanceProvider =
        context.read<AddInstanceProvider>();
    return switch (connMeta) {
      NameMeta() => CommonFormField(
          label: "名称",
          controller: addInstanceProvider.nameCtrl,
          validator: validatorName(context)),
      AddressMeta() => AddressFormField(
          addrController: addInstanceProvider.addrCtrl,
          portController: addInstanceProvider.portCtrl),
      UserMeta() =>
        CommonFormField(label: "账号", controller: addInstanceProvider.userCtrl),
      PasswordMeta() =>
        PasswordFormField(controller: addInstanceProvider.passwordCtrl),
      DescMeta() => DescFormField(controller: addInstanceProvider.descCtrl),
      CustomMeta() => CommonFormField(
          state: addInstanceProvider.states[connMeta]!.state,
          label: connMeta.name,
          controller: addInstanceProvider.customCtrl[connMeta]!,
          onValid: (isValid) {
            context.read<AddInstanceProvider>().updateValidState(connMeta, isValid);
          },
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddInstanceProvider>(
        builder: (context, addInstanceProvider, _) {
      return Row(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      "基础配置",
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Form(
                    key: addInstanceProvider.formKey,
                    child: Column(
                      children: [
                        for (final w
                            in addInstanceProvider.getSettingMeta("base"))
                          buildBaseFormField(context, w),
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
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                Row(
                  children: [
                    for (var group in addInstanceProvider.customSettingGroup)
                      TextButton(
                        onPressed: () {
                          addInstanceProvider.onGroupChange(addInstanceProvider
                              .customSettingGroup
                              .indexOf(group));
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: addInstanceProvider
                                          .customSettingGroup[
                                      addInstanceProvider.selectedGroup] ==
                                  group
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest // custom config tab selected color
                              : null,
                        ),
                        child: Text(
                          group,
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.titleMedium!.merge(
                              TextStyle(
                                  color: !addInstanceProvider.isGroupValid(group)
                                      ? Colors.red
                                      : null)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                IndexedStack(
                  index: addInstanceProvider.selectedGroup,
                  children: [
                    for (final group in addInstanceProvider.customSettingGroup)
                      Form(
                          // key: formKey,
                          child: Column(
                        children: [
                          for (final meta
                              in addInstanceProvider.getSettingMeta(group))
                            buildBaseFormField(context, meta),
                        ],
                      ))
                  ],
                )
              ],
            ),
          ))
        ],
      );
    });
  }
}
