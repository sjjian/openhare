import 'package:client/models/sessions.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/screens/code_edit.dart';
import 'package:client/screens/session_tile.dart';
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
    final sessions = SessionsModel();
    final sessionProvider = SessionProvider(sessions.current);
    final sessionTileProvider = SessionTileProvider(sessionProvider, sessions);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: sessionProvider),
          ChangeNotifierProvider.value(value: sessionTileProvider),
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
                    SessionTileList(),
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
                  children: results.map((result) {
                    final index = results.indexOf(result);
                    return ReorderableDragStartListener(
                        index: index,
                        key: ValueKey(index),
                        child: RawChip(
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          selectedColor: Colors.white,
                          selected: result == currentResult,
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
                            sessionProvider.deleteSQLResultByIndex(index);
                          },
                          onPressed: () {
                            sessionProvider.selectSQLResultByIndex(index);
                          },
                        ));
                  }).toList());
            },
          ),
        ),
        const Expanded(child: SqlResultTable())
      ],
    );
    ;
  }
}
