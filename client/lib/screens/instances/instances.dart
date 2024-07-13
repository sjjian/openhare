import 'package:client/models/instances.dart';
import 'package:client/providers/instances.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InstancesPage extends StatefulWidget {
  const InstancesPage({super.key});

  @override
  State<InstancesPage> createState() => _InstancesPageState();
}

class _InstancesPageState extends State<InstancesPage> {
  Set<InstanceModel> selectedInstances = {};

  @override
  Widget build(BuildContext context) {
    const column = [
      DataColumn(label: Text("名称")),
      DataColumn(label: Text("描述")),
      DataColumn(label: Text("地址")),
      DataColumn(label: Text("端口")),
      DataColumn(label: Text("用户名")),
      DataColumn(label: Text("操作"))
    ];

    return Row(
      children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                decoration: BoxDecoration(
                    border: Border(bottom: Divider.createBorderSide(context))),
                child: const Row(
                  children: [
                    Text(
                      "数据源列表",
                      style: TextStyle(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Consumer<InstancesProvider>(
                    builder: (context, instancesProvider, _) {
                      return DataTable(
                          checkboxHorizontalMargin: 0,
                          showBottomBorder: true,
                          columns: column,
                          rows:
                              instancesProvider.instancesModel.map((instance) {
                            return DataRow(
                                selected: selectedInstances.contains(instance),
                                onSelectChanged: (state) {
                                  setState(() {
                                    if (state == null || !state) {
                                      selectedInstances.remove(instance);
                                    } else {
                                      selectedInstances.add(instance);
                                    }
                                  });
                                },
                                cells: [
                                  DataCell(Text(instance.name)),
                                  DataCell(Text(instance.desc ?? "-")),
                                  DataCell(Text(instance.addr)),
                                  DataCell(Text("${instance.port}")),
                                  DataCell(Text(instance.user)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.edit),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          context
                                              .read<InstancesProvider>()
                                              .deleteInstance(instance.name);
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                            Icons.more_vert_outlined),
                                      )
                                    ],
                                  ))
                                ]);
                          }).toList(),
                          sortAscending: false,
                          showCheckboxColumn: true,
                          onSelectAll: (state) {
                            setState(() {
                              if (state == null || !state) {
                                selectedInstances.clear();
                              } else {
                                selectedInstances
                                    .addAll(instancesProvider.instancesModel);
                              }
                            });
                          }
                          // setState(() => _instances.selectAll(state!)),
                          );
                    },
                  ),
                ),
              )),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
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
