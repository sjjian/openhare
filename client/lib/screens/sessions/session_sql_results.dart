import 'package:db_driver/db_driver.dart';
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
      selectedColor: Theme.of(context)
          .colorScheme
          .surfaceContainerLow, // sql result tab 的选中颜色
      color:
          Theme.of(context).colorScheme.surfaceContainer, // sql result tab 的背景色
      hoverColor: Theme.of(context)
          .colorScheme
          .surfaceContainer, // sql result tab 的鼠标移入色
    );
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(maxHeight: 35),
                child: Consumer<SessionProvider>(
                  builder: (context, sessionProvider, _) {
                    final results = sessionProvider.session!.getAllSQLResult();
                    final currentResult = sessionProvider.session!.getCurrentSQLResult();
                    final showRecord = sessionProvider.session!.showRecord;
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
                                      .surfaceContainer,
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

  List<PlutoColumn> buildColumns(List<BaseQueryColumn> columns) {
    return columns
        .map<PlutoColumn>((e) => PlutoColumn(
            title: e.name,
            field: e.name,
            type: switch (e.dataType()) {
              DataType.number => PlutoColumnType.number(),
              _ => PlutoColumnType.text(),
            },
            titleSpan: WidgetSpan(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: DataTypeIcon(type: e.dataType(), size: 20),
                  ),
                  Expanded(
                      child: Text(e.name, overflow: TextOverflow.ellipsis)),
                ],
              ),
            )))
        .toList();
  }

  List<PlutoRow> buildRows(List<QueryResultRow> rows) {
    return rows.map<PlutoRow>((e) {
      return PlutoRow(cells: <String, PlutoCell>{
        for (int i = 0; i < e.columns.length; i++)
          e.columns[i].name: PlutoCell(value: e.values[i].getSummary())
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
      final color = Theme.of(context)
          .colorScheme
          .surfaceContainerLow; // sql result body 的背景色
      final result = sessionProvider.session!.getCurrentSQLResult();
      if (sessionProvider.session!.showRecord) {
        return Container(
            alignment: Alignment.center,
            color: color,
            child: const Text('执行记录'));
      }
      if (result == null) {
        return Container(
            alignment: Alignment.center,
            color: color,
            child: const Text('no data'));
      }
      if (result.state == SQLExecuteState.done) {
        return PlutoGrid(
          key: ObjectKey(result),
          mode: PlutoGridMode.selectWithOneTap,
          onSelected: (event) {
            sessionProvider.showSQLResult(
              result: result.rows![event.rowIdx!]
                  .getValue(event.cell!.column.title),
              column: result.rows![event.rowIdx!]
                  .getColumn(event.cell!.column.title), 
            );
          },
          configuration: PlutoGridConfiguration(
            localeText: const PlutoGridLocaleText.china(),
            style: PlutoGridStyleConfig(
              rowHeight: 30,
              columnHeight: 36,
              gridBorderColor: color,
              rowColor: color,
              activatedColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainer, // sql result table 行选中的颜色
              gridBackgroundColor: color,
            ),
          ),
          columns: buildColumns(result.columns!),
          rows: buildRows(result.rows!),
        );
      } else if (result.state == SQLExecuteState.error) {
        return Container(
            alignment: Alignment.topLeft,
            color: color,
            child: Text('${result.error}'));
      } else {
        return Container(
            alignment: Alignment.topLeft,
            color: color,
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
