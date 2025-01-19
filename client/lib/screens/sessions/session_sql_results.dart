import 'package:client/core/connection/result_set.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:client/models/sql_result.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
      selectedColor: Theme.of(context).colorScheme.surfaceContainerLow,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      hoverColor: Theme.of(context).colorScheme.surfaceContainer,
    );
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
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

class SqlResultTable extends StatefulWidget {
  const SqlResultTable({super.key});

  @override
  State<SqlResultTable> createState() => _SqlResultTableState();
}

class _SqlResultTableState extends State<SqlResultTable> {
  @override
  void initState() {
    super.initState();
  }

  List<PlutoColumn> buildColumns(List<ResultSetColumn> columns) {
    return columns
        .map<PlutoColumn>((e) => PlutoColumn(
            title: e.name,
            field: e.name,
            type: switch (e.type) {
              ValueType.str => PlutoColumnType.text(),
              ValueType.number => PlutoColumnType.number(),
              _ => PlutoColumnType.text(),
            },
            titleSpan: WidgetSpan(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: ValueTypeIcon(type: e.type, size: 20),
                  ),
                  Expanded(
                      child: Text(e.name, overflow: TextOverflow.ellipsis)),
                ],
              ),
            )))
        .toList();
  }

  List<PlutoRow> buildRows(List<ResultSetRow> rows) {
    return rows.map<PlutoRow>((e) {
      return PlutoRow(cells: <String, PlutoCell>{
        for (final v in e.cells) v.column.name: PlutoCell(value: v.value.summary())
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
      final result = sessionProvider.getCurrentSQLResult();
      if (sessionProvider.showRecord) {
        return Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: const Text('执行记录'));
      }
      if (result == null) {
        return Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: const Text('no data'));
      }
      if (result.state == SQLExecuteState.done) {
        return PlutoGrid(
          key: ObjectKey(result),
          mode: PlutoGridMode.selectWithOneTap,
          onSelected: (event) {
            sessionProvider.session!.metadataController.showSQLResult(
                result: result.resultSet!
                    .getValue(event.cell!.column.title, event.rowIdx!));
          },
          configuration: PlutoGridConfiguration(
            localeText: const PlutoGridLocaleText.china(),
            style: PlutoGridStyleConfig(
              rowHeight: 30,
              columnHeight: 36,
              gridBorderColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              rowColor: Theme.of(context).colorScheme.surfaceContainerLow,
              activatedColor: Theme.of(context).colorScheme.surfaceContainer,
              gridBackgroundColor : Theme.of(context).colorScheme.surfaceContainer,
            ),
          ),
          columns: buildColumns(result.resultSet!.columns),
          rows: buildRows(result.resultSet!.rows),
        );
      } else if (result.state == SQLExecuteState.error) {
        return Container(
            alignment: Alignment.topLeft,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Text('${result.error}'));
      } else {
        return Container(
            alignment: Alignment.topLeft,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: const Center(
              child: SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(),
              ),
            ));
      }
    });
  }
}
