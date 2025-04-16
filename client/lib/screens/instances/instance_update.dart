import 'package:client/providers/instances.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/screens/instances/instance_add.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:go_router/go_router.dart';

class UpdateInstancePage extends StatelessWidget {
  const UpdateInstancePage({Key? key}) : super(key: key);

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
      bottomBar: Consumer<UpdateInstanceProvider>(
          builder: (context, updateInstanceProvider, _) {
        return AddInstanceBottomBar(
          isDatabasePingDoing: updateInstanceProvider.isDatabasePingDoing,
          isDatabaseConnectable: updateInstanceProvider.isDatabaseConnectable,
          databaseConnectError: updateInstanceProvider.databaseConnectError,
        );
      }),
      child: const UpdateInstance(),
    );
  }
}

class UpdateInstance extends StatelessWidget {
  const UpdateInstance({Key? key}) : super(key: key);

  Color? selectedColor(UpdateInstanceProvider updateInstanceProvider) {
    if (updateInstanceProvider.isDatabasePingDoing) {
      return null;
    }
    if (updateInstanceProvider.isDatabaseConnectable == null) {
      return null;
    }
    if (updateInstanceProvider.isDatabaseConnectable == true) {
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
          child: Consumer<UpdateInstanceProvider>(
            builder: (context, updateInstanceProvider, _) {
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
                          "更新数据源",
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        TextButton(
                            onPressed:
                                updateInstanceProvider.isDatabasePingDoing
                                    ? null
                                    : () {
                                        updateInstanceProvider.databasePing();
                                      },
                            child: updateInstanceProvider.isDatabasePingDoing
                                ? const Text("测试中")
                                : const Text("测试连接")),
                        TextButton(
                            onPressed: () {
                              if (updateInstanceProvider.validate()) {
                                updateInstanceProvider.onSubmit(context);
                                updateInstanceProvider.clear();
                                GoRouter.of(context).go('/instances/list');
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
                            DatabaseTypeCardList(
                              connectionMetas: [
                                connectionMetaMap[updateInstanceProvider
                                    .selectedDatabaseType]!
                              ],
                              selectedColor:
                                  selectedColor(updateInstanceProvider),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: UpdateInstanceForm(
                                infos: updateInstanceProvider.dbInfos,
                                selectedGroup:
                                    updateInstanceProvider.selectedGroup,
                                onValid: (info, isValid) {
                                  updateInstanceProvider.updateValidState(
                                      info, isValid);
                                },
                                onGroupChange: (group) {
                                  updateInstanceProvider.onGroupChange(group);
                                },
                                codeController: updateInstanceProvider.code,
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

class UpdateInstanceForm extends AddInstanceForm {
  const UpdateInstanceForm(
      {super.key,
      required super.infos,
      required super.selectedGroup,
      super.onGroupChange,
      super.onValid,
      required super.codeController});
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
  Widget buildNameField(BuildContext context) {
    FormInfo name = infos[settingMetaNameName]!;
    return CommonFormField(
      readOnly: true,
      state: name.state,
      label: "名称",
      controller: name.ctrl,
      validator: validatorFn(context, name, validatorName(context)),
    );
  }
}
