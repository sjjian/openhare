import 'package:client/models/instances.dart';
import 'package:client/providers/instances.dart';
import 'package:client/screens/app.dart';
import 'package:client/screens/settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class InstancesPage extends StatefulWidget {
  const InstancesPage({super.key});

  @override
  State<InstancesPage> createState() => _InstancesPageState();
}

class _InstancesPageState extends State<InstancesPage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.withOpacity(0.5)))),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    const Text(
                      "数据源列表",
                      style: TextStyle(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                    IconButton(
                        onPressed: () {
                          addInstance(context);
                          // GoRouter.of(context).go('/instances/create');
                        },
                        icon: const Icon(Icons.add))
                  ],
                ),
              ),
              Expanded(
                  child: Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTableTheme(
                    data: DataTableThemeData(
                        dataRowColor: MaterialStateProperty.all(Colors.white),
                        headingRowColor:
                            MaterialStateProperty.all(Colors.white)),
                    child: Consumer<InstancesProvider>(
                      builder: (context, instancesProvider, _) {
                        return DataTable(
                            checkboxHorizontalMargin: 0,
                            columns: const [
                              DataColumn(label: Text("名称")),
                              DataColumn(label: Text("描述")),
                              DataColumn(label: Text("地址")),
                              DataColumn(label: Text("端口")),
                              DataColumn(label: Text("用户名")),
                              DataColumn(label: Text("操作"))
                            ],
                            rows: instancesProvider.instancesModel
                                .map((instance) {
                              return DataRow(
                                  onSelectChanged: (value) {},
                                  cells: [
                                    DataCell(Text(instance.name)),
                                    DataCell(Text(instance.desc ?? "-")),
                                    DataCell(Text(instance.addr)),
                                    DataCell(Text("${instance.port}")),
                                    DataCell(Text(instance.user)),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            print(1);
                                          },
                                          icon: const Icon(Icons.edit),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            print(2);
                                          },
                                          icon: const Icon(Icons.delete),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            print(3);
                                          },
                                          icon: const Icon(
                                              Icons.more_vert_outlined),
                                        )
                                      ],
                                    ))
                                  ]);
                            }).toList(),
                            sortAscending: false,
                            showCheckboxColumn: true,
                            onSelectAll: (state) {}
                            // setState(() => _instances.selectAll(state!)),
                            );
                      },
                    ),
                  ),
                ),
              ))
            ],
          ),
        )),
      ],
    );
  }

  Future<void> addInstance(BuildContext context) {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController descCtrl = TextEditingController();
    TextEditingController addrCtrl = TextEditingController();
    TextEditingController portCtrl = TextEditingController(text: "3306");
    TextEditingController userCtrl = TextEditingController();
    TextEditingController passwordCtrl = TextEditingController();

    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              alignment: Alignment.center,
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 500, maxHeight: 532),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                        child: Row(
                          children: [
                            const Text(
                              "添加数据源",
                              style: TextStyle(fontSize: 24),
                            ),
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.close))
                              ],
                            ))
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Form(
                            child: Column(
                          children: [
                            Container(
                              constraints: const BoxConstraints(minHeight: 80),
                              child: TextFormField(
                                controller: nameCtrl,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    labelText: "名称",
                                    contentPadding: const EdgeInsets.all(10)),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minHeight: 90),
                              child: TextFormField(
                                controller: descCtrl,
                                maxLength: 50,
                                maxLines: 2,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    labelText: "描述",
                                    contentPadding: const EdgeInsets.all(10)),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minHeight: 80),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: addrCtrl,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          labelText: "地址",
                                          contentPadding:
                                              const EdgeInsets.all(10)),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 120),
                                    child: TextFormField(
                                      controller: portCtrl,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          labelText: "端口",
                                          contentPadding:
                                              const EdgeInsets.all(10)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minHeight: 80),
                              child: TextFormField(
                                controller: userCtrl,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    labelText: "帐号",
                                    contentPadding: const EdgeInsets.all(10)),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minHeight: 80),
                              child: TextFormField(
                                controller: passwordCtrl,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    labelText: "密码",
                                    contentPadding: const EdgeInsets.all(10)),
                              ),
                            ),
                          ],
                        )),
                      ),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(30, 0, 40, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      context
                                          .read<InstancesProvider>()
                                          .addInstance(InstanceModel(
                                              name: nameCtrl.text,
                                              addr: nameCtrl.text,
                                              port: 3306,
                                              user: nameCtrl.text,
                                              password: nameCtrl.text));

                                      context.pop();
                                    },
                                    child: const Text("提交"))
                              ],
                            ),
                          ),
                        ],
                      ))
                    ]),
              ));
        });
  }
}
