import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/providers/instances.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/screens/instances/instance_tables.dart';
import 'package:client/widgets/paginated_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddSession extends StatefulWidget {
  const AddSession({Key? key}) : super(key: key);

  @override
  State<AddSession> createState() => _AddSessionState();
}

class _AddSessionState extends State<AddSession> {
  @override
  void initState() {
    super.initState();
    instanceTableController.addListener(() => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    instanceTableController.removeListener(() {});
    super.dispose();
  }

  void addSession(BuildContext context, InstanceModel inst, {String? schema}) {
    SessionProvider sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);

    SessionListProvider sessionListProvider =
        Provider.of<SessionListProvider>(context, listen: false);

    if (sessionProvider.session == null) {
      SessionModel session = SessionModel();
      sessionListProvider.addSession(session);
      sessionProvider.setConn(inst, schema: schema);
      // 添加会话自动建立连接
      sessionListProvider.connect(session);
    } else {
      sessionProvider.setConn(inst, schema: schema);
      // 添加会话自动建立连接
      sessionProvider.connect();
    }
    sessionListProvider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    InstancesProvider instancesProvider =
        Provider.of<InstancesProvider>(context);

    instanceTableController.setCount(instancesProvider
        .instanceCount(instanceTableController.searchTextController.text));

    return Expanded(
        child: Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(40, 20, 0, 0),
      child: Row(
        children: [
          Container(
            width: 800,
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
                for (var inst in instancesProvider.activeInstances())
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/icons/mysql_icon.png",
                              height: 24,
                            ),
                            TextButton(
                                onPressed: () {
                                  addSession(context, inst);
                                },
                                child: Text(inst.name)),
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        width: 5,
                      ),
                      for (final schema in inst.activeSchemas.toList())
                        TextButton(
                          onPressed: () {
                            addSession(context, inst, schema: schema);
                          },
                          child: Text(schema),
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
                                    controller: instanceTableController
                                        .searchTextController,
                                    onChanged: (value) {
                                      instanceTableController.onSearchChange();
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
                for (var inst in instancesProvider.instances(
                    instanceTableController.searchTextController.text,
                    instanceTableController.pageSize,
                    instanceTableController.pageNumber))
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/icons/mysql_icon.png",
                              height: 24,
                            ),
                            TextButton(
                                onPressed: () {
                                  addSession(context, inst);
                                },
                                child: Text(inst.name)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 15),
                        width: 200,
                        child: Row(
                          children: [
                            Text("${inst.addr}:${inst.port}"),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 15),
                        width: 200,
                        child: Row(
                          children: [
                            Text(inst.desc ?? ""),
                          ],
                        ),
                      ),
                    ],
                  ),
                TablePaginatedBar(controller: instanceTableController)
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

InstanceTableController instanceTableController = InstanceTableController();
