import 'package:client/models/instances.dart';
import 'package:client/providers/instances.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:db_driver/db_driver.dart';

// 定义一个通用的Form表单结构，代表
class CustomFormMeta {
  String name;
  bool isRequired;
  String group;
  TextEditingController ctrl = TextEditingController();
  FormFieldValidator? validator;

  CustomFormMeta(
      {required this.name, required this.group, this.isRequired = false});
}

class InstanceAdd extends StatefulWidget {
  const InstanceAdd({Key? key}) : super(key: key);

  @override
  _InstanceAddState createState() => _InstanceAddState();
}

class _InstanceAddState extends State<InstanceAdd> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
          child: Consumer<InstancesProvider>(
            builder: (context, instancesProvider, _) {
              // instanceTableController.setCount(instancesProvider.instanceCount(
              //     instanceTableController.searchTextController.text));
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
                        const Expanded(child: Spacer()),
                        TextButton(
                            onPressed: () {
                              // showAddInstanceDialog(context);
                            },
                            child: const Text("测试连接")),
                        TextButton(
                            onPressed: () {
                              // showAddInstanceDialog(context);
                            },
                            child: const Text("提交并继续添加")),
                        TextButton(
                            onPressed: () {
                              // showAddInstanceDialog(context);
                            },
                            child: const Text("提交")),
                      ],
                    ),
                  ),
                  Expanded(
                      child: SizedBox(
                    // width: 500,
                    child: AddInstancePage(
                      formMeta: [
                        CustomFormMeta(name: "自定义字段1", group: "组1"),
                        CustomFormMeta(name: "自定义字段2", group: "组1"),
                        CustomFormMeta(name: "自定义字段3", group: "组2"),
                        CustomFormMeta(name: "自定义字段4", group: "组2"),
                        CustomFormMeta(name: "自定义字段5", group: "组3"),
                        CustomFormMeta(name: "自定义字段6", group: "组3"),
                      ],
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

Future<void> showAddInstanceDialog(BuildContext context) {
  // todo: 释放资源
  return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.center,
          child: AddInstancePage(),
        );
      });
}

Future<void> showUpdateInstanceDialog(
    BuildContext context, InstanceModel instance) {
  // todo: 释放资源
  return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.center,
          child: UpdateInstancePage(instance: instance),
        );
      });
}

class AddInstancePage extends StatefulWidget {
  final TextEditingController nameCtrl = TextEditingController();

  final TextEditingController descCtrl = TextEditingController();

  final TextEditingController addrCtrl = TextEditingController();

  final TextEditingController portCtrl = TextEditingController(text: "3306");

  final TextEditingController userCtrl = TextEditingController();

  final TextEditingController passwordCtrl = TextEditingController();
  final List<CustomFormMeta> formMeta;
  final List<String> customFormGroup;

  AddInstancePage({Key? key, this.formMeta = const []})
      : customFormGroup = formMeta.map((e) => e.group).toSet().toList(),
        super(key: key);

  @override
  State<AddInstancePage> createState() => _AddInstancePageState();
}

class _AddInstancePageState extends State<AddInstancePage> {
  final String title = "添加数据源";

  int selectedGroupIndex = 0;
  int selectedDatabaseTypeIndex = 0;

  void onGroupChange(int index) {
    setState(() {
      selectedGroupIndex = index;
    });
  }

  void onDatabaseTypeChange(int index) {
    setState(() {
      selectedDatabaseTypeIndex = index;
    });
  }

  void onSubmit(BuildContext context, InstanceModel instance) {
    context.read<InstancesProvider>().addInstance(instance);
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

  FormFieldValidator validatorPassword() {
    return (value) {
      if (value == null || value.isEmpty) {
        return "密码不能为空";
      }
      return null;
    };
  }

  List<Widget> buildBaseFormField(List<SettingMeta> metas) {
    final ws = <Widget>[];
    for (final meta in metas) {
      final form = switch (meta) {
        NameMeta() =>
          nameFormField(widget.nameCtrl, validator: validatorName(context)),
        AddressMeta() => addressFormField(widget.addrCtrl, widget.portCtrl),
        UserMeta() => commonFormField("账号", widget.userCtrl),
        PasswordMeta() => passwordFormField(widget.passwordCtrl,
            validator: validatorPassword()),
        DescMeta() => descFormField(widget.descCtrl),
        _ => null,
      };
      if (form != null) {
        ws.add(form);
      }
    }
    return ws;
  }

  Widget customFormField(CustomFormMeta meta) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: TextFormField(
        controller: meta.ctrl,
        validator: meta.validator,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            labelText: meta.name,
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }

  Widget nameFormField(TextEditingController ctrl,
      {FormFieldValidator? validator}) {
    return commonFormField("名称", ctrl, validator: validator);
  }

  Widget passwordFormField(TextEditingController ctrl,
      {FormFieldValidator? validator}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: TextFormField(
        obscureText: true,
        controller: ctrl,
        validator: validator,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          labelText: "密码",
          contentPadding: const EdgeInsets.all(10),
        ),
      ),
    );
  }

  Widget commonFormField(String label, TextEditingController ctrl,
      {FormFieldValidator? validator}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: TextFormField(
        controller: ctrl,
        validator: validator,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            labelText: label,
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }

  Widget addressFormField(
      TextEditingController addrCtrl, TextEditingController portCtrl) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: addrCtrl,
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
              controller: portCtrl,
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

  Widget descFormField(TextEditingController descCtrl) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      child: TextFormField(
        controller: descCtrl,
        maxLength: 50,
        maxLines: 4,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            labelText: "描述",
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }

  Widget _buildDatabaseTypeCard(BuildContext context, int index, String type,
      String logoPath, String label) {
    return GestureDetector(
      onTap: () {
        // Handle database type selection logic here
      },
      child: Card(
        // padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        // color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: InkWell(
          onTap: () {
            setState(() {
              onDatabaseTypeChange(index);
            });
          },
          child: Column(
            children: [
              Image.asset(logoPath),
              const SizedBox(height: 5),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      // constraints: const BoxConstraints(maxWidth: 300, maxHeight: 532),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < connectionMetas.length; i++)
                      _buildDatabaseTypeCard(
                        context,
                        i,
                        connectionMetas[i].displayName,
                        connectionMetas[i].logoAssertPath,
                        connectionMetas[i].displayName,
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
                    for (final w in buildBaseFormField(
                        connectionMetas[selectedDatabaseTypeIndex].connMeta))
                      w,

                    // Expanded(
                    //     child: Column(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Container(
                    //       padding: const EdgeInsets.fromLTRB(30, 0, 40, 20),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.end,
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           TextButton(
                    //               onPressed: () {
                    //                 if (formKey.currentState!.validate()) {
                    //                   onSubmit(
                    //                       context,
                    //                       InstanceModel(
                    //                         name: nameCtrl.text,
                    //                         addr: addrCtrl.text,
                    //                         port: int.parse(portCtrl.text),
                    //                         user: userCtrl.text,
                    //                         password: passwordCtrl.text,
                    //                         desc: descCtrl.text,
                    //                       ));
                    //                   context.pop();
                    //                 }
                    //               },
                    //               child: const Text("提交"))
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ))
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              // VerticalDivider(
              //   color: Theme.of(context).dividerColor,
              //   // thickness: 1,
              // ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (var group in widget.customFormGroup)
                          TextButton(
                            onPressed: () {
                              onGroupChange(
                                  widget.customFormGroup.indexOf(group));
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: selectedGroupIndex ==
                                      widget.customFormGroup.indexOf(group)
                                  ? Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest // custom config tab selected color
                                  : null,
                            ),
                            child: Text(
                              group,
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final CustomFormMeta meta in widget.formMeta)
                      if (meta.group ==
                          widget.customFormGroup[selectedGroupIndex])
                        customFormField(meta),
                  ],
                ),
              ))
            ],
          ),
        )
      ]),
    );
  }
}

class UpdateInstancePage extends AddInstancePage {
  final TextEditingController descCtrl = TextEditingController();
  @override
  String get title => "更新数据源";

  UpdateInstancePage({Key? key, required InstanceModel instance})
      : super(key: key) {
    nameCtrl.text = instance.name;
    descCtrl.text = instance.desc ?? "";
    addrCtrl.text = instance.addr;
    portCtrl.text = instance.port.toString();
    userCtrl.text = instance.user;
    passwordCtrl.text = instance.password;
  }

  @override
  void onSubmit(BuildContext context, InstanceModel instance) {
    context.read<InstancesProvider>().updateInstance(instance);
  }

  @override
  FormFieldValidator validatorName(BuildContext context) {
    return (value) {
      if (value == null || value.isEmpty) {
        return "名称不能为空";
      }
      return null;
    };
  }

  @override
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
}
