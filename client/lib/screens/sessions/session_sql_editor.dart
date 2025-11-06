import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_sql_editor.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/divider.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sql_editor/re_editor.dart';
import 'dart:math';
import 'package:sql_parser/parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/widgets/code_auto_complete.dart';

class SQLEditor extends ConsumerWidget {
  final CodeLineEditingController codeController;
  final CodeScrollController? scrollController;

  const SQLEditor(
      {super.key, required this.codeController, this.scrollController});

  List<DBObjectPrompt> buildMetadataKeyword(List<MetaDataNode> metadata) {
    List<DBObjectPrompt> keywordPrompt = List.empty(growable: true);
    for (final node in metadata) {
      node.visitor((node, parent) {
        keywordPrompt.add(DBObjectPrompt(
            word: node.value, type: node.type, props: node.props));
        return true;
      });
    }
    return keywordPrompt;
  }

  Map<String, List<CodePrompt>> buildRelatePrompts(
      List<MetaDataNode> metadata, String? currentSchema) {
    Map<String, List<CodePrompt>> relatedPrompts = {};
    // todo: 有一个缺陷，有下划线的变量无法relate, 当存在类似的prefix时，例如: 存在`t1`时, `t1_1`无法关联。
    for (final node in metadata) {
      node.visitor((node, parent) {
        if (parent == null) {
          return true;
        }
        if (parent.value == "") {
          return true;
        }
        if (node.type == MetaType.schema && node.value != currentSchema) {
          return false;
        }
        final ps = relatedPrompts.putIfAbsent(
            parent.value, () => List.empty(growable: true));

        ps.add(DBObjectPrompt(
            word: node.value, type: node.type, props: node.props));
        return true;
      });
    }
    return relatedPrompts;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionSQLEditorModel model =
        ref.watch(selectedSessionSQLEditorNotifierProvider);

    List<CodeKeywordPrompt> keywordPrompt = [
      for (final keyword in keywords)
        KeywordPrompt(word: keyword),
    ];
    if (model.metadata != null) {
      keywordPrompt.addAll(buildMetadataKeyword(model.metadata!));
    }

    final textStyle = GoogleFonts.robotoMono(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: CodeAutocomplete(
                viewBuilder: (context, notifier, onSelected) {
                  return SQLEditorAutoCompleteListView(
                    notifier: notifier,
                    onSelected: onSelected,
                  );
                },
                promptsBuilder: SQLEditorAutocompletePromptsBuilder(
                  keywordPrompts: keywordPrompt,
                  directPrompts: [],
                  relatedPrompts: (model.metadata != null)
                      ? buildRelatePrompts(model.metadata!, model.currentSchema)
                      : const {},
                ),
                child: CodeEditor(
                  wordWrap: false,
                  scrollController: scrollController,
                  style: CodeEditorStyle(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLowest, // SQL 编辑器背景色
                    textStyle: textStyle, // SQL 编辑器文字颜色
                  ),
                  controller: codeController,
                  indicatorBuilder:
                      (context, editingController, chunkController, notifier) {
                    return Row(children: [
                      const SizedBox(width: kSpacingTiny),
                      CodeLineNumber(
                        textStyle: textStyle,
                        totalHeight: constraints.maxHeight,
                        notifier: notifier,
                        codeController: codeController,
                      ),
                      const PixelVerticalDivider(),
                    ]);
                  },
                ),
              ),
            ),
            const PixelDivider(),
          ],
        );
      },
    );
  }
}

class CodeLineNumber extends StatefulWidget {
  final double totalHeight;
  final TextStyle textStyle;
  final CodeIndicatorValueNotifier notifier;
  final CodeLineEditingController codeController;

  const CodeLineNumber({
    Key? key,
    required this.notifier,
    required this.totalHeight,
    required this.textStyle,
    required this.codeController,
  }) : super(key: key);

  @override
  State<CodeLineNumber> createState() => _CodeLineNumberState();
}

class _CodeLineNumberState extends State<CodeLineNumber> {
  @override
  void initState() {
    widget.codeController.addListener(_onValueChanged);
    widget.notifier.addListener(_onValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    widget.notifier.removeListener(_onValueChanged);
  }

  void _onValueChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ps = widget.notifier.value?.paragraphs ?? [];

    // 计算开头的padding掉的高度
    double paddingSize = (ps.isNotEmpty) ? ps.first.offset.dy : 0;

    // 计算文字宽度, 默认最小是3.
    final lastLineNumberLength =
        max((ps.isNotEmpty) ? ps.last.index.toString().length : 0, 3);
    final tp = TextPainter(
      text: TextSpan(
        text: '0' * lastLineNumberLength,
        style: widget.textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    // 计算当前组件的宽度，加上了2个像素的divider 和内边距.
    final width = tp.width + kSpacingTiny * 2 + 2;
    if (widget.notifier.value == null) {
      return SizedBox(width: width);
    }
    var content = widget.codeController.text.toString();
    List<SQLChunk> querys =
        Splitter(content, ";", skipWhitespace: true, skipComment: true).split();
    CodeLineSelection s = widget.codeController.selection;

    // 计算当前选中的SQL块的开始和结束行.
    int currentSQLBlockStartLine;
    int currentSQLBlockEndLine;
    if (!s.isCollapsed) {
      if (s.baseIndex > s.extentIndex) {
        currentSQLBlockStartLine = s.extentIndex + 1;
        currentSQLBlockEndLine = s.baseIndex + 1;
      } else {
        currentSQLBlockStartLine = s.baseIndex + 1;
        currentSQLBlockEndLine = s.extentIndex + 1;
      }
    } else {
      Pos cursor = Pos(0, s.baseIndex + 1, s.baseOffset);
      SQLChunk chunk = querys.firstWhere((chunk) {
        if (cursor.between(chunk.start, chunk.end)) {
          return true;
        }
        return false;
      }, orElse: () => SQLChunk.empty());
      currentSQLBlockStartLine = chunk.start.line;
      currentSQLBlockEndLine = chunk.end.line;
    }

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: paddingSize),
          for (int i = 0; i < ps.length; i++)
            SizedBox(
              height: max(
                  0,
                  min(
                    ps[i].preferredLineHeight,
                    widget.totalHeight -
                        paddingSize -
                        i * ps[i].preferredLineHeight -
                        1,
                  )), // 减去1是为了让文字和下划线对齐
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Text(
                        (ps[i].index + 1).toString(),
                        overflow: TextOverflow.clip,
                        softWrap: false,
                        textAlign: TextAlign.right,
                        style: widget.textStyle.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: kSpacingTiny),
                  SizedBox(
                    width: 2,
                    child: (ps[i].index + 1 >= currentSQLBlockStartLine &&
                            ps[i].index + 1 <= currentSQLBlockEndLine)
                        ? const VerticalDivider(
                            color: Colors.green,
                            thickness: 2,
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: kSpacingTiny),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
