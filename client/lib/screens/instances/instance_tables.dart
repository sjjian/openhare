import 'package:client/models/instances.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/widgets/paginated_bar.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'instance_tables.g.dart';

@Riverpod(keepAlive: true)
class InstancesNotifier extends _$InstancesNotifier {
  @override
  PaginationInstanceListModel build() {
    return ref
        .read(instancesServicesProvider.notifier)
        .instances("", pageNumber: 1, pageSize: 10);
  }

  void changePage(String key, {int? pageNumber, int? pageSize}) {
    state = ref
        .read(instancesServicesProvider.notifier)
        .instances(key, pageNumber: pageNumber, pageSize: pageSize);
  }
}

TextEditingController searchTextController = TextEditingController(text: "");

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

class InstanceTable extends ConsumerStatefulWidget {
  const InstanceTable({super.key});

  @override
  ConsumerState<InstanceTable> createState() => _InstanceTableState();
}

class _InstanceTableState extends ConsumerState<InstanceTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // instanceTableController.removeListener(() {});
    super.dispose();
  }

  DataRow buildDataRow(InstanceModel instance) {
    return DataRow(
        // selected: instanceTableController.selectedInstances.contains(instance),
        // onSelectChanged: (state) {
        //   setState(() {
        //     if (state == null || !state) {
        //       instanceTableController.selectedInstances.remove(instance);
        //     } else {
        //       instanceTableController.selectedInstances.add(instance);
        //     }
        //   });
        // },
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
                  // todo
                  // context
                  //     .read<UpdateInstanceProvider>()
                  //     .tryUpdateInstance(instance);
                  // GoRouter.of(context).go('/instances/update');
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  ref
                      .read(instancesServicesProvider.notifier)
                      .deleteInstance(instance.id);
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

    final model = ref.watch(instancesNotifierProvider);

    return Row(
      children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                decoration: BoxDecoration(
                    border: Border(bottom: Divider.createBorderSide(context))),
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
                              controller: searchTextController,
                              onChanged: (value) {
                                ref
                                    .read(instancesNotifierProvider.notifier)
                                    .changePage(value,
                                        pageNumber: model.currentPage,
                                        pageSize: model.pageSize);
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
                      rows: model.instances.map((instance) {
                        return buildDataRow(instance);
                      }).toList(),
                      sortAscending: false,
                      showCheckboxColumn: true,
                      onSelectAll: (state) async {
                        // setState(() {
                        //   if (state == null || !state) {
                        //     instanceTableController.selectedInstances.clear();
                        //   }
                        // });
                        // if (state != null && state) {
                        //   setState(() {
                        //     instanceTableController.selectedInstances
                        //         .addAll(model.instances);
                        //   });
                        // }
                      }),
                ),
              ),
              TablePaginatedBar(
                  count: model.count,
                  pageSize: model.pageSize,
                  pageNumber: model.currentPage,
                  onChange: (pageNumber) {
                    ref.read(instancesNotifierProvider.notifier).changePage(
                        searchTextController.text,
                        pageNumber: pageNumber,
                        pageSize: model.pageSize);
                  }),
              const Spacer(),
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

// class InstanceTableController extends ChangeNotifier
//     implements TablePageController {
//   Set<InstanceModel> selectedInstances = {};
//   TextEditingController searchTextController = TextEditingController(text: "");
//   int currentPage = 1;
//   int _count = 0;

//   InstanceTableController();

//   @override
//   void onChange(int pageNumber) {
//     currentPage = pageNumber;
//     notifyListeners();
//   }

//   void onSearchChange() {
//     notifyListeners();
//   }

//   void setCount(int count) => _count = count;

//   @override
//   int get count => _count;

//   @override
//   int get pageSize => 10;

//   @override
//   int get pageNumber => currentPage;
// }

// InstanceTableController instanceTableController = InstanceTableController();
