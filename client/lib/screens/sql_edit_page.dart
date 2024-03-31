import 'package:client/models/connection.dart';
import 'package:client/screens/code_edit.dart';
import 'package:client/screens/instance_list.dart';
import 'package:client/widgets/split_view.dart';
import 'package:client/widgets/sql_result_table.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';

class SQLEditPage extends StatefulWidget {
  const SQLEditPage({super.key});

  @override
  State<SQLEditPage> createState() => _SQLEditPageState();
}

class _SQLEditPageState extends State<SQLEditPage> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SplitView(
          controller: MultiSplitViewController(areas: [Area(size: 200)]),
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                InstanceList()
              ],
            ),
            ChangeNotifierProvider(
                create: (_) => SessionModel(),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Expanded(
                      child: Container(
                          alignment: Alignment.topLeft,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: const Column(
                            children: [
                              SplitView(axis: Axis.vertical, children: [
                                CodeEditor(),
                                Expanded(child: SqlResultTables()),
                              ]),
                            ],
                          )),
                    ),
                    const SizedBox(height: 30)
                  ],
                ))
          ]),
      const SizedBox(width: 5),
    ]);
  }
}

class SqlResultTables extends StatefulWidget {
  const SqlResultTables({Key? key}) : super(key: key);

  @override
  _SqlResultTablesState createState() => _SqlResultTablesState();
}

class _SqlResultTablesState extends State<SqlResultTables> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SessionModel>(builder: (context, sessionModel, _) {
      return Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            constraints: const BoxConstraints(maxHeight: 40),
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.grey),
                    bottom: BorderSide(color: Colors.grey))),
            child: ReorderableListView(
                buildDefaultDragHandles: false,
                scrollDirection: Axis.horizontal,
                onReorder: (oldIndex, newIndex) {
                  sessionModel.reorderResult(oldIndex, newIndex);
                },
                children: sessionModel.results.map((result) {
                  final index = sessionModel.results.indexOf(result);
                  return ReorderableDragStartListener(
                      index: index,
                      key: ValueKey(index),
                      child: RawChip(
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        selectedColor: Colors.white,
                        selected: result == sessionModel.currentResult,
                        avatar: const Icon(
                          Icons.grid_on,
                          color: Colors.black,
                        ),
                        label: Text("${result.id + 1}"),
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 16,
                        ),
                        onDeleted: () {
                          sessionModel.deleteResultByIndex(index);
                        },
                        onPressed: () {
                          sessionModel.selectResultByIndex(index);
                        },
                      ));
                }).toList()),
          ),
          Expanded(
              child: SqlResultTable(result: sessionModel.getCurrentSQLResult()))
        ],
      );
    });
  }
}
