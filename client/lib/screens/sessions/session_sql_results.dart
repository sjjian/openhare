import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/loading.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SqlResultTables extends ConsumerWidget {
  const SqlResultTables({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionSQLResultsModel? model =
        ref.watch(selectedSQLResultTabNotifierProvider);
    CommonTabStyle style = CommonTabStyle(
      maxWidth: 100,
      minWidth: 90,
      labelAlign: TextAlign.center,
      selectedColor:
          Theme.of(context).colorScheme.surfaceContainerLowest, // sql result tab 的选中颜色
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerLow, // sql result tab 的背景色
      hoverColor:
          Theme.of(context).colorScheme.surfaceContainerLowest, // sql result tab 的鼠标移入色
    );

    Widget tab = Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: CommonTabBar(
          height: 36,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerLow, // CommonTabBar 背景色
          tabStyle: style,
          onReorder: (oldIndex, newIndex) {
            final sqlResultsServices =
                ref.read(sQLResultsServicesProvider.notifier);

            sqlResultsServices.reorderSQLResult(
                model!.sessionId, oldIndex, newIndex);
          },
          tabs: (model != null)
              ? [
                  for (var i = 0; i < model.results.length; i++)
                    CommonTabWrap(
                      label: "${model.results[i].resultId.value}",
                      selected: model.results[i] == model.selected,
                      onTap: () {
                        final sqlResultsServices =
                            ref.read(sQLResultsServicesProvider.notifier);

                        sqlResultsServices
                            .selectSQLResult(model.results[i].resultId);
                      },
                      onDeleted: () {
                        final sqlResultsServices =
                            ref.read(sQLResultsServicesProvider.notifier);
                        sqlResultsServices
                            .deleteSQLResult(model.results[i].resultId);
                      },
                      avatar: (model.results[i] != model.selected &&
                              model.results[i].state == SQLExecuteState.init)
                          ? const Loading.small()
                          : const Icon(
                              size: kIconSizeTiny,
                              Icons.grid_on,
                            ),
                    ),
                ]
              : [],
        ),
      )
    ]);

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(maxHeight: 32),
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
                    padding: const EdgeInsets.only(right: kSpacingTiny),
                    child: DataTypeIcon(
                      type: e.dataType(),
                      size: kIconSizeSmall,
                    ),
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
    final color =
        Theme.of(context).colorScheme.surfaceContainerLowest; // sql result body 的背景色

    final model = ref.watch(selectedSQLResultNotifierProvider);
    if (model == null) {
      return Container(
          alignment: Alignment.center,
          color: color,
          child: Text(AppLocalizations.of(context)!.display_msg_no_data));
    }
    if (model.state == SQLExecuteState.done) {
      return PlutoGrid(
        key: ObjectKey(model),
        mode: PlutoGridMode.selectWithOneTap,
        onSelected: (event) {
          ref.read(sessionDrawerNotifierProvider.notifier).showSQLResult(
                result: model.data!.rows[event.rowIdx!]
                    .getValue(event.cell!.column.title),
                column: model.data!.rows[event.rowIdx!]
                    .getColumn(event.cell!.column.title),
              );
        },
        configuration: PlutoGridConfiguration(
          localeText: AppLocalizations.of(context)!.localeName == "zh"
              ? const PlutoGridLocaleText.china()
              : const PlutoGridLocaleText(),
          style: PlutoGridStyleConfig(
            rowHeight: 24,
            columnHeight: 32,
            gridBorderColor: color,
            rowColor: color,
            activatedColor: Theme.of(context)
                .colorScheme
                .surfaceContainer, // sql result table 行选中的颜色
            gridBackgroundColor: color,
            cellTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        columns: buildColumns(model.data!.columns),
        rows: buildRows(model.data!.rows),
      );
    } else if (model.state == SQLExecuteState.error) {
      return Container(
          alignment: Alignment.topLeft,
          color: color,
          child: Text('${model.error}'));
    } else {
      return Container(
        alignment: Alignment.topLeft,
        color: color,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Loading.big(),
              const SizedBox(height: kSpacingMedium),
              FilledButton(
                  onPressed: () async {
                    SessionDetailModel? sessionModel = ref
                        .read(sessionsServicesProvider.notifier)
                        .getSession(model.resultId.sessionId);

                    if (sessionModel == null || sessionModel.connId == null) {
                      return;
                    }
                    await ref
                        .read(sessionConnsServicesProvider.notifier)
                        .killQuery(sessionModel.connId!);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel))
            ],
          ),
        ),
      );
    }
  }
}
