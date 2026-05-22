import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/services/sessions/session_drawer.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/data_grid.dart';
import 'package:client/widgets/empty.dart';
import 'package:client/widgets/loading.dart';
import 'package:client/widgets/tooltip.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/widgets/divider.dart';
import 'package:client/services/sessions/session_controller.dart';

class SqlResultTables extends ConsumerWidget {
  const SqlResultTables({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionSQLResultsModel? model = ref.watch(selectedSQLResultTabProvider);
    CommonTabStyle style = CommonTabStyle(
      maxWidth: 100,
      minWidth: 90,
      labelAlign: TextAlign.center,
      color: Theme.of(context).colorScheme.surfaceContainerLow, // sql result tab 的背景色
      selectedColor: Theme.of(context).colorScheme.surfaceContainerHigh, // sql result tab 的选中颜色
      hoverColor: Theme.of(context).colorScheme.surfaceContainer, // sql result tab 的鼠标移入色
    );

    Widget tab = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: CommonTabBar(
            height: 36,
            tabStyle: style,
            onReorder: (oldIndex, newIndex) {
              final sqlResultsServices = ref.read(sQLResultsServicesProvider.notifier);

              sqlResultsServices.reorderSQLResult(model!.sessionId, oldIndex, newIndex);
            },
            tabs: (model != null)
                ? [
                    for (var i = 0; i < model.results.length; i++)
                      CommonTabWrap(
                        label: "${model.results[i].resultId.value}",
                        selected: model.results[i] == model.selected,
                        onTap: () {
                          final sqlResultsServices = ref.read(sQLResultsServicesProvider.notifier);

                          sqlResultsServices.selectSQLResult(model.results[i].resultId);
                        },
                        onDeleted: () {
                          final sqlResultsServices = ref.read(sQLResultsServicesProvider.notifier);
                          sqlResultsServices.deleteSQLResult(model.results[i].resultId);
                        },
                        avatar: (model.results[i] != model.selected && model.results[i].state == SQLExecuteState.init)
                            ? const Loading.small()
                            : const Icon(
                                size: kIconSizeSmall,
                                Icons.grid_on,
                              ),
                      ),
                  ]
                : [],
          ),
        ),
        const SizedBox(width: kSpacingTiny / 2),
      ],
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(maxHeight: 32),
                child: tab,
              ),
              const SizedBox(height: kSpacingTiny),
              const PixelDivider(),
              const Expanded(child: SqlResultTable()),
            ],
          ),
        ),
      ],
    );
  }
}

class SqlResultTable extends ConsumerWidget {
  const SqlResultTable({super.key});

  List<DataGridColumn> buildColumns(
    BuildContext context,
    List<BaseQueryColumn> columns,
    List<QueryResultRow> rows,
  ) {
    List<DataGridColumn> result = [];
    for (int i = 0; i < columns.length; i++) {
      final column = columns[i];
      result.add(
        DataGridColumn.autoSize(
          context: context,
          name: column.name,
          dataType: column.dataType(),
          cells: <DataGridCell>[
            for (int j = 0; j < rows.length; j++)
              DataGridCell(
                data: rows[j].values[i].getSummary() ?? '',
              ),
          ],
        ),
      );
    }
    return result;
  }

  Widget buildEmptyBody(BuildContext context) {
    return EmptyPage(
      child: Text(
        AppLocalizations.of(context)!.display_msg_no_data,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), // 没有数据时显示的文字颜色
      ),
    );
  }

  Widget buildSuccessBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 48,
            color: Theme.of(context).colorScheme.primaryContainer, // SQL执行成功图标颜色
          ),
          const SizedBox(height: kSpacingSmall),
          Text(AppLocalizations.of(context)!.display_msg_execution_success),
        ],
      ),
    );
  }

  Widget buildErrorBody(BuildContext context, SQLResultDetailModel model) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpacingLarge, kSpacingSmall, kSpacingLarge, kSpacingSmall),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 48,
              color: Theme.of(context).colorScheme.errorContainer, // SQL执行错误时图标颜色
            ),
            const SizedBox(height: kSpacingMedium),
            TooltipText(text: '${model.error}${model.query}'),
          ],
        ),
      ),
    );
  }

  Widget buildCancelBody(BuildContext context, SQLResultDetailModel model) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpacingLarge, kSpacingSmall, kSpacingLarge, kSpacingSmall),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 48,
              color: const Color.fromARGB(255, 241, 192, 84), // todo: 颜色统一放, 目前和 explain 按钮使用同样颜色
            ),
            const SizedBox(height: kSpacingMedium),
            Text(
              l10n.display_msg_execution_cancelled,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWaitingBody(BuildContext context, WidgetRef ref, SQLResultDetailModel model) {
    final ConnId? connId = model.connId;
    final bool canKill = connId != null && model.canKill;

    return Container(
      alignment: Alignment.topLeft,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Loading.large(),
            if (canKill) ...[
              const SizedBox(height: kSpacingMedium),
              FilledButton(
                onPressed: () async {
                  await ref.read(sessionConnsServicesProvider.notifier).killQuery(connId);
                },
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(selectedSQLResultProvider);
    if (model == null) {
      return buildEmptyBody(context);
    }
    if (model.state == SQLExecuteState.done) {
      // 非查询语句没有返回值，此时展示空页面
      if (model.data!.columns.isEmpty) {
        return buildSuccessBody(context);
      }
      final controller = SQLResultController.sqlResultController(
        model.resultId,
        () => DataGridController(
          columns: buildColumns(context, model.data!.columns, model.data!.rows),
        ),
      );
      return DataGrid(
        key: ValueKey(model.resultId),
        controller: controller.controller,
        horizontalScrollGroup: controller.horizontalScrollGroup,
        verticalScrollGroup: controller.verticalScrollGroup,
        onCellTap: (postion) {
          ref
              .read(sessionDrawerServicesProvider(model.resultId.sessionId).notifier)
              .showSQLResult(
                result: model.data!.rows[postion.rowIndex].values[postion.columnIndex],
                column: model.data!.rows[postion.rowIndex].columns[postion.columnIndex],
              );
        },
      );
    } else if (model.state == SQLExecuteState.error) {
      return buildErrorBody(context, model);
    } else if (model.state == SQLExecuteState.cancel) {
      return buildCancelBody(context, model);
    } else {
      return buildWaitingBody(context, ref, model);
    }
  }
}
