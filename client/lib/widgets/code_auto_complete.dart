import 'package:client/widgets/const.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:client/widgets/sql_highlight.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:sql_parser/parser.dart';
import 'package:sql_complete/sql_complete.dart';
import 'dart:math';

class FuzzyMatchCodePrompt extends CodeKeywordPrompt {
  final List<int>? matchPositions;

  const FuzzyMatchCodePrompt({required super.word, this.matchPositions});

  @override
  bool match(String input) {
    return FuzzyMatch.match(input, word);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is FuzzyMatchCodePrompt && other.word == word;
  }

  @override
  int get hashCode => word.hashCode;

  /// Builds a TextSpan with highlighted match positions.
  TextSpan getTextSpan(BuildContext context, String input, {TextStyle? style}) {
    List<int>? positions = matchPositions;
    if (positions == null) {
      final matchResult = FuzzyMatch.matchWithResult(input, word);
      if (matchResult.matched) positions = matchResult.matchPositions;
    }
    final baseStyle =
        style ??
        GoogleFonts.robotoMono(
          textStyle: Theme.of(context).textTheme.bodyMedium,
          color: Theme.of(context).colorScheme.onSurface,
          letterSpacing: 0,
        );

    // If no match or no matchPositions, return plain text
    if (positions == null || positions.isEmpty) {
      return TextSpan(text: word, style: baseStyle);
    }

    final matchPositionsSet = positions.toSet();
    final List<TextSpan> spans = [];

    for (int i = 0; i < word.length; i++) {
      final isMatch = matchPositionsSet.contains(i);
      spans.add(
        TextSpan(
          text: word[i],
          style: isMatch ? baseStyle.copyWith(color: SQLHighlightColor.keyword) : baseStyle,
        ),
      );
    }

    return TextSpan(children: spans);
  }
}

class KeywordPrompt extends FuzzyMatchCodePrompt {
  const KeywordPrompt({required super.word, super.matchPositions});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is KeywordPrompt && other.word == word;
  }

  @override
  int get hashCode => word.hashCode;
}

class DBObjectPrompt extends FuzzyMatchCodePrompt {
  final MetaType type;
  final Map<MetaDataPropType, MetaDataProp>? props;
  const DBObjectPrompt({
    required super.word,
    required this.type,
    this.props,
    super.matchPositions,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DBObjectPrompt && other.word == word;
  }

  @override
  int get hashCode => word.hashCode;
}

class SQLEditorAutocompletePromptsBuilder implements DefaultCodeAutocompletePromptsBuilder {
  final CodeLineEditingController controller;
  final SqlCompleteCatalog catalog;
  final DialectType dialect;

  /// 对象名 → metadata props。
  final Map<String, Map<MetaDataPropType, MetaDataProp>> objectProps;

  SQLEditorAutocompletePromptsBuilder({
    required this.controller,
    required this.catalog,
    this.dialect = DialectType.mysql,
    this.objectProps = const {},
  });

  CodePrompt _promptFromItem(SqlCompleteItem item) {
    switch (item.kind) {
      case SqlCompleteKind.keyword:
        return KeywordPrompt(
          word: item.text,
          matchPositions: item.matchPositions,
        );
      case SqlCompleteKind.database:
        return _objectPrompt(item, MetaType.database);
      case SqlCompleteKind.table:
      case SqlCompleteKind.alias:
        return _objectPrompt(item, MetaType.table);
      case SqlCompleteKind.column:
      // object 是模型未细分的对象名，列图标最中性。
      case SqlCompleteKind.object:
        return _objectPrompt(item, MetaType.column);
    }
  }

  DBObjectPrompt _objectPrompt(SqlCompleteItem item, MetaType type) {
    return DBObjectPrompt(
      word: item.text,
      type: type,
      props: objectProps[item.text],
      matchPositions: item.matchPositions,
    );
  }

  @override
  CodeAutocompleteEditingValue? build(BuildContext context, CodeLine codeLine, CodeLineSelection selection) {
    final text = codeLine.text;
    final before = text.substring(0, selection.extentOffset);
    final after = text.substring(selection.extentOffset);
    final sqlPrefix = prefixBeforeCursor(controller, dialect: dialect);

    final engine = SqlCompletionEngine(catalog: catalog, dialect: dialect);
    final result = engine.complete(
      SqlCompletionRequest(
        sqlPrefix: sqlPrefix,
        lineBefore: before,
        lineAfter: after,
      ),
    );
    if (result.isEmpty) return null;

    return CodeAutocompleteEditingValue(
      input: result.input,
      prompts: [for (final item in result.items) _promptFromItem(item)],
      index: 0,
    );
  }
}

/// 光标所在 SQL block 内、到光标为止的前缀（与行号条 / 执行当前语句同一套 [splitSQL]）。
String prefixBeforeCursor(
  CodeLineEditingController controller, {
  DialectType dialect = DialectType.mysql,
}) {
  final content = controller.text;
  final chunks = splitSQL(
    dialect,
    content,
    skipWhitespace: true,
    skipComment: true,
  );
  final abs = _absoluteCursorOffset(controller);
  SQLChunk? chunk;
  for (final c in chunks) {
    // end.cursor 含尾字符；abs == end.cursor + 1 表示停在语句末尾之后。
    if (abs >= c.start.cursor && abs <= c.end.cursor + 1) {
      chunk = c;
      break;
    }
  }
  if (chunk == null || chunk.start.cursor < 0) return '';
  final end = abs.clamp(chunk.start.cursor, chunk.end.cursor + 1);
  return content.substring(chunk.start.cursor, end);
}

/// 与 `controller.text`（默认 LF）对齐的绝对下标。
int _absoluteCursorOffset(CodeLineEditingController controller) {
  final selection = controller.selection;
  var offset = selection.extentOffset;
  for (var i = 0; i < selection.extentIndex; i++) {
    offset += controller.codeLines[i].charCount + 1;
  }
  return offset;
}

class SQLEditorAutoCompleteListView extends StatefulWidget implements PreferredSizeWidget {
  static const double kItemHeight = 26;

  final ValueNotifier<CodeAutocompleteEditingValue> notifier;
  final ValueChanged<CodeAutocompleteResult> onSelected;

  final TextStyle textStyle;

  const SQLEditorAutoCompleteListView({
    super.key,
    required this.notifier,
    required this.onSelected,
    required this.textStyle,
  });

  @override
  Size get preferredSize {
    // 计算最长的提示词的宽度
    CodePrompt? maxLengthPrompt;
    for (final prompt in notifier.value.prompts) {
      if (prompt.word.length > (maxLengthPrompt?.word.length ?? 0)) {
        maxLengthPrompt = prompt;
      }
    }
    double textWidth = 0;
    if (maxLengthPrompt != null) {
      final fullTextPainter = TextPainter(
        text: TextSpan(
          text: maxLengthPrompt.word,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      fullTextPainter.layout();
      textWidth = fullTextPainter.width;
    }
    // Calculate total width: icon(16) * 2 + spacing(5) * 3 + text width + padding(20)
    double maxWidth = 16 * 2 + textWidth + kSpacingTiny * 3 + 20;

    return Size(
      // 长度在区间 400 - 800 之间
      min(max(maxWidth, 400.0), 600.0),
      // 2 is border size
      min(kItemHeight * notifier.value.prompts.length, 250) + 2,
    );
  }

  @override
  State<StatefulWidget> createState() => _SQLEditorAutoCompleteListViewState();
}

class _SQLEditorAutoCompleteListViewState extends State<SQLEditorAutoCompleteListView> {
  @override
  void initState() {
    widget.notifier.addListener(_onValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onValueChanged);
    super.dispose();
  }

  Widget _buildPromptText(BuildContext context, CodePrompt prompt) {
    if (prompt is FuzzyMatchCodePrompt) {
      final input = widget.notifier.value.input;
      return Text.rich(
        prompt.getTextSpan(context, input, style: widget.textStyle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        prompt.word,
        style: widget.textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget getIcon(BuildContext context, CodePrompt prompt) {
    if (prompt is KeywordPrompt) {
      return const HugeIcon(
        icon: HugeIcons.strokeRoundedTag01,
        color: SQLHighlightColor.keyword, // todo: 颜色需要抽取到 theme 中
        size: 16,
      );
    }

    if (prompt is DBObjectPrompt) {
      switch (prompt.type) {
        case MetaType.instance:
          return const HugeIcon(
            icon: HugeIcons.strokeRoundedDatabase,
            color: SQLHighlightColor.ident,
            size: 16,
          );
        case MetaType.database:
          return const HugeIcon(
            icon: HugeIcons.strokeRoundedDatabase,
            color: SQLHighlightColor.ident,
            size: 16,
          );
        case MetaType.schema:
          return const HugeIcon(
            icon: HugeIcons.strokeRoundedDatabase,
            color: SQLHighlightColor.ident,
            size: 16,
          );
        case MetaType.table:
          return const HugeIcon(
            icon: HugeIcons.strokeRoundedTable,
            color: SQLHighlightColor.doubleQValue,
            size: 16,
          );
        case MetaType.column:
          return const HugeIcon(
            icon: HugeIcons.strokeRoundedMenu09,
            color: SQLHighlightColor.number,
            size: 16,
          );
      }
    }
    return const Icon(Icons.table_rows);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.surfaceContainerLowest; // 代码补全提示窗口的背景色
    final selectedBackgroundColor = Theme.of(context).colorScheme.surfaceContainer; // 代码补全提示窗口选中项的背景色

    return Container(
      constraints: BoxConstraints.loose(widget.preferredSize),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant, // 提示窗边框颜色
        ),
      ),
      child: SQLEditorAutoCompleteScrollListView(
        controller: ScrollController(),
        initialIndex: widget.notifier.value.index,
        scrollDirection: Axis.vertical,
        itemCount: widget.notifier.value.prompts.length,
        itemBuilder: (context, index) {
          final CodePrompt prompt = widget.notifier.value.prompts[index];
          final BorderRadius radius = BorderRadius.only(
            topLeft: index == 0 ? const Radius.circular(5) : Radius.zero,
            topRight: index == 0 ? const Radius.circular(5) : Radius.zero,
            bottomLeft: index == widget.notifier.value.prompts.length - 1 ? const Radius.circular(5) : Radius.zero,
            bottomRight: index == widget.notifier.value.prompts.length - 1 ? const Radius.circular(5) : Radius.zero,
          );
          return InkWell(
            borderRadius: radius,
            onTap: () {
              widget.onSelected(widget.notifier.value.copyWith(index: index).autocomplete);
            },
            child: Container(
              width: double.infinity,
              height: SQLEditorAutoCompleteListView.kItemHeight,
              padding: const EdgeInsets.only(left: 5, right: 5),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: index == widget.notifier.value.index ? selectedBackgroundColor : null,
                borderRadius: radius,
              ),
              child: Row(
                children: [
                  getIcon(context, prompt),
                  const SizedBox(width: kSpacingTiny),
                  Expanded(child: _buildPromptText(context, prompt)),
                  const SizedBox(width: kSpacingTiny),
                  if (prompt is DBObjectPrompt && prompt.type == MetaType.column)
                    DataTypeIcon(
                      size: 16,
                      type: prompt.props?[MetaDataPropType.dataType]?.value as DataType? ?? DataType.blob,
                    ),
                  const SizedBox(width: kSpacingTiny),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onValueChanged() {
    setState(() {});
  }
}

class SQLEditorAutoCompleteScrollListView extends StatefulWidget {
  final ScrollController controller;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final int initialIndex;
  final Axis scrollDirection;

  const SQLEditorAutoCompleteScrollListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.itemCount,
    this.initialIndex = 0,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<StatefulWidget> createState() => _SQLEditorAutoCompleteScrollListViewState();
}

class _SQLEditorAutoCompleteScrollListViewState extends State<SQLEditorAutoCompleteScrollListView> {
  late final List<GlobalKey> _keys;

  @override
  void initState() {
    _keys = List.generate(widget.itemCount, (index) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SQLEditorAutoCompleteScrollListView oldWidget) {
    if (widget.itemCount > oldWidget.itemCount) {
      _keys.addAll(List.generate(widget.itemCount - oldWidget.itemCount, (index) => GlobalKey()));
    } else if (widget.itemCount < oldWidget.itemCount) {
      _keys.sublist(oldWidget.itemCount - widget.itemCount);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    for (int i = 0; i < widget.itemCount; i++) {
      widgets.add(
        Container(
          key: _keys[i],
          child: widget.itemBuilder(context, i),
        ),
      );
    }
    return SingleChildScrollView(
      controller: widget.controller,
      scrollDirection: widget.scrollDirection,
      child: isHorizontal
          ? Row(
              children: widgets,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
    );
  }

  void _autoScroll() {
    final ScrollController controller = widget.controller;
    if (!controller.hasClients) {
      return;
    }
    if (controller.position.maxScrollExtent == 0) {
      return;
    }
    double pre = 0;
    double cur = 0;
    for (int i = 0; i < _keys.length; i++) {
      final RenderObject? obj = _keys[i].currentContext?.findRenderObject();
      if (obj == null || obj is! RenderBox) {
        continue;
      }
      if (isHorizontal) {
        double width = obj.size.width;
        if (i == widget.initialIndex) {
          cur = pre + width;
          break;
        }
        pre += width;
      } else {
        double height = obj.size.height;
        if (i == widget.initialIndex) {
          cur = pre + height;
          break;
        }
        pre += height;
      }
    }
    if (pre == cur) {
      return;
    }
    if (pre < widget.controller.offset) {
      controller.jumpTo(pre - 1);
    } else if (cur > controller.offset + controller.position.viewportDimension) {
      controller.jumpTo(cur - controller.position.viewportDimension);
    }
  }

  bool get isHorizontal => widget.scrollDirection == Axis.horizontal;
}
