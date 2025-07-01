import 'package:client/models/instances.dart';
import 'package:client/repositories/instances/instances.dart';
import 'package:client/services/instances/instances.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/screens/instances/instance_add.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:go_router/go_router.dart';

class UpdateInstancePage extends StatefulWidget {
  const UpdateInstancePage({Key? key}) : super(key: key);

  @override
  State<UpdateInstancePage> createState() => _UpdateInstancePageState();
}

class _UpdateInstancePageState extends State<UpdateInstancePage> {
  @override
  void initState() {
    super.initState();
    updateInstanceController
        .addListener(() => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    updateInstanceController.removeListener(() {});
    super.dispose();
  }

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
      bottomBar: AddInstanceBottomBar(
        isDatabasePingDoing: updateInstanceController.isDatabasePingDoing,
        isDatabaseConnectable: updateInstanceController.isDatabaseConnectable,
        databaseConnectError: updateInstanceController.databaseConnectError,
      ),
      child: const UpdateInstance(),
    );
  }
}

class UpdateInstance extends ConsumerStatefulWidget {
  const UpdateInstance({Key? key}) : super(key: key);

  @override
  ConsumerState<UpdateInstance> createState() => _UpdateInstanceState();
}

class _UpdateInstanceState extends ConsumerState<UpdateInstance> {
  @override
  void initState() {
    super.initState();
    updateInstanceController
        .addListener(() => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    updateInstanceController.removeListener(() {});
    super.dispose();
  }

  Color? selectedColor(AddInstanceController updateInstanceController) {
    if (updateInstanceController.isDatabasePingDoing) {
      return null;
    }
    if (updateInstanceController.isDatabaseConnectable == null) {
      return null;
    }
    if (updateInstanceController.isDatabaseConnectable == true) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                decoration: BoxDecoration(
                    border: Border(bottom: Divider.createBorderSide(context))),
                child: Row(
                  children: [
                    Text(
                      "更新数据源",
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    TextButton(
                        onPressed: updateInstanceController.isDatabasePingDoing
                            ? null
                            : () {
                                updateInstanceController.databasePing();
                              },
                        child: updateInstanceController.isDatabasePingDoing
                            ? const Text("测试中")
                            : const Text("测试连接")),
                    TextButton(
                        onPressed: () {
                          if (updateInstanceController.validate()) {
                            ref
                                .read(instancesServicesProvider.notifier)
                                .updateInstance(
                                  InstanceStorage.one(
                                    //todo: fix
                                    id: updateInstanceController
                                        .instance!.id.value,
                                    dbType: updateInstanceController
                                        .selectedDatabaseType,
                                    connectValue: updateInstanceController
                                        .getConnectValue(),
                                  ).toModel(),
                                );
                            updateInstanceController.clear();
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
                            connectionMetaMap[
                                addInstanceController.selectedDatabaseType]!
                          ],
                          selectedColor: selectedColor(addInstanceController),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: UpdateInstanceForm(
                            infos: addInstanceController.dbInfos,
                            selectedGroup: addInstanceController.selectedGroup,
                            onValid: (info, isValid) {
                              addInstanceController.updateValidState(
                                  info, isValid);
                            },
                            onGroupChange: (group) {
                              addInstanceController.onGroupChange(group);
                            },
                            codeController: addInstanceController.code,
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

class UpdateInstanceController extends AddInstanceController {
  InstanceModel? instance;

  @override
  DatabaseType get selectedDatabaseType =>
      instance?.dbType ?? DatabaseType.mysql;

  @override
  void onDatabaseTypeChange(DatabaseType type) {
    return;
  }

  UpdateInstanceController() : super();

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

  // @override
  // Future<void> onSubmit(BuildContext context) async {
  //   context.read<InstancesProvider>().updateInstance(InstanceStorage.one(
  //       id: instance!.id,
  //       dbType: selectedDatabaseType,
  //       connectValue: getConnectValue()));
  // }
}

UpdateInstanceController updateInstanceController = UpdateInstanceController();
