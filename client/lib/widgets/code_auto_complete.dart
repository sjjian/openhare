import 'package:client/utils/fuzzy_match.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:client/widgets/sql_highlight.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sql_editor/re_editor.dart';
import 'dart:math';

class FuzzyMatchCodePrompt extends CodeKeywordPrompt {
  const FuzzyMatchCodePrompt({required super.word});
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
  ///
  /// If [cachedResult] is provided, it will be used instead of recalculating.
  /// This improves performance when the result was already computed during sorting.
  TextSpan getTextSpan(BuildContext context, String input,
      [FuzzyMatchResult? cachedResult]) {
    final matchResult = cachedResult ?? FuzzyMatch.matchWithResult(input, word);
    final baseStyle = GoogleFonts.robotoMono(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      color: Theme.of(context).colorScheme.onSurface,
    );

    // If no match or no matchPositions, return plain text
    if (!matchResult.matched ||
        matchResult.matchPositions == null ||
        matchResult.matchPositions!.isEmpty) {
      return TextSpan(text: word, style: baseStyle);
    }

    final matchPositionsSet = matchResult.matchPositions!.toSet();
    final List<TextSpan> spans = [];

    // Build TextSpan by checking each character's position
    for (int i = 0; i < word.length; i++) {
      final isMatch = matchPositionsSet.contains(i);
      spans.add(TextSpan(
        text: word[i],
        style: isMatch
            ? baseStyle.copyWith(
                color: SQLHighlightColor.keyword,
                fontWeight: FontWeight.bold,
              )
            : baseStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}

class KeywordPrompt extends FuzzyMatchCodePrompt {
  const KeywordPrompt({required super.word});

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
  const DBObjectPrompt({required super.word, required this.type, this.props});

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

extension _CodeAutocompleteStringExtension on String {
  bool get isValidVariablePart {
    final int char = codeUnits.first;
    return (char >= 65 && char <= 90) || // A–Z
        (char >= 97 && char <= 122) || // a–z
        (char >= 48 && char <= 57) || // 0–9
        char == 95; // _
  }
}

extension _CodeAutocompleteCharactersExtension on Characters {
  bool containsSymbols(List<String> symbols) {
    for (int i = length - 1; i >= 0; i--) {
      if (symbols.contains(elementAt(i))) {
        return true;
      }
    }
    return false;
  }
}

class SQLEditorAutocompletePromptsBuilder
    implements DefaultCodeAutocompletePromptsBuilder {
  final List<CodeKeywordPrompt> keywordPrompts;
  final List<CodePrompt> directPrompts;
  final Map<String, List<CodePrompt>> relatedPrompts;

  final Set<CodePrompt> _allKeywordPrompts = {};

  SQLEditorAutocompletePromptsBuilder(
      {required this.keywordPrompts,
      required this.directPrompts,
      required this.relatedPrompts}) {
    _allKeywordPrompts.addAll(keywordPrompts);
    _allKeywordPrompts.addAll(directPrompts);
  }

  bool _isInsideString(Characters before, Characters after) {
    // Check whether the position is inside a string
    return before.containsSymbols(const ['\'', '"']) &&
        after.containsSymbols(const ['\'', '"']);
  }

  String _extractWordBeforePosition(Characters characters, int endOffset) {
    int start = endOffset - 1;
    for (; start >= 0; start--) {
      if (!characters.elementAt(start).isValidVariablePart) {
        break;
      }
    }
    return characters.getRange(start + 1, endOffset).string;
  }

  (String input, Iterable<CodePrompt> prompts) _extractInputAndPrompts(
      Characters charactersBefore) {
    // Handle dot notation (e.g., table.column)
    if (charactersBefore.takeLast(1).string == '.') {
      const input = '';
      final target = _extractWordBeforePosition(
          charactersBefore, charactersBefore.length - 1);
      final prompts = relatedPrompts[target] ?? const [];
      return (input, prompts);
    }

    // Handle regular input extraction
    final input =
        _extractWordBeforePosition(charactersBefore, charactersBefore.length);
    if (input.isEmpty) {
      return ('', const []);
    }

    // Check if this is a qualified name (e.g., table.column)
    if (charactersBefore.length > 1 &&
        charactersBefore.elementAt(charactersBefore.length - 2) == '.') {
      final target = _extractWordBeforePosition(
          charactersBefore, charactersBefore.length - 1);
      final allPrompts =
          relatedPrompts[target]?.where((prompt) => prompt.match(input)) ??
              const [];
      final prompts = _sortAndLimitPrompts(allPrompts, input);
      return (input, prompts);
    }

    // Handle keyword/direct prompts
    final allPrompts =
        _allKeywordPrompts.where((prompt) => prompt.match(input));
    final prompts = _sortAndLimitPrompts(allPrompts, input);
    return (input, prompts);
  }

  @override
  CodeAutocompleteEditingValue? build(
      BuildContext context, CodeLine codeLine, CodeLineSelection selection) {
    final String text = codeLine.text;
    final Characters charactersBefore =
        text.substring(0, selection.extentOffset).characters;
    if (charactersBefore.isEmpty) {
      return null;
    }
    final Characters charactersAfter =
        text.substring(selection.extentOffset).characters;

    if (_isInsideString(charactersBefore, charactersAfter)) {
      return null;
    }

    final (input, prompts) = _extractInputAndPrompts(charactersBefore);

    if (input.isEmpty && prompts.isEmpty) {
      return null;
    }

    if (prompts.isEmpty) {
      return null;
    }

    return CodeAutocompleteEditingValue(
        input: input, prompts: prompts.toList(), index: 0);
  }

  /// Sorts prompts by match score and limits the result count for performance.
  ///
  /// Limits to top 100 matches to prevent UI lag when there are many candidates.
  static const int _maxPrompts = 100;

  List<CodePrompt> _sortAndLimitPrompts(
      Iterable<CodePrompt> prompts, String input) {
    if (input.isEmpty) {
      return prompts.take(_maxPrompts).toList();
    }

    // For FuzzyMatchCodePrompt, calculate scores and sort
    final List<(CodePrompt, double)> scoredPrompts = [];
    for (final prompt in prompts) {
      if (prompt is FuzzyMatchCodePrompt) {
        final result = FuzzyMatch.matchWithResult(input, prompt.word);
        if (result.matched) {
          scoredPrompts.add((prompt, result.score));
        }
      } else {
        // For other prompts, use a default score based on word length
        // Shorter words get higher scores (better for autocomplete)
        final score = 1.0 / (prompt.word.length + 1);
        scoredPrompts.add((prompt, score));
      }
    }

    // Sort by score (descending) and limit
    scoredPrompts.sort((a, b) => b.$2.compareTo(a.$2));
    return scoredPrompts.take(_maxPrompts).map((item) => item.$1).toList();
  }
}

class SQLEditorAutoCompleteListView extends StatefulWidget
    implements PreferredSizeWidget {
  static const double kItemHeight = 26;

  final ValueNotifier<CodeAutocompleteEditingValue> notifier;
  final ValueChanged<CodeAutocompleteResult> onSelected;

  const SQLEditorAutoCompleteListView({
    Key? key,
    required this.notifier,
    required this.onSelected,
  }) : super(key: key);

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
          // todo: 这里未指定字体大小，可能会导致调整了字体之后计算不匹配的问题
          style: GoogleFonts.robotoMono(),
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

class _SQLEditorAutoCompleteListViewState
    extends State<SQLEditorAutoCompleteListView> {
  // Cache for match results to avoid recalculating during rendering
  final Map<CodePrompt, FuzzyMatchResult> _matchResultCache = {};
  String _cachedInput = '';

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

  void _updateCache() {
    final input = widget.notifier.value.input;
    if (input == _cachedInput) {
      return; // Cache is still valid
    }

    _matchResultCache.clear();
    _cachedInput = input;

    // Pre-compute match results for all FuzzyMatchCodePrompt prompts
    for (final prompt in widget.notifier.value.prompts) {
      if (prompt is FuzzyMatchCodePrompt) {
        _matchResultCache[prompt] =
            FuzzyMatch.matchWithResult(input, prompt.word);
      }
    }
  }

  Widget _buildPromptText(BuildContext context, CodePrompt prompt) {
    final baseStyle = GoogleFonts.robotoMono(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      color: Theme.of(context).colorScheme.onSurface,
    );

    if (prompt is FuzzyMatchCodePrompt) {
      final input = widget.notifier.value.input;
      // Update cache if needed
      _updateCache();
      // Use cached result if available
      final cachedResult = _matchResultCache[prompt];
      return Text.rich(
        prompt.getTextSpan(context, input, cachedResult),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        prompt.word,
        style: baseStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget getIcon(BuildContext context, CodePrompt prompt) {
    if (prompt is KeywordPrompt) {
      return const HugeIcon(
        icon: HugeIcons.strokeRoundedTag01,
        color: SQLHighlightColor.keyword,
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
    final backgroundColor =
        Theme.of(context).colorScheme.surfaceContainerLowest; // 提示窗口的背景色
    final selectedBackgroundColor =
        Theme.of(context).colorScheme.surfaceContainer; // 提示窗口选中项的背景色

    return Container(
        constraints: BoxConstraints.loose(widget.preferredSize),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).dividerColor, // 提示窗边框颜色
            width: 1,
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
              bottomLeft: index == widget.notifier.value.prompts.length - 1
                  ? const Radius.circular(5)
                  : Radius.zero,
              bottomRight: index == widget.notifier.value.prompts.length - 1
                  ? const Radius.circular(5)
                  : Radius.zero,
            );
            return InkWell(
                borderRadius: radius,
                onTap: () {
                  widget.onSelected(widget.notifier.value
                      .copyWith(index: index)
                      .autocomplete);
                },
                child: Container(
                  width: double.infinity,
                  height: SQLEditorAutoCompleteListView.kItemHeight,
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: index == widget.notifier.value.index
                        ? selectedBackgroundColor
                        : null,
                    borderRadius: radius,
                  ),
                  child: Row(
                    children: [
                      getIcon(context, prompt),
                      const SizedBox(width: kSpacingTiny),
                      Expanded(child: _buildPromptText(context, prompt)),
                      const SizedBox(width: kSpacingTiny),
                      if (prompt is DBObjectPrompt &&
                          prompt.type == MetaType.column)
                        DataTypeIcon(
                          size: 16,
                          type: prompt.props?[MetaDataPropType.dataType]?.value
                                  as DataType? ??
                              DataType.blob,
                        ),
                      const SizedBox(width: kSpacingTiny),
                    ],
                  ),
                ));
          },
        ));
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
  State<StatefulWidget> createState() =>
      _SQLEditorAutoCompleteScrollListViewState();
}

class _SQLEditorAutoCompleteScrollListViewState
    extends State<SQLEditorAutoCompleteScrollListView> {
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
  void didUpdateWidget(
      covariant SQLEditorAutoCompleteScrollListView oldWidget) {
    if (widget.itemCount > oldWidget.itemCount) {
      _keys.addAll(List.generate(
          widget.itemCount - oldWidget.itemCount, (index) => GlobalKey()));
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
      widgets.add(Container(
        key: _keys[i],
        child: widget.itemBuilder(context, i),
      ));
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
    } else if (cur >
        controller.offset + controller.position.viewportDimension) {
      controller.jumpTo(cur - controller.position.viewportDimension);
    }
  }

  bool get isHorizontal => widget.scrollDirection == Axis.horizontal;
}
