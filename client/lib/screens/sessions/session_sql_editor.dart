import 'package:client/providers/sessions.dart';
import 'package:client/screens/sessions/session_sql_editor_bar.dart';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:provider/provider.dart';
import 'package:client/widgets/split_view.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:client/widgets/sql_result_table.dart';
import 'package:client/widgets/tab_widget.dart';

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
                          key: ValueKey(sessionProvider.getSQLEditCode()),
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
          lineNumberStyle: LineNumberStyle(
              background: Theme.of(context).colorScheme.surfaceContainerLow),
          expands: true,
          controller: widget.codeController,
          textStyle: const TextStyle(fontFamily: 'Roboto Mono'),
        ),
      ));

      const double codeButtonHeight = 36;
      Widget codeButtonBar = CodeButtionBar(
          codeController: widget.codeController, height: codeButtonHeight);

      return Column(
        children: [codeButtonBar, codeField],
      );

      // if (c.maxHeight <= codeButtonHeight) {
      //   codeButtonBar = Expanded(child: codeButtonBar);
      //   return Column(children: [codeButtonBar]);
      // } else {
      //   return Column(
      //     children: [codeField, codeButtonBar],
      //   );
      // }
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
      color: Theme.of(context).colorScheme.surfaceContainer,
      hoverColor: Theme.of(context).colorScheme.surfaceContainer,
    );
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
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
