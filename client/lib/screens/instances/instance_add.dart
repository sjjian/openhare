import 'package:client/providers/instances.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:google_fonts/google_fonts.dart';

class AddInstancePage extends StatelessWidget {
  const AddInstancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageSkeleton(
      topBar: Row(
        children: [
          IconButton(
              onPressed: () => GoRouter.of(context).go('/instances/list'),
              icon: const Icon(Icons.arrow_back))
        ],
      ),
      bottomBar: Consumer<AddInstanceProvider>(
          builder: (context, addInstanceProvider, _) {
        return AddInstanceBottomBar(
          isDatabasePingDoing: addInstanceProvider.isDatabasePingDoing,
          isDatabaseConnectable: addInstanceProvider.isDatabaseConnectable,
          databaseConnectError: addInstanceProvider.databaseConnectError,
        );
      }),
      child: const AddInstance(),
    );
  }
}

class AddInstance extends StatelessWidget {
  const AddInstance({Key? key}) : super(key: key);

  Color? selectedColor(AddInstanceProvider addInstanceProvider) {
    if (addInstanceProvider.isDatabasePingDoing) {
      return null;
    }
    if (addInstanceProvider.isDatabaseConnectable == null) {
      return null;
    }
    if (addInstanceProvider.isDatabaseConnectable == true) {
      return Colors.green;
    } else {
      return Colors.red;
    }
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
                            onPressed: addInstanceProvider.isDatabasePingDoing
                                ? null
                                : () {
                                    addInstanceProvider.databasePing();
                                    // showAddInstanceDialog(context);
                                  },
                            child: const Text("测试连接")),
                        TextButton(
                            onPressed: () async {
                              if (addInstanceProvider.validate()) {
                                await addInstanceProvider.onSubmit(context);
                                addInstanceProvider.clear();
                              }
                            },
                            child: const Text("提交并继续添加")),
                        TextButton(
                            onPressed: () async {
                              if (addInstanceProvider.validate()) {
                                await addInstanceProvider.onSubmit(context);
                                addInstanceProvider.clear();
                                GoRouter.of(context).go('/instances/list');
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
                            DatabaseTypeCardList(
                              connectionMetas: connectionMetas,
                              selectedDatabaseType:
                                  addInstanceProvider.selectedDatabaseType,
                              onDatabaseTypeChange: (type) {
                                addInstanceProvider.onDatabaseTypeChange(type);
                              },
                              selectedColor: selectedColor(addInstanceProvider),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: AddInstanceForm(
                                infos: addInstanceProvider.dbInfos,
                                selectedGroup:
                                    addInstanceProvider.selectedGroup,
                                onValid: (info, isValid) {
                                  addInstanceProvider.updateValidState(
                                      info, isValid);
                                },
                                onGroupChange: (group) {
                                  addInstanceProvider.onGroupChange(group);
                                },
                                codeController: addInstanceProvider.code,
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
  final Color? selectedColor;
  final Function(DatabaseType type)? onTap;

  const DatabaseTypeCard(
      {Key? key,
      required this.type,
      required this.name,
      required this.logoPath,
      this.selected = false,
      this.selectedColor,
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedColor, // Green when selected, grey when not
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DatabaseTypeCardList extends StatelessWidget {
  final List<ConnectionMeta> connectionMetas;
  final Function(DatabaseType type)? onDatabaseTypeChange;
  final DatabaseType? _selectedDatabaseType;
  final Color? selectedColor;

  const DatabaseTypeCardList({
    Key? key,
    required this.connectionMetas,
    this.onDatabaseTypeChange,
    DatabaseType? selectedDatabaseType,
    this.selectedColor,
  })  : _selectedDatabaseType = selectedDatabaseType,
        super(key: key);

  DatabaseType? get selectedDatabaseType =>
      _selectedDatabaseType ?? connectionMetas.first.type;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    selected: connMeta.type == selectedDatabaseType,
                    selectedColor: selectedColor,
                    onTap: (type) => onDatabaseTypeChange?.call(type),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CommonFormField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FormFieldValidator? validator;
  final bool readOnly;
  final GlobalKey<FormFieldState>? state;
  final bool obscureText;

  const CommonFormField(
      {Key? key,
      required this.label,
      required this.controller,
      this.state,
      this.validator,
      this.readOnly = false,
      this.obscureText = false})
      : super(key: key);

  @override
  State<CommonFormField> createState() => _CommonFormFieldState();
}

class _CommonFormFieldState extends State<CommonFormField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: TextFormField(
        key: widget.state,
        readOnly: widget.readOnly,
        obscureText: widget.obscureText,
        autovalidateMode: AutovalidateMode.onUnfocus,
        controller: widget.controller,
        validator: widget.validator,
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
  final GlobalKey<FormFieldState>? state;

  const DescFormField({Key? key, required this.controller, this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      child: TextFormField(
        key: state,
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
  final String? selectedGroup;
  final Map<String, FormInfo> infos;
  final Function(FormInfo info, bool isValid)? onValid;
  final Function(String group)? onGroupChange;
  final CodeLineEditingController codeController;

  const AddInstanceForm(
      {Key? key,
      required this.infos,
      this.onValid,
      this.onGroupChange,
      this.selectedGroup,
      required this.codeController})
      : super(key: key);

  FormFieldValidator validatorFn(
      BuildContext context, FormInfo info, FormFieldValidator validate) {
    return (value) {
      final result = validate(value);
      if (result == null) {
        onValid?.call(info, true);
      } else {
        onValid?.call(info, false);
      }
      return result;
    };
  }

  FormFieldValidator validatorName(BuildContext context) {
    return (value) {
      if (value == null || value.isEmpty) {
        return "名称不能为空";
      }
      // final exist = context.read<InstancesProvider>().isInstanceExist(value);
      // if (exist is Future<bool>) {
      //   exist.then((exists) {
      //     if (exists) {
      //       // Handle validation error asynchronously if needed
      //     }
      //   });
      // }
      return null;
    };
  }

  FormFieldValidator validatorValueRequired(BuildContext context) {
    return (value) {
      if (value == null || value.isEmpty) {
        return "值不能为空";
      }
      return null;
    };
  }

  int get selectedGroupIndex {
    if (selectedGroup == null) {
      return 0;
    }
    return groups.indexOf(selectedGroup!);
  }

  List<String> get groups {
    final groups = infos.values
        .groupListsBy((info) => info.meta.group)
        .keys
        .whereNot((e) => e == settingMetaGroupBase)
        .toList();
    groups.add("initize");
    return groups;
  }

  Widget buildNameField(BuildContext context) {
    FormInfo name = infos[settingMetaNameName]!;
    return CommonFormField(
      state: name.state,
      label: "名称",
      controller: name.ctrl,
      validator: validatorFn(context, name, validatorName(context)),
    );
  }

  Widget buildAddressField(BuildContext context) {
    FormInfo addr = infos[settingMetaNameAddr]!;
    FormInfo port = infos[settingMetaNamePort]!;
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CommonFormField(
              label: "地址",
              controller: addr.ctrl,
              state: addr.state,
              validator:
                  validatorFn(context, addr, validatorValueRequired(context)),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 120),
            child: CommonFormField(
              label: "端口",
              controller: port.ctrl,
              state: port.state,
              validator:
                  validatorFn(context, port, validatorValueRequired(context)),
            ),
          )
        ],
      ),
    );
  }

  Widget buildUserField(BuildContext context) {
    FormInfo user = infos[settingMetaNameUser]!;
    return CommonFormField(
      label: "账号",
      controller: user.ctrl,
      state: user.state,
      validator: validatorFn(context, user, validatorValueRequired(context)),
    );
  }

  Widget buildPasswordField(BuildContext context) {
    FormInfo password = infos[settingMetaNamePassword]!;
    return CommonFormField(
      label: "密码",
      controller: password.ctrl,
      state: password.state,
      obscureText: true,
      validator:
          validatorFn(context, password, validatorValueRequired(context)),
    );
  }

  Widget buildDescField(BuildContext context) {
    FormInfo desc = infos[settingMetaNameDesc]!;
    return DescFormField(
      controller: desc.ctrl,
      state: desc.state,
    );
  }

  List<Widget> buildCustomField(BuildContext context, String group) {
    if (group == "initize") {
      return [
        Container(
            constraints: const BoxConstraints(maxHeight: 430),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest // db type card selected color
              ,
            ),
            child: CodeEditor(
              // todo: 抽取公共方法.
              style: CodeEditorStyle(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh, // SQL 编辑器背景色
                textStyle: GoogleFonts.robotoMono(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    color:
                        Theme.of(context).colorScheme.onSurface), // SQL 编辑器文字颜色
              ),
              indicatorBuilder:
                  (context, editingController, chunkController, notifier) {
                return Row(
                  children: [
                    DefaultCodeLineNumber(
                      controller: editingController,
                      notifier: notifier,
                    ),
                    DefaultCodeChunkIndicator(
                        width: 20,
                        controller: chunkController,
                        notifier: notifier)
                  ],
                );
              },
              controller: codeController,
              wordWrap: false,
            ))
      ];
    }
    List<Widget> ws = [];
    for (final info in infos.values) {
      if (info.meta.group == group && info.meta is CustomMeta) {
        ws.add(CommonFormField(
            state: info.state,
            label: info.meta.name,
            controller: info.ctrl,
            validator: validatorFn(
              context,
              info,
              validatorValueRequired(context),
            )));
      }
    }
    return ws;
  }

  bool isGroupValid(String group) {
    for (final info in infos.values) {
      if (info.meta.group == group) {
        if (!info.isValid) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
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
              Column(
                children: [
                  buildNameField(context),
                  buildAddressField(context),
                  buildUserField(context),
                  buildPasswordField(context),
                  buildDescField(context)
                ],
              )
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
                  for (var group in groups)
                    TextButton(
                      onPressed: () {
                        onGroupChange?.call(group);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: group == selectedGroup
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
                                color:
                                    !isGroupValid(group) ? Colors.red : null)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              IndexedStack(
                index: selectedGroupIndex,
                children: [
                  for (final group in groups)
                    Column(
                      children: buildCustomField(context, group),
                    ),
                ],
              )
            ],
          ),
        ))
      ],
    );
  }
}

class AddInstanceBottomBar extends StatelessWidget {
  final bool? isDatabaseConnectable;
  final String? databaseConnectError;
  final bool isDatabasePingDoing;

  const AddInstanceBottomBar(
      {Key? key,
      this.databaseConnectError,
      required this.isDatabasePingDoing,
      this.isDatabaseConnectable})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget msg;
    Widget status;

    if (isDatabasePingDoing) {
      msg = const Text("连接测试中");
      status = const CircularProgressIndicator(
        strokeWidth: 2
      );
    } else if (isDatabaseConnectable == null) {
      msg = const Text("");
      status = const Spacer();
    } else if (isDatabaseConnectable == true) {
      msg = const Text("连接成功");
      status = const Icon(Icons.check_circle,size: 20, color: Colors.green);
    } else {
      msg = Text(databaseConnectError ?? "", overflow: TextOverflow.ellipsis);
      status = const Icon(Icons.error,size: 20, color: Colors.red);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10,0,10,0),
          child: SizedBox(
            height: 20,
            width: 20,
            child: status,
          ),
        ),
        Expanded(child: msg)
      ],
    );
  }
}
