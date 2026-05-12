import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_sql_editor.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/divider.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sql_editor/re_editor.dart';
import 'dart:math';
import 'package:sql_parser/parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/screens/sessions/session_operation_bar.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/code_auto_complete.dart';
import 'package:client/widgets/menu.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SQLEditor extends ConsumerStatefulWidget {
  final CodeLineEditingController codeController;
  final CodeScrollController? scrollController;

  const SQLEditor({super.key, required this.codeController, this.scrollController});

  static List<DBObjectPrompt> buildMetadataKeyword(List<MetaDataNode> metadata) {
    List<DBObjectPrompt> keywordPrompt = List.empty(growable: true);
    for (final node in metadata) {
      node.visitor((node, parent) {
        keywordPrompt.add(DBObjectPrompt(word: node.value, type: node.type, props: node.props));
        return true;
      });
    }
    return keywordPrompt;
  }

  static Map<String, List<CodePrompt>> buildRelatePrompts(List<MetaDataNode> metadata, DatabaseRef? currentSchema) {
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
        final ps = relatedPrompts.putIfAbsent(parent.value, () => List.empty(growable: true));

        ps.add(DBObjectPrompt(word: node.value, type: node.type, props: node.props));
        return true;
      });
    }
    return relatedPrompts;
  }

  @override
  ConsumerState<SQLEditor> createState() => _SQLEditorState();
}

class _SQLEditorState extends ConsumerState<SQLEditor> {
  late final ToolbarController _toolbarController = ToolbarController();

  @override
  void dispose() {
    _toolbarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SessionSQLEditorModel model = ref.watch(selectedSessionSQLEditorProvider);

    List<CodeKeywordPrompt> keywordPrompt = [
      for (final keyword in keywords(model.dbType?.dialectType ?? DialectType.mysql)) KeywordPrompt(word: keyword),
    ];
    if (model.metadata != null) {
      keywordPrompt.addAll(SQLEditor.buildMetadataKeyword(model.metadata!));
    }

    final textStyle = GoogleFonts.robotoMono(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      color: Theme.of(context).colorScheme.onSurface, // SQL 编辑器文字颜色
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
                      ? SQLEditor.buildRelatePrompts(model.metadata!, model.currentSchema)
                      : const {},
                ),
                child: CodeEditor(
                  wordWrap: false,
                  scrollController: widget.scrollController,
                  style: CodeEditorStyle(
                    textStyle: textStyle, // SQL 编辑器文字颜色
                  ),
                  controller: widget.codeController,
                  toolbarController: _toolbarController,
                  indicatorBuilder: (context, editingController, chunkController, notifier) {
                    return Row(
                      children: [
                        const SizedBox(width: kSpacingTiny),
                        CodeLineNumber(
                          model: model,
                          textStyle: textStyle,
                          totalHeight: constraints.maxHeight,
                          notifier: notifier,
                          codeController: widget.codeController,
                        ),
                        const PixelVerticalDivider(),
                      ],
                    );
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

/// SQL 编辑器选区工具栏在 [OverlayEntry] 中的内容（订阅 [sessionOpBarProvider] 与 [controller]）。
class _SqlEditorSelectionToolbar extends ConsumerWidget {
  const _SqlEditorSelectionToolbar({
    required this.overlayContext,
    required this.controller,
    required this.anchors,
    required this.visibility,
    required this.onDismissBarrier,
  });

  final BuildContext overlayContext;
  final CodeLineEditingController controller;
  final TextSelectionToolbarAnchors anchors;
  final ValueNotifier<bool> visibility;
  final VoidCallback onDismissBarrier;

  OverlayMenuHeader? _sqlContextMenuSqlActionsHeader({
    required BuildContext overlayContext,
    required WidgetRef ref,
    required SessionOpBarModel barModel,
    required CodeLineEditingController controller,
    required AppLocalizations l10n,
    required VoidCallback onAfterAction,
  }) {
    final idle = SQLConnectState.isIdle(barModel.state);
    final outline = Theme.of(overlayContext).colorScheme.outlineVariant;

    return OverlayMenuHeader(
      height: 42,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kSpacingTiny, 0, 0, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RectangleIconButton.medium(
                      tooltip: l10n.button_tooltip_run_sql,
                      icon: Icons.play_circle_outline_rounded,
                      iconColor: idle ? Colors.green : Colors.grey,
                      onPressed: () {
                        sessionOpBarRunExecute(
                          context: overlayContext,
                          ref: ref,
                          model: barModel,
                          codeController: controller,
                        );
                        onAfterAction();
                      },
                    ),
                    SizedBox(width: kSpacingTiny),
                    RectangleIconButton.medium(
                      tooltip: l10n.button_tooltip_run_sql_new_tab,
                      icon: Icons.not_started_outlined,
                      iconColor: idle ? Colors.green : Colors.grey,
                      onPressed: () {
                        sessionOpBarRunExecuteAdd(
                          context: overlayContext,
                          ref: ref,
                          model: barModel,
                          codeController: controller,
                        );
                        onAfterAction();
                      },
                    ),
                    SizedBox(width: kSpacingTiny),
                    RectangleIconButton.medium(
                      tooltip: l10n.button_tooltip_explain_sql,
                      icon: Icons.poll_outlined,
                      iconColor: idle ? const Color.fromARGB(255, 241, 192, 84) : Colors.grey, // todo: color 统一
                      onPressed: () {
                        sessionOpBarExplain(
                          context: overlayContext,
                          ref: ref,
                          model: barModel,
                          codeController: controller,
                        );
                        onAfterAction();
                      },
                    ),
                    SizedBox(width: kSpacingTiny),
                    RectangleIconButton.medium(
                      tooltip: l10n.button_tooltip_sql_result_download,
                      icon: Icons.file_download_sharp,
                      iconColor: Colors.green,
                      verticalOffset: 1,
                      onPressed: () {
                        sessionOpBarExportDownload(
                          context: overlayContext,
                          model: barModel,
                          codeController: controller,
                        );
                        onAfterAction();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: outline),
        ],
      ),
    );
  }

  Widget _sqlContextMenuLeadingRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? iconColor,
  }) {
    final color = iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingTiny),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            RectangleIconButton.medium(
              icon: icon,
              iconColor: color,
              onPressed: null,
            ),
            const SizedBox(width: kSpacingTiny),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<OverlayMenuItem> _sqlContextMenuCopyPasteItems(
    BuildContext context, {
    required VoidCallback onCopy,
    required VoidCallback onPaste,
    double rowHeight = 40,
    bool canCopy = true,
  }) {
    final loc = MaterialLocalizations.of(context);
    return [
      OverlayMenuItem(
        height: rowHeight,
        onTabSelected: canCopy ? onCopy : null,
        child: Opacity(
          opacity: canCopy ? 1 : 0.38,
          child: _sqlContextMenuLeadingRow(context, icon: Icons.content_copy_rounded, label: loc.copyButtonLabel),
        ),
      ),
      OverlayMenuItem(
        height: rowHeight,
        onTabSelected: onPaste,
        child: _sqlContextMenuLeadingRow(context, icon: Icons.content_paste_rounded, label: loc.pasteButtonLabel),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListenableBuilder(
      listenable: controller,
      builder: (lbContext, _) {
        final barModel = ref.watch(sessionOpBarProvider);
        final l10n = AppLocalizations.of(overlayContext)!;
        final sqlHeader = barModel != null
            ? _sqlContextMenuSqlActionsHeader(
                overlayContext: overlayContext,
                ref: ref,
                barModel: barModel,
                controller: controller,
                l10n: l10n,
                onAfterAction: onDismissBarrier,
              )
            : null;

        final tabs = <OverlayMenuItem>[
          ..._sqlContextMenuCopyPasteItems(
            overlayContext,
            canCopy: !controller.selection.isCollapsed,
            onCopy: () {
              controller.copy();
            },
            onPaste: controller.paste,
          ),
          OverlayMenuItem(
            height: 40,
            onTabSelected: () => controller.selectAll(),
            child: _sqlContextMenuLeadingRow(
              overlayContext,
              icon: Icons.select_all_rounded,
              label: l10n.sql_editor_menu_select_all,
            ),
          ),
          OverlayMenuItem(
            height: 40,
            onTabSelected: controller.canUndo ? () => controller.undo() : null,
            child: Opacity(
              opacity: controller.canUndo ? 1 : 0.38,
              child: _sqlContextMenuLeadingRow(
                overlayContext,
                icon: Icons.undo_rounded,
                label: l10n.sql_editor_menu_undo,
              ),
            ),
          ),
          OverlayMenuItem(
            height: 40,
            onTabSelected: controller.canRedo ? () => controller.redo() : null,
            child: Opacity(
              opacity: controller.canRedo ? 1 : 0.38,
              child: _sqlContextMenuLeadingRow(
                overlayContext,
                icon: Icons.redo_rounded,
                label: l10n.sql_editor_menu_redo,
              ),
            ),
          ),
        ];
        final secondary = anchors.secondaryAnchor;
        final targetRect = secondary == null
            ? Rect.fromLTWH(anchors.primaryAnchor.dx, anchors.primaryAnchor.dy, 0, 0)
            : Rect.fromPoints(anchors.primaryAnchor, secondary);
        return CodeEditorTapRegion(
          child: Directionality(
            textDirection: Directionality.of(overlayContext),
            child: ListenableBuilder(
              listenable: visibility,
              builder: (context, _) {
                final visible = visibility.value;
                return IgnorePointer(
                  ignoring: !visible,
                  child: Opacity(
                    opacity: visible ? 1 : 0,
                    child: OverlayMenuLayer(
                      targetTopLeft: targetRect.topLeft,
                      targetSize: targetRect.size,
                      maxWidth: 250,
                      header: sqlHeader,
                      footer: OverlayMenuFooter(height: 10, child: SizedBox.shrink()),
                      tabs: tabs,
                      closeOnSelectItem: true,
                      onDismissBarrier: onDismissBarrier,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ToolbarController implements SelectionToolbarController {
  OverlayEntry? _entry;

  void dispose() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void hide(BuildContext context) {
    _entry?.remove();
    _entry = null;
  }

  @override
  void show({
    required BuildContext context,
    required CodeLineEditingController controller,
    required TextSelectionToolbarAnchors anchors,
    Rect? renderRect,
    required LayerLink layerLink,
    required ValueNotifier<bool> visibility,
  }) {
    hide(context);
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }
    void close() => hide(context);

    _entry = OverlayEntry(
      builder: (overlayContext) => _SqlEditorSelectionToolbar(
        overlayContext: overlayContext,
        controller: controller,
        anchors: anchors,
        visibility: visibility,
        onDismissBarrier: close,
      ),
    );
    overlay.insert(_entry!);
  }
}

class CodeLineNumber extends StatefulWidget {
  final SessionSQLEditorModel model;
  final double totalHeight;
  final TextStyle textStyle;
  final CodeIndicatorValueNotifier notifier;
  final CodeLineEditingController codeController;

  const CodeLineNumber({
    super.key,
    required this.model,
    required this.notifier,
    required this.totalHeight,
    required this.textStyle,
    required this.codeController,
  });

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
    final lastLineNumberLength = max((ps.isNotEmpty) ? ps.last.index.toString().length : 0, 3);
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
    List<SQLChunk> querys = splitSQL(
      widget.model.dbType?.dialectType ?? DialectType.mysql,
      content,
      skipWhitespace: true,
      skipComment: true,
    );
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
                  widget.totalHeight - paddingSize - i * ps[i].preferredLineHeight - 1,
                ),
              ), // 减去1是为了让文字和下划线对齐
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant, // SQL 编辑器行号文字颜色
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: kSpacingTiny),
                  SizedBox(
                    width: 2,
                    child: (ps[i].index + 1 >= currentSQLBlockStartLine && ps[i].index + 1 <= currentSQLBlockEndLine)
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
