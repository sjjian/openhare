import 'package:client/models/instances.dart';
import 'package:client/providers/instances.dart';
import 'package:client/widgets/paginated_bar.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:go_router/go_router.dart';

class InstancesPage extends StatelessWidget {
  const InstancesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PageSkeleton(
      key: Key("instances"),
      child: InstanceTable(),
    );
  }
}

class InstanceTable extends StatefulWidget {
  const InstanceTable({super.key});

  @override
  State<InstanceTable> createState() => _InstanceTableState();
}

class _InstanceTableState extends State<InstanceTable> {
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

  DataRow buildDataRow(InstanceModel instance) {
    return DataRow(
        selected: instanceTableController.selectedInstances.contains(instance),
        onSelectChanged: (state) {
          setState(() {
            if (state == null || !state) {
              instanceTableController.selectedInstances.remove(instance);
            } else {
              instanceTableController.selectedInstances.add(instance);
            }
          });
        },
        cells: [
          DataCell(Row(
            children: [
              Image.asset(connectionMetaMap[instance.dbType]!.logoAssertPath),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(instance.connectValue.name),
              )
            ],
          )),
          DataCell(Text(instance.connectValue.desc)),
          DataCell(Text(instance.connectValue.host)),
          DataCell(Text("${instance.connectValue.port}")),
          DataCell(Text(instance.connectValue.user)),
          DataCell(Row(
            children: [
              IconButton(
                onPressed: () {
                  context
                      .read<UpdateInstanceProvider>()
                      .tryUpdateInstance(instance);
                  GoRouter.of(context).go('/instances/update');
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  context.read<InstancesProvider>().deleteInstance(instance);
                },
                icon: const Icon(Icons.delete),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_outlined),
              )
            ],
          ))
        ]);
  }

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
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
          child: Consumer<InstancesProvider>(
            builder: (context, instancesProvider, _) {
              instanceTableController.setCount(instancesProvider.instanceCount(
                  instanceTableController.searchTextController.text));

              final instacnes = instancesProvider.instances(
                  instanceTableController.searchTextController.text,
                  instanceTableController.pageSize,
                  instanceTableController.pageNumber);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    decoration: BoxDecoration(
                        border:
                            Border(bottom: Divider.createBorderSide(context))),
                    child: Row(
                      children: [
                        Text(
                          "数据源列表",
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 35,
                              height: 35,
                              child: FloatingActionButton.small(
                                elevation: 2,
                                onPressed: () =>
                                    GoRouter.of(context).go('/instances/add'),
                                child: const Icon(Icons.add),
                              ),
                            ),
                            const SizedBox(width: 15),
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
                        ))
                      ],
                    ),
                  ),
                  Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                          checkboxHorizontalMargin: 0,
                          showBottomBorder: true,
                          columns: column,
                          rows: instacnes.map((instance) {
                            return buildDataRow(instance);
                          }).toList(),
                          sortAscending: false,
                          showCheckboxColumn: true,
                          onSelectAll: (state) async {
                            setState(() {
                              if (state == null || !state) {
                                instanceTableController.selectedInstances
                                    .clear();
                              }
                            });
                            if (state != null && state) {
                              setState(() {
                                instanceTableController.selectedInstances
                                    .addAll(instacnes);
                              });
                            }
                          }),
                    ),
                  ),
                  TablePaginatedBar(controller: instanceTableController),
                  const Spacer(),
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

class InstanceTableController extends ChangeNotifier
    implements TablePageController {
  Set<InstanceModel> selectedInstances = {};
  TextEditingController searchTextController = TextEditingController(text: "");
  int currentPage = 1;
  int _count = 0;

  InstanceTableController();

  @override
  void onChange(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }

  void onSearchChange() {
    notifyListeners();
  }

  void setCount(int count) => _count = count;

  @override
  int get count => _count;

  @override
  int get pageSize => 10;

  @override
  int get pageNumber => currentPage;
}

InstanceTableController instanceTableController = InstanceTableController();
