import 'package:client/providers/session_sql_result.dart';
import 'package:client/providers/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:client/models/session_sql_result.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/utils/reorder_list.dart';

class SqlResultTables extends ConsumerWidget {
  const SqlResultTables({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SQLResultModel? sqlResult = ref.watch(sQLResultControllerProvider)!;
    ReorderSelectedList<SQLResultModel> sqlResults =
        ref.watch(sQLResultTabControllerProvider);

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

    // final results = sqlResults.getAllSQLResult();
    // final currentResult = session.getCurrentSQLResult();
    // final showRecord = session.showRecord;

    Widget tab;
    if (sqlResults.isEmpty) {
      tab = const Spacer();
    } else {
      tab = Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        CommonTab(
          label: "执行记录",
          selected: false, // todo
          width: 100,
          style: style,
          onTap: () {
            // session.selectToRecord();
          },
        ),
        Expanded(
            child: CommonTabBar(
                height: 35,
                color: Theme.of(context).colorScheme.surfaceContainer,
                tabStyle: style,
                onReorder: (oldIndex, newIndex) {
                  ref.read(sQLResultTabControllerProvider.notifier).reorderSQLResult(oldIndex, newIndex);
                },
                tabs: [
              for (var i = 0; i < sqlResults.length; i++)
                CommonTabWrap(
                  label: "${sqlResults[i].id + 1}",
                  selected: sqlResults[i] == sqlResult,
                  onTap: () {
                    ref.read(sQLResultTabControllerProvider.notifier).selectSQLResultByIndex(i);
                  },
                  onDeleted: () {
                    ref.read(sQLResultTabControllerProvider.notifier).deleteSQLResultByIndex(i);
                  },
                  avatar: const Icon(
                    Icons.grid_on,
                  ),
                )
            ]))
      ]);
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(maxHeight: 35),
                child: tab,
              ),
              const Expanded(child: SqlResultTable())
            ],
          ),
        ),
      ],
    );
  }
}

class SqlResultTable extends ConsumerWidget {
  const SqlResultTable({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
   SQLResultModel? sqlResult = ref.watch(sQLResultControllerProvider);

    final color = Theme.of(context)
        .colorScheme
        .surfaceContainerLow; // sql result body 的背景色

    if (sqlResult == null) {
      return Container(
          alignment: Alignment.center, color: color, child: const Text('执行记录'));
    }
    if (sqlResult == null) {
      return Container(
          alignment: Alignment.center,
          color: color,
          child: const Text('no data'));
    }
    if (sqlResult.state == SQLExecuteState.done) {
      return PlutoGrid(
        key: ObjectKey(sqlResult),
        mode: PlutoGridMode.selectWithOneTap,
        onSelected: (event) {
          ref.read(sessionDrawerControllerProvider.notifier).showSQLResult(
            result: sqlResult.rows![event.rowIdx!]
                .getValue(event.cell!.column.title),
            column: sqlResult.rows![event.rowIdx!]
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
        columns: buildColumns(sqlResult.columns!),
        rows: buildRows(sqlResult.rows!),
      );
    } else if (sqlResult.state == SQLExecuteState.error) {
      return Container(
          alignment: Alignment.topLeft,
          color: color,
          child: Text('${sqlResult.error}'));
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
  }
}
