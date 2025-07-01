import 'package:client/services/instances/instances.dart';
import 'package:client/services/sessions.dart';
import 'package:client/screens/instances/instance_tables.dart';
import 'package:client/widgets/paginated_bar.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

TextEditingController searchTextController = TextEditingController(text: "");

class AddSession extends HookConsumerWidget {
  const AddSession({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(instancesNotifierProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(40, 20, 0, 0),
      child: Row(
        children: [
          Container(
            width: 900,
            constraints: const BoxConstraints(minWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    "最近使用",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Row(
                    children: [
                      const SizedBox(width: 200, child: Text("数据源")),
                      Container(
                          padding: const EdgeInsets.only(left: 15),
                          child: const Text("最近打开的数据库"))
                    ],
                  ),
                ),
                for (var inst in ref
                    .read(instancesServicesProvider.notifier)
                    .activeInstances()) // todo
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            Image.asset(
                              connectionMetaMap[inst.dbType]!.logoAssertPath,
                              height: 24,
                            ),
                            TextButton(
                                onPressed: () {
                                  ref
                                      .read(sessionsServicesProvider.notifier)
                                      .addSession(inst);
                                },
                                child: Text(
                                  inst.connectValue.name,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        width: 5,
                      ),
                      for (final schema in inst.activeSchemas.toList())
                        TextButton(
                          onPressed: () {
                            ref
                                .read(sessionsServicesProvider.notifier)
                                .addSession(inst, schema: schema);
                          },
                          child: Text(schema, overflow: TextOverflow.ellipsis),
                        )
                    ],
                  ),
                Container(
                  padding: const EdgeInsets.only(bottom: 5, top: 35),
                  child: Row(
                    children: [
                      Text(
                        "完整列表",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(right: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SearchBarTheme(
                                  data: const SearchBarThemeData(
                                      elevation: WidgetStatePropertyAll(0),
                                      constraints: BoxConstraints(
                                          minHeight: 35, maxWidth: 200)),
                                  child: SearchBar(
                                    controller: searchTextController,
                                    onChanged: (value) {
                                      print("=============$value");
                                      ref
                                          .read(instancesNotifierProvider
                                              .notifier)
                                          .changePage(value,
                                              pageNumber: model.currentPage,
                                              pageSize: model.pageSize);
                                    },
                                    trailing: const [Icon(Icons.search)],
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Row(
                    children: [
                      const SizedBox(width: 200, child: Text("数据源")),
                      Container(
                          width: 200,
                          padding: const EdgeInsets.only(left: 15),
                          child: const Text("地址")),
                      Container(
                          padding: const EdgeInsets.only(left: 15),
                          child: const Text("描述")),
                    ],
                  ),
                ),
                for (var inst in model.instances) //todo
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            Image.asset(
                              connectionMetaMap[inst.dbType]!.logoAssertPath,
                              height: 24,
                            ),
                            TextButton(
                                onPressed: () {
                                  ref
                                      .read(sessionsServicesProvider.notifier)
                                      .addSession(inst);
                                },
                                child: Text(inst.connectValue.name,
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 15),
                        width: 200,
                        child: Row(
                          children: [
                            Text(
                                "${inst.connectValue.host}:${inst.connectValue.port}",
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 15),
                        width: 200,
                        child: Row(
                          children: [
                            Text(inst.connectValue.desc ?? ""),
                          ],
                        ),
                      ),
                    ],
                  ),
                TablePaginatedBar(
                    count: model.count,
                    pageSize: model.pageSize,
                    pageNumber: model.currentPage,
                    onChange: (pageNumber) {
                      ref.read(instancesNotifierProvider.notifier).changePage(
                          "",
                          pageNumber: pageNumber,
                          pageSize: model.pageSize);
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class _AddSessionState extends State<AddSession> {
//   @override
//   void initState() {
//     super.initState();
//     instanceTableController.addListener(() => mounted ? setState(() {}) : null);
//   }

//   @override
//   void dispose() {
//     instanceTableController.removeListener(() {});
//     super.dispose();
//   }

// }

// InstanceTableController instanceTableController = InstanceTableController();
