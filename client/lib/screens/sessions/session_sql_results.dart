import 'package:client/providers/sessions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/widgets/sql_result_table.dart';
import 'package:client/widgets/tab_widget.dart';

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
      color: Theme.of(context).colorScheme.surfaceContainer,
      hoverColor: Theme.of(context).colorScheme.surfaceContainerLow,
    );
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(maxHeight: 35),
                child: Consumer<SessionProvider>(
                  builder: (context, sessionProvider, _) {
                    final results = sessionProvider.getAllSQLResult();
                    final currentResult = sessionProvider.getCurrentSQLResult();
                    final showRecord = sessionProvider.showRecord;
                    if (results == null) {
                      return const Spacer();
                    }
                    return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CommonTab(
                            label: "执行记录",
                            selected: showRecord,
                            width: 100,
                            style: style,
                            onTap: () {
                              sessionProvider.selectToRecord();
                            },
                          ),
                          Expanded(
                              child: CommonTabBar(
                                  height: 35,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLow,
                                  tabStyle: style,
                                  onReorder: (oldIndex, newIndex) {
                                    sessionProvider.reorderSQLResult(
                                        oldIndex, newIndex);
                                  },
                                  tabs: [
                                for (var i = 0; i < results.length; i++)
                                  CommonTabWrap(
                                    label: "${results[i].id + 1}",
                                    selected: !showRecord &&
                                        results[i] == currentResult,
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
          ),
        ),
      ],
    );
  }
}