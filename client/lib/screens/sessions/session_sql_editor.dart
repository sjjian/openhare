import 'package:client/providers/sessions.dart';
import 'package:client/widgets/hover_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:provider/provider.dart';
import 'package:client/widgets/split_view.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:client/widgets/sql_result_table.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:common/parser.dart';

final multiSplitViewCtrl = MultiSplitViewController();

class SqlEditor extends StatefulWidget {
  const SqlEditor({Key? key}) : super(key: key);

  @override
  State<SqlEditor> createState() => _SqlEditorState();
}

class _SqlEditorState extends State<SqlEditor> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            SplitView(
                controller: multiSplitViewCtrl,
                axis: Axis.vertical,
                children: [
                  Consumer<SessionProvider>(
                    builder: (context, sessionProvider, _) {
                      return CodeEditor(
                          key: UniqueKey(),
                          codeController: sessionProvider.getSQLEditCode());
                    },
                  ),
                  const Expanded(child: SqlResultTables()),
                ]),
          ],
        ));
  }
}

class CodeEditor extends StatefulWidget {
  final CodeController codeController;

  const CodeEditor({super.key, required this.codeController});

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      Widget codeField = Expanded(
          child: CodeTheme(
        data: const CodeThemeData(styles: a11yLightTheme),
        child: CodeField(
          expands: true,
          controller: widget.codeController,
          textStyle: const TextStyle(fontFamily: 'SourceCode'),
        ),
      ));

      Widget codeButton = Container(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        constraints: const BoxConstraints(maxHeight: 40),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
            final canQuery = sessionProvider.canQuery();
            return IconButton(
                alignment: Alignment.topLeft,
                onPressed: canQuery
                    ? () {
                        var content = widget.codeController.text.toString();
                        List<String> querys = Splitter(content, ";").split();
                        TextSelection s = widget.codeController.selection;

                        String query;
                        // 当界面手动选中了文本片段则仅执行该片段，当前还不支持多SQL执行.
                        if (!s.isCollapsed) {
                          query = widget.codeController.text
                              .toString()
                              .substring(s.start, s.end);
                        } else {
                          // 当前界面未选中SQL, 则当前游标在哪个SQL片段内就执行哪个SQL. todo: 移动到通用的地方.
                          int totalLength = 0;
                          query = querys.firstWhere((query) {
                            totalLength = totalLength + query.length;
                            if (s.start <= totalLength) {
                              return true;
                            } else {
                              return false;
                            }
                          }, orElse: () => "");
                        }
                        if (query.trim().isNotEmpty) {
                          sessionProvider.query(query);
                        }
                      }
                    : null,
                icon: Icon(Icons.play_arrow_rounded,
                    size: 36, color: canQuery ? Colors.green : Colors.grey));
          }),
          HoverIconButton(onTap: () => print(1), icon: Icons.play_arrow_rounded)
        ]),
      );

      if (c.maxHeight <= 40) {
        codeButton = Expanded(child: codeButton);
        return Column(children: [codeButton]);
      } else {
        return Column(
          children: [codeField, codeButton],
        );
      }
    });
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
              final showRecord = sessionProvider.showRecord;
              if (results == null) {
                return const Spacer();
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
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
                          selected: !showRecord && results[i] == currentResult,
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
