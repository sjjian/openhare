import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sql_editor/re_editor.dart';
import 'dart:math';
import 'package:sql_parser/parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SQLEditor extends ConsumerWidget {
  final CodeLineEditingController codeController;

  const SQLEditor({super.key, required this.codeController});

  List<CodeKeywordPrompt> buildMetadataKeyword(MetaDataNode metadata) {
    List<CodeKeywordPrompt> keywordPrompt = List.empty(growable: true);
    metadata.visitor((node, parent) {
      keywordPrompt.add(CodeKeywordPrompt(word: node.value));
      return true;
    });
    return keywordPrompt;
  }

  Map<String, List<CodePrompt>> buildRelatePrompts(
      MetaDataNode metadata, String? currentSchema) {
    Map<String, List<CodePrompt>> relatedPrompts = {};
    // todo: 有一个缺陷，有下划线的变量无法relate, 当存在类似的prefix时，例如: 存在`t1`时, `t1_1`无法关联。
    metadata.visitor((node, parent) {
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

      ps.add(CodeKeywordPrompt(word: node.value));
      return true;
    });
    return relatedPrompts;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionSQLEditorModel model =
        ref.watch(selectedSessionSQLEditorNotifierProvider);

    List<CodeKeywordPrompt> keywordPrompt = [
      for (final keyword in keywords)
        CodeCaseInsensitiveKeywordPrompt(word: keyword),
    ];
    if (model.metadata != null) {
      keywordPrompt.addAll(buildMetadataKeyword(model.metadata!));
    }

    return CodeAutocomplete(
      viewBuilder: (context, notifier, onSelected) {
        return _DefaultCodeAutocompleteListView(
          notifier: notifier,
          onSelected: onSelected,
        );
      },
      promptsBuilder: DefaultCodeAutocompletePromptsBuilder(
        keywordPrompts: keywordPrompt,
        relatedPrompts: (model.metadata != null)
            ? buildRelatePrompts(model.metadata!, model.currentSchema)
            : const {},
      ),
      child: CodeEditor(
        wordWrap: false,
        style: CodeEditorStyle(
          backgroundColor:
              Theme.of(context).colorScheme.surfaceBright, // SQL 编辑器背景色
          textStyle: GoogleFonts.robotoMono(
              textStyle: Theme.of(context).textTheme.bodyMedium,
              color: Theme.of(context).colorScheme.onSurface), // SQL 编辑器文字颜色
        ),
        indicatorBuilder:
            (context, editingController, chunkController, notifier) {
          return Row(
            children: [
              DefaultCodeLineNumber(
                controller: editingController,
                notifier: notifier,
              ),
              DefaultCodeChunkIndicator(
                  width: 20, controller: chunkController, notifier: notifier)
            ],
          );
        },
        controller: codeController,
      ),
    );
  }
}

class _DefaultCodeAutocompleteListView extends StatefulWidget
    implements PreferredSizeWidget {
  static const double kItemHeight = 26;

  final ValueNotifier<CodeAutocompleteEditingValue> notifier;
  final ValueChanged<CodeAutocompleteResult> onSelected;

  const _DefaultCodeAutocompleteListView({
    required this.notifier,
    required this.onSelected,
  });

  @override
  Size get preferredSize => Size(
      250,
      // 2 is border size
      min(kItemHeight * notifier.value.prompts.length, 150) + 2);

  @override
  State<StatefulWidget> createState() =>
      _DefaultCodeAutocompleteListViewState();
}

class _DefaultCodeAutocompleteListViewState
    extends State<_DefaultCodeAutocompleteListView> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.loose(widget.preferredSize),
        decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .inverseSurface, // SQL editor 提示框背景色
            borderRadius: BorderRadius.circular(6)),
        child: AutoScrollListView(
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
                  height: _DefaultCodeAutocompleteListView.kItemHeight,
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: index == widget.notifier.value.index
                          ? Theme.of(context)
                              .colorScheme
                              .secondary // SQL editor 提示框选中时背景色
                          : null,
                      borderRadius: radius),
                  child: RichText(
                    text:
                        prompt.createSpan(context, widget.notifier.value.input),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ));
          },
        ));
  }

  void _onValueChanged() {
    setState(() {});
  }
}

extension _CodePromptExtension on CodePrompt {
  InlineSpan createSpan(BuildContext context, String input) {
    const TextStyle style = TextStyle();
    final InlineSpan span = style.createSpan(
      value: word,
      anchor: input,
      color: Theme.of(context)
          .colorScheme
          .inversePrimary, // SQL editor 提示框高亮字体色，例如： [SE]LECT 中的 SE
      fontWeight: FontWeight.bold,
    );
    final CodePrompt prompt = this;

    if (prompt is CodeFunctionPrompt) {
      return TextSpan(children: [
        span,
        TextSpan(
            text: '(...) -> ${prompt.type}',
            style: style.copyWith(color: Colors.cyan))
      ]);
    }
    return span;
  }
}

extension _TextStyleExtension on TextStyle {
  InlineSpan createSpan({
    required String value,
    required String anchor,
    required Color color,
    FontWeight? fontWeight,
    bool casesensitive = false,
  }) {
    if (anchor.isEmpty) {
      return TextSpan(
        text: value,
        style: this,
      );
    }
    final int index;
    if (casesensitive) {
      index = value.indexOf(anchor);
    } else {
      index = value.toLowerCase().indexOf(anchor.toLowerCase());
    }
    if (index < 0) {
      return TextSpan(
        text: value,
        style: this,
      );
    }
    return TextSpan(children: [
      TextSpan(text: value.substring(0, index), style: this),
      TextSpan(
          text: value.substring(index, index + anchor.length),
          style: copyWith(
            color: color,
            fontWeight: fontWeight,
          )),
      TextSpan(text: value.substring(index + anchor.length), style: this)
    ]);
  }
}

class AutoScrollListView extends StatefulWidget {
  final ScrollController controller;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final int initialIndex;
  final Axis scrollDirection;

  const AutoScrollListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.itemCount,
    this.initialIndex = 0,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<StatefulWidget> createState() => _AutoScrollListViewState();
}

class _AutoScrollListViewState extends State<AutoScrollListView> {
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
  void didUpdateWidget(covariant AutoScrollListView oldWidget) {
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
