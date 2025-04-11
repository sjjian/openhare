import 'package:client/providers/instances.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:re_highlight/languages/sql.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

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
      child: const AddInstance(),
    );
  }
}

class AddInstance extends StatelessWidget {
  const AddInstance({Key? key}) : super(key: key);

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
                              if (addInstanceProvider.validate()) {
                                addInstanceProvider.onSubmit(context);
                                addInstanceProvider.clear();
                              }
                            },
                            child: const Text("提交并继续添加")),
                        TextButton(
                            onPressed: () {
                              if (addInstanceProvider.validate()) {
                                addInstanceProvider.onSubmit(context);
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

class DatabaseTypeCardList extends StatelessWidget {
  final List<ConnectionMeta> connectionMetas;
  final Function(DatabaseType type)? onDatabaseTypeChange;
  final DatabaseType? _selectedDatabaseType;

  const DatabaseTypeCardList(
      {Key? key,
      required this.connectionMetas,
      this.onDatabaseTypeChange,
      DatabaseType? selectedDatabaseType})
      : _selectedDatabaseType = selectedDatabaseType,
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
      if (context.read<InstancesProvider>().isInstanceExist(value)) {
        return "名称已存在";
      }
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
    groups.add("bash");
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
    if (group == "bash") {
      return [
        Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest // db type card selected color
              ,
            ),
            child: CodeEditor(
              style: CodeEditorStyle(
                  codeTheme: CodeHighlightTheme(
                      theme: atomOneLightTheme,
                      languages: <String, CodeHighlightThemeMode>{
                    'sql': CodeHighlightThemeMode(mode: langSql),
                  })),
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
