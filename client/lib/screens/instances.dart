import 'package:client/providers/instances.dart';
import 'package:client/screens/app.dart';
import 'package:client/screens/settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaginatedDataTablePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PaginatedPageState();
}

class _PaginatedPageState extends State<PaginatedDataTablePage> {
  InstancesProvider _instances = InstancesProvider();
  var _rowsPerPage = 8;
  int _sortColumnIndex = 1;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTableTheme(
          data: DataTableThemeData(
              dataRowColor: MaterialStateProperty.all(Colors.white),
              headingRowColor: MaterialStateProperty.all(Colors.white)),
          child: PaginatedDataTable(
            header: const Text('数据源列表'),
            primary: true,
            // actions: [Icon(Icons.refresh), Icon(Icons.clear)],
            headingRowHeight: 50.0,
            rowsPerPage: _rowsPerPage,
            onPageChanged: (i) => print('onPageChanged -> $i'),
            availableRowsPerPage: [8, 16, 20],
            onRowsPerPageChanged: (value) =>
                setState(() => _rowsPerPage = value!),
            sortAscending: _sortAscending,
            sortColumnIndex: 1,
            showCheckboxColumn: true,
            onSelectAll: (state) =>
                setState(() => _instances.selectAll(state!)),
            columns: [
              const DataColumn(label: Text('Avatar')),
              DataColumn(
                  label: Text('ID'),
                  onSort: (index, sortAscending) {
                    setState(() {
                      _sortAscending = sortAscending;
                      _instances.sortData((map) => map['id'], sortAscending);
                    });
                  }),
              const DataColumn(label: Text('Name')),
              const DataColumn(
                  label: Row(children: [
                Text('Price'),
                SizedBox(width: 5.0),
                Icon(Icons.airplanemode_active)
              ])),
              const DataColumn(label: Text('No.')),
              const DataColumn(label: Text('Address'))
            ],
            source: _instances,
          )),
    );
  }
}

class DataTablePage extends StatefulWidget {
  @override
  State<DataTablePage> createState() => _DataTablePageState();
}

class _DataTablePageState extends State<DataTablePage> {
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
                    Text(
                      "数据源列表",
                      style: TextStyle(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                    IconButton(
                        onPressed: () {
                          print(1);
                          GoRouter.of(context).go('/instances/create');
                        },
                        icon: Icon(Icons.add))
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
                    child: DataTable(
                      checkboxHorizontalMargin: 0,
                      columns: const [
                        DataColumn(label: Text("名称")),
                        DataColumn(label: Text("地址")),
                        DataColumn(label: Text("端口")),
                        DataColumn(label: Text("用户名")),
                        DataColumn(label: Text("密码")),
                        DataColumn(label: Text("操作"))
                      ],
                      rows: [
                        for (var i = 0; i < 10; i++)
                          DataRow(
                              onSelectChanged: (value) {
                                print("row select: ${value}");
                              },
                              cells: [
                                const DataCell(Text("aaa")),
                                const DataCell(Text("aaa")),
                                const DataCell(Text("aaa")),
                                const DataCell(Text("aaa")),
                                const DataCell(Text("aaa")),
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
                                      icon:
                                          const Icon(Icons.more_vert_outlined),
                                    )
                                  ],
                                ))
                              ]),
                      ],
                      sortAscending: false,
                      showCheckboxColumn: true,
                      onSelectAll: (state) {}
                          // setState(() => _instances.selectAll(state!)),
                    ),
                  ),
                ),
              ))
            ],
          ),
        )),
        // Drawer(child: Text("i am a drawer"),)
      ],
    );
  }
}

class CreateInstance extends StatefulWidget {
  const CreateInstance({ Key? key }) : super(key: key);

  @override
  State<CreateInstance> createState() => _CreateInstancesState();
}

class _CreateInstancesState extends State<CreateInstance> {
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
                child: const Text(
                  "添加数据源",
                  style: TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                  onPressed: () {
                    print(2);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.add))
            ],
          ),
        ))
      ],
    );
  }
}