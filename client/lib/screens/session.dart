import 'package:client/providers/sessions.dart';
import 'package:client/screens/code_edit.dart';
import 'package:client/screens/session_list.dart';
import 'package:client/widgets/split_view.dart';
import 'package:client/widgets/sql_result_table.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';

final multiSplitViewCtrl1 = MultiSplitViewController(areas: [Area(size: 200)]);
final multiSplitViewCtrl2 = MultiSplitViewController();

class SQLEditPage extends StatefulWidget {
  const SQLEditPage({super.key});

  @override
  State<SQLEditPage> createState() => _SQLEditPageState();
}

class _SQLEditPageState extends State<SQLEditPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SessionList(),
        Expanded(
            child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        SplitView(
                            controller: multiSplitViewCtrl2,
                            axis: Axis.vertical,
                            children: [
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
          ),
        )),
      ],
    );
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
    CommonTabStyle style = CommonTabStyle(
      maxWidth: 100,
      labelAlign: TextAlign.center,
      selectedColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      hoverColor: Theme.of(context).colorScheme.surfaceContainerLow,
    );
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          alignment: Alignment.centerLeft,
          constraints: const BoxConstraints(maxHeight: 40),
          child: Consumer<SessionProvider>(
            builder: (context, sessionProvider, _) {
              final results = sessionProvider.getAllSQLResult();
              final currentResult = sessionProvider.getCurrentSQLResult();
              if (results == null) {
                return const Spacer();
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                CommonTab(
                  label: "执行记录",
                  selected: true,
                  width: 100,
                  style: style,
                ),
                Expanded(
                    child: CommonTabBar(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        tabStyle: style,
                        onReorder: (oldIndex, newIndex) {
                          sessionProvider.reorderSQLResult(oldIndex, newIndex);
                        },
                        tabs: [
                      for (var i = 0; i < results.length; i++)
                        CommonTabWrap(
                          label: "${results[i].id + 1}",
                          selected: results[i] == currentResult,
                          onTap: () {
                            sessionProvider.selectSQLResultByIndex(i);
                          },
                          onDeleted: () {
                            sessionProvider.deleteSQLResultByIndex(i);
                          },
                          avatar: const Icon(
                            Icons.grid_on,
                          ),
                        )
                    ]))
              ]);
            },
          ),
        ),
        const Expanded(child: SqlResultTable())
      ],
    );
  }
}
