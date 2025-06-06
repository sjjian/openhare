import 'package:client/core/conn.dart';
import 'package:client/models/interface.dart';
import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:client/services/session_sql_result.dart';
import 'package:client/services/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:sql_parser/parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_sql_results.g.dart';

@Riverpod(keepAlive: true)
CurrentSessionEditor sessionEditor(Ref ref, int sessionId) {
  return CurrentSessionEditor(code: CodeLineEditingController(
      spanBuilder: ({required codeLines, required context, required style}) {
    return TextSpan(
        children: Lexer(codeLines.asString(TextLineBreak.lf))
            .tokens()
            .map<TextSpan>((tok) => TextSpan(
                text: tok.content,
                style: style.merge(getStyle(tok.id) ?? style)))
            .toList());
  }));
}

@Riverpod(keepAlive: true)
class SessionEditorController extends _$SessionEditorController {
  @override
  CurrentSessionEditor build() {
    SelectedSessionId? sessionIdModel =
        ref.watch(selectedSessionIdServicesProvider);
    if (sessionIdModel == null) {
      return ref.watch(sessionEditorProvider(0));
    }
    return ref.watch(sessionEditorProvider(sessionIdModel.sessionId));
  }
}

class SqlResultTables extends ConsumerWidget {
  const SqlResultTables({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SQLResultsModel? sqlResultsModel =
        ref.watch(selectedSQLResultTabControllerProvider);

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

    Widget tab;
    if (sqlResultsModel == null) {
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
                  ref
                      .read(sQLResultsServicesProvider(
                              sqlResultsModel.sessionId)
                          .notifier)
                      .reorderSQLResult(oldIndex, newIndex);
                },
                tabs: [
              for (var i = 0; i < sqlResultsModel.sqlResults.length; i++)
                CommonTabWrap(
                  label: "${sqlResultsModel.sqlResults[i].id + 1}",
                  selected: sqlResultsModel.sqlResults
                      .isSelected(sqlResultsModel.sqlResults[i]),
                  onTap: () {
                    ref
                        .read(sQLResultsServicesProvider(
                                sqlResultsModel.sessionId)
                            .notifier)
                        .selectSQLResultByIndex(i);
                  },
                  onDeleted: () {
                    ref
                        .read(sQLResultsServicesProvider(
                                sqlResultsModel.sessionId)
                            .notifier)
                        .deleteSQLResultByIndex(i);
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
    final color = Theme.of(context)
        .colorScheme
        .surfaceContainerLow; // sql result body 的背景色

    SQLResultModel? sqlResultModel =
        ref.watch(selectedSQLResultControllerProvider);
    if (sqlResultModel == null) {
      return Container(
          alignment: Alignment.center,
          color: color,
          child: const Text('no data'));
    }
    if (sqlResultModel.result.state == SQLExecuteState.done) {
      return PlutoGrid(
        key: ObjectKey(sqlResultModel.result),
        mode: PlutoGridMode.selectWithOneTap,
        onSelected: (event) {
          ref.read(sessionDrawerControllerProvider.notifier).showSQLResult(
                result: sqlResultModel.result.data!.rows[event.rowIdx!]
                    .getValue(event.cell!.column.title),
                column: sqlResultModel.result.data!.rows[event.rowIdx!]
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
        columns: buildColumns(sqlResultModel.result.data!.columns),
        rows: buildRows(sqlResultModel.result.data!.rows),
      );
    } else if (sqlResultModel.result.state == SQLExecuteState.error) {
      return Container(
          alignment: Alignment.topLeft,
          color: color,
          child: Text('${sqlResultModel.result.error}'));
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
