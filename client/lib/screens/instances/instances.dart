import 'package:client/models/instances.dart';
import 'package:client/providers/instances.dart';
import 'package:client/screens/instances/add_instance.dart';
import 'package:client/widgets/paginated_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InstancesPage extends StatefulWidget {
  const InstancesPage({super.key});

  @override
  State<InstancesPage> createState() => _InstancesPageState();
}

class _InstancesPageState extends State<InstancesPage> {
  @override
  void initState() {
    super.initState();
    pageController.addListener(() => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    pageController.removeListener(() {});
    super.dispose();
  }

  DataRow buildDataRow(InstanceModel instance) {
    return DataRow(
        selected: pageController.selectedInstances.contains(instance),
        onSelectChanged: (state) {
          setState(() {
            if (state == null || !state) {
              pageController.selectedInstances.remove(instance);
            } else {
              pageController.selectedInstances.add(instance);
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
              pageController.setCount(
                  instancesProvider.instanceCount(pageController.searchKey));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(5, 20, 20, 10),
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
                                onPressed: () => {
                                  AddInstancePage.showAddInstanceDialog(context)
                                },
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
                                  onChanged: (value) {
                                    pageController.setSearchKey(value);
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
                          rows: instancesProvider
                              .instances(
                                  pageController.searchKey,
                                  pageController.pageSize,
                                  pageController.pageNumber)
                              .map((instance) {
                            return buildDataRow(instance);
                          }).toList(),
                          sortAscending: false,
                          showCheckboxColumn: true,
                          onSelectAll: (state) {
                            setState(() {
                              if (state == null || !state) {
                                pageController.selectedInstances.clear();
                              } else {
                                pageController.selectedInstances.addAll(
                                    instancesProvider.instances(
                                        pageController.searchKey,
                                        pageController.pageSize,
                                        pageController.currentPage));
                              }
                            });
                          }),
                    ),
                  ),
                  TablePaginatedBar(controller: pageController),
                  const Expanded(child: Spacer()),
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

class PageController extends ChangeNotifier implements TablePageController {
  Set<InstanceModel> selectedInstances = {};
  String searchKey = "";
  int currentPage = 1;
  int _count = 0;

  PageController();

  @override
  void onChange(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }

  void setSearchKey(String key) {
    searchKey = key;
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

PageController pageController = PageController();
