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
                            Expanded(
                              child: AddInstanceForm(
                                infos: updateInstanceProvider.infos[
                                    updateInstanceProvider
                                        .selectedDatabaseType]!,
                                selectedGroup: "conn",
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
