import 'package:client/models/instances.dart';
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
      child: const UpdateInstance(),
    );
  }
}

class UpdateInstance extends StatelessWidget {
  const UpdateInstance({Key? key}) : super(key: key);

  void onSubmit(BuildContext context, InstanceModel instance) {
    context.read<InstancesProvider>().updateInstance(instance);
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
                            onPressed: () {
                              // showAddInstanceDialog(context);
                            },
                            child: const Text("测试连接")),
                        TextButton(
                            onPressed: () {
                              if (updateInstanceProvider.validate()) {
                                onSubmit(
                                    context,
                                    InstanceModel(
                                        dbType: updateInstanceProvider
                                            .selectedDatabaseType,
                                        connectValue: updateInstanceProvider
                                            .getConnectValue()));
                                updateInstanceProvider.clear();
                                GoRouter.of(context).go('/instances/list');
                                // instancesProvider.goPage("instances");
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
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        DatabaseTypeCard(
                                          name: connectionMetaMap[
                                                  updateInstanceProvider
                                                      .selectedDatabaseType]!
                                              .displayName,
                                          type: updateInstanceProvider
                                              .selectedDatabaseType,
                                          logoPath: connectionMetaMap[
                                                  updateInstanceProvider
                                                      .selectedDatabaseType]!
                                              .logoAssertPath,
                                          selected: true,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Expanded(
                              child: UpdateInstanceForm(),
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
  const UpdateInstanceForm({Key? key}) : super(key: key);

  @override
  Widget buildBaseFormField(BuildContext context, SettingMeta connMeta) {
    UpdateInstanceProvider updateInstanceProvider =
        context.read<UpdateInstanceProvider>();
    return switch (connMeta) {
      NameMeta() => CommonFormField(
          label: "名称",
          readOnly: true,
          controller: updateInstanceProvider.nameCtrl,
        ),
      AddressMeta() => AddressFormField(
          addrController: updateInstanceProvider.addrCtrl,
          portController: updateInstanceProvider.portCtrl),
      UserMeta() => CommonFormField(
          label: "账号", controller: updateInstanceProvider.userCtrl),
      PasswordMeta() =>
        PasswordFormField(controller: updateInstanceProvider.passwordCtrl),
      DescMeta() => DescFormField(controller: updateInstanceProvider.descCtrl),
      CustomMeta() => CommonFormField(
          state: updateInstanceProvider.states[connMeta]!.state,
          label: connMeta.name,
          controller: updateInstanceProvider.customCtrl[connMeta]!,
          onValid: (isValid) {
            context
                .read<UpdateInstanceProvider>()
                .updateValidState(connMeta, isValid);
          },
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateInstanceProvider>(
        builder: (context, updateInstanceProvider, _) {
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
                    key: updateInstanceProvider.formKey,
                    child: Column(
                      children: [
                        for (final w
                            in updateInstanceProvider.getSettingMeta("base"))
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
                    for (var group in updateInstanceProvider.customSettingGroup)
                      TextButton(
                        onPressed: () {
                          updateInstanceProvider.onGroupChange(
                              updateInstanceProvider.customSettingGroup
                                  .indexOf(group));
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: updateInstanceProvider
                                          .customSettingGroup[
                                      updateInstanceProvider.selectedGroup] ==
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
                                  color: !updateInstanceProvider
                                          .isGroupValid(group)
                                      ? Colors.red
                                      : null)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                IndexedStack(
                  index: updateInstanceProvider.selectedGroup,
                  children: [
                    for (final group
                        in updateInstanceProvider.customSettingGroup)
                      Form(
                          // key: formKey,
                          child: Column(
                        children: [
                          for (final meta
                              in updateInstanceProvider.getSettingMeta(group))
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
