import 'package:client/models/sessions.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/screens/code_edit.dart';
import 'package:client/screens/session_list.dart';
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
    print("sql edit page");
    final sessions = SessionsModel();
    final sessionProvider = SessionProvider(sessions.data.selected());
    final sessionListProvider = SessionListProvider(sessionProvider, sessions);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: sessionProvider),
          ChangeNotifierProvider.value(value: sessionListProvider),
        ],
        child: Row(children: [
          SplitView(
              controller: MultiSplitViewController(areas: [Area(size: 200)]),
              children: [
                const Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    SessionList(),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 30),
                    Expanded(
                      child: Container(
                          alignment: Alignment.topLeft,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: Column(
                            children: [
                              SplitView(axis: Axis.vertical, children: [
                                Consumer<SessionProvider>(
                                  builder: (context, sessionProvider, _) {
                                    return CodeEditor(
                                        key: UniqueKey(),
                                        codeController:
                                            sessionProvider.getSQLEditCode());
                                  },
                                ),
                                const Expanded(child: SqlResultTables()),
                              ]),
                            ],
                          )),
                    ),
                    const SizedBox(height: 30)
                  ],
                )
              ]),
          const SizedBox(width: 5),
        ]));
  }
}

class SqlResultTables extends StatefulWidget {
  const SqlResultTables({Key? key}) : super(key: key);

  @override
  State<SqlResultTables> createState() => _SqlResultTablesState();
}

class _SqlResultTablesState extends State<SqlResultTables> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          constraints: const BoxConstraints(maxHeight: 40),
          decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey))),
          child: Consumer<SessionProvider>(
            builder: (context, sessionProvider, _) {
              final results = sessionProvider.getAllSQLResult();
              final currentResult = sessionProvider.getCurrentSQLResult();
              if (results == null) {
                return const Spacer();
              }
              return ReorderableListView(
                  buildDefaultDragHandles: false,
                  scrollDirection: Axis.horizontal,
                  onReorder: (oldIndex, newIndex) {
                    sessionProvider.reorderSQLResult(oldIndex, newIndex);
                  },
                  children: [
                    for (var i = 0; i < results.length; i++)
                      ReorderableDragStartListener(
                          index: i,
                          key: ValueKey(i),
                          child: RawChip(
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            selectedColor: Colors.white,
                            selected: results[i] == currentResult,
                            avatar: const Icon(
                              Icons.grid_on,
                              color: Colors.black,
                            ),
                            label: Text("${results[i].id + 1}"),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 16,
                            ),
                            onDeleted: () {
                              sessionProvider.deleteSQLResultByIndex(i);
                            },
                            onPressed: () {
                              sessionProvider.selectSQLResultByIndex(i);
                            },
                          ))
                  ]);
            },
          ),
        ),
        const Expanded(child: SqlResultTable())
      ],
    );
    ;
  }
}
