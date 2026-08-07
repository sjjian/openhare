import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

/// 统一的 marker 字符：
/// - encodedString 中用于标记 mention 结束（@label + marker）
/// - driverString 中用于 TextField 驱动的 placeholder（mention 视为一个字符）
const String _marker = '\uE000';

sealed class Segment {
  int get driverLength => switch (this) {
    TextSegment(:final value) => value.length,
    MentionSegment() => 1,
  };

  String toDriverString(String placeholder) => switch (this) {
    TextSegment(:final value) => value,
    MentionSegment() => placeholder,
  };
}

class TextSegment extends Segment {
  final String value;
  TextSegment(this.value);
}

class MentionSegment extends Segment {
  final String label;
  MentionSegment({required this.label});
}

typedef MentionState = ({int startIndex, String query});

class MentionCandidate {
  final String label;
  const MentionCandidate({required this.label});
}

typedef MentionCandidatesBuilder = FutureOr<List<MentionCandidate>> Function(String query);

typedef MentionItemBuilder =
    Widget Function(
      BuildContext context,
      MentionCandidate candidate,
      String query,
    );

class MentionSegmentSerializer {
  static String encode(List<Segment> segments) {
    return segments
        .map(
          (s) => switch (s) {
            TextSegment(:final value) => value,
            MentionSegment(:final label) => '@$label$_marker',
          },
        )
        .join();
  }

  static List<Segment> decode(String encodedString) {
    if (encodedString.isEmpty) return [];

    final segments = <Segment>[];
    final buffer = StringBuffer();
    int i = 0;

    while (i < encodedString.length) {
      if (encodedString[i] == '@') {
        // 查找下一个 mentionEndChar
        int j = i + 1;
        while (j < encodedString.length && encodedString[j] != _marker) {
          j++;
        }
        // 如果找到了 mentionEndChar，则判定为 Mention
        if (j < encodedString.length) {
          if (buffer.length > 0) {
            segments.add(TextSegment(buffer.toString()));
            buffer.clear();
          }
          final label = encodedString.substring(i + 1, j);
          // 处理空 label 的情况：如果 label 为空，将其作为普通文本处理
          if (label.isEmpty) {
            buffer.write('@');
            i++;
            continue;
          }
          // 当前编码格式只携带 label，且业务约定 label 唯一且稳定。
          segments.add(MentionSegment(label: label));
          i = j + 1;
          continue;
        }
      }
      buffer.write(encodedString[i]);
      i++;
    }

    if (buffer.length > 0) {
      segments.add(TextSegment(buffer.toString()));
    }

    return segments;
  }
}

String _segmentsToClipboardText(List<Segment> segments) {
  return MentionSegmentSerializer.encode(segments);
}

List<Segment> _decodeClipboardText(String raw) {
  return MentionSegmentSerializer.decode(raw);
}

class MentionTextController extends TextEditingController {
  List<Segment> _segments;
  final ValueNotifier<MentionState?> mentionState = ValueNotifier(null);

  MentionTextController({String? text})
    : _segments = text != null ? MentionSegmentSerializer.decode(text) : <Segment>[],
      super(text: '') {
    final initialDriver = _segmentsToDriverString();
    super.value = TextEditingValue(
      text: initialDriver,
      selection: TextSelection.collapsed(offset: initialDriver.length),
    );
    _updateMentionState();
  }

  /// 将 segment 转化成 value 给 TextEditingController 使用
  String _segmentsToDriverString() {
    return _segments.map((s) => s.toDriverString(_marker)).join();
  }

  List<Segment> get segments => List.unmodifiable(_segments);

  String get displayText => MentionSegmentSerializer.encode(_segments);

  @override
  void clear() {
    _segments = <Segment>[TextSegment('')];
    super.value = TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0), composing: TextRange.empty);
    _updateMentionState();
  }

  bool removeMention(MentionSegment segment) {
    int driverOffset = 0;
    int index = -1;
    for (int i = 0; i < _segments.length; i++) {
      final s = _segments[i];
      if (s is MentionSegment && identical(s, segment)) {
        index = i;
        break;
      }
      driverOffset += s.driverLength;
    }
    if (index < 0) return false;

    _segments.removeAt(index);
    final driver = _segmentsToDriverString();
    super.value = TextEditingValue(
      text: driver,
      selection: TextSelection.collapsed(offset: driverOffset.clamp(0, driver.length)),
      composing: TextRange.empty,
    );
    _updateMentionState();
    return true;
  }

  void loadFromEncodedString(String encodedString) {
    _segments = MentionSegmentSerializer.decode(encodedString);
    final driver = _segmentsToDriverString();
    super.value = TextEditingValue(
      text: driver,
      selection: TextSelection.collapsed(offset: driver.length),
      composing: TextRange.empty,
    );
    _updateMentionState();
  }

  void insertMention(String label) {
    final state = mentionState.value;
    if (state == null) return;
    final driverText = text;
    final start = state.startIndex.clamp(0, driverText.length);
    final end = selection.extentOffset.clamp(start, driverText.length);
    _replaceRangeInSegments(start, end, [MentionSegment(label: label)]);
    mentionState.value = null;
    final newDriver = _segmentsToDriverString();
    super.value = TextEditingValue(
      text: newDriver,
      selection: TextSelection.collapsed(offset: (start + 1).clamp(0, newDriver.length)),
      composing: TextRange.empty,
    );
  }

  /// 复制时输出“接近 displayText”的可见文本，同时在 mention 后附加零宽元数据，
  /// 以便粘贴回本输入框时能还原 mention。
  Future<void> copySelectionToClipboard() async {
    final sel = selection;
    if (!sel.isValid || sel.isCollapsed) return;
    final start = math.min(sel.start, sel.end);
    final end = math.max(sel.start, sel.end);
    final text = _segmentsToClipboardText(_sliceSegments(start, end));
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// 剪切：先复制，再删除选区内容。
  Future<void> cutSelectionToClipboard() async {
    final sel = selection;
    if (!sel.isValid || sel.isCollapsed) return;
    await copySelectionToClipboard();
    final start = math.min(sel.start, sel.end);
    final end = math.max(sel.start, sel.end);
    _replaceRangeInSegments(start, end, const []);
    final driver = _segmentsToDriverString();
    super.value = TextEditingValue(
      text: driver,
      selection: TextSelection.collapsed(offset: start.clamp(0, driver.length)),
      composing: TextRange.empty,
    );
    _updateMentionState();
  }

  /// 粘贴：若检测到零宽元数据则还原 mention；否则按普通文本粘贴。
  Future<void> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final raw = data?.text ?? '';
    if (raw.isEmpty) return;

    final inserted = _decodeClipboardText(raw);
    final sel = selection;
    final start = sel.isValid ? math.min(sel.start, sel.end) : text.length;
    final end = sel.isValid ? math.max(sel.start, sel.end) : text.length;
    _replaceRangeInSegments(start, end, inserted);
    final driver = _segmentsToDriverString();
    final caret = (start + inserted.fold<int>(0, (a, s) => a + s.driverLength)).clamp(0, driver.length);
    super.value = TextEditingValue(
      text: driver,
      selection: TextSelection.collapsed(offset: caret),
      composing: TextRange.empty,
    );
    _updateMentionState();
  }

  @override
  set value(TextEditingValue newValue) {
    final oldValue = super.value;
    final oldText = oldValue.text;
    final newText = newValue.text;

    // Selection-only changes: just forward, but keep mentionState in sync.
    if (oldText == newText) {
      super.value = newValue;
      _updateMentionState();
      return;
    }

    final (prefixLen, suffixLen) = _computeDiff(oldText, newText);
    final delStart = prefixLen;
    final delEnd = oldText.length - suffixLen;
    var inserted = newText.substring(prefixLen, newText.length - suffixLen);
    // 用户不应输入 placeholder 字符；若出现则忽略它，避免破坏 mention 语义。
    if (inserted.contains(_marker)) {
      inserted = inserted.replaceAll(_marker, '');
    }

    _replaceRangeInSegments(delStart, delEnd, inserted.isEmpty ? [] : [TextSegment(inserted)]);

    final driver = _segmentsToDriverString();
    final clampedSelection = _clampSelection(
      newValue.selection,
      driver.length,
      fallbackOffset: (prefixLen + inserted.length).clamp(0, driver.length),
    );
    final clampedComposing = _clampComposing(newValue.composing, driver.length);

    super.value = TextEditingValue(
      text: driver,
      selection: clampedSelection,
      composing: clampedComposing,
    );
    _updateMentionState();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (_segments.isEmpty) {
      return TextSpan(text: '', style: style);
    }

    final baseStyle = style ?? const TextStyle();
    final spans = <InlineSpan>[];

    final composing = withComposing ? value.composing : TextRange.empty;
    final composingValid = composing.isValid && !composing.isCollapsed && composing.end <= text.length;
    final composingStyle = baseStyle.merge(const TextStyle(decoration: TextDecoration.underline));

    var driverOffset = 0;
    for (final segment in _segments) {
      switch (segment) {
        case TextSegment(:final value):
          if (value.isEmpty) {
            driverOffset += 0;
            continue;
          }
          if (!composingValid) {
            spans.add(TextSpan(text: value, style: baseStyle));
            driverOffset += value.length;
            continue;
          }

          final segStart = driverOffset;
          final segEnd = driverOffset + value.length;
          driverOffset = segEnd;

          final overlapStart = math.max(segStart, composing.start);
          final overlapEnd = math.min(segEnd, composing.end);
          if (overlapStart >= overlapEnd) {
            spans.add(TextSpan(text: value, style: baseStyle));
            continue;
          }

          final beforeLen = (overlapStart - segStart).clamp(0, value.length);
          final composingLen = (overlapEnd - overlapStart).clamp(0, value.length - beforeLen);
          final afterStart = beforeLen + composingLen;

          if (beforeLen > 0) {
            spans.add(TextSpan(text: value.substring(0, beforeLen), style: baseStyle));
          }
          if (composingLen > 0) {
            spans.add(
              TextSpan(
                text: value.substring(beforeLen, beforeLen + composingLen),
                style: composingStyle,
              ),
            );
          }
          if (afterStart < value.length) {
            spans.add(TextSpan(text: value.substring(afterStart), style: baseStyle));
          }
        case MentionSegment(:final label):
          final mentionWidget = _MentionToken(
            controller: this,
            segment: segment,
            baseStyle: baseStyle.copyWith(fontWeight: FontWeight.w500),
            fallbackLabel: label,
          );
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: mentionWidget,
              ),
            ),
          );
          driverOffset += 1;
      }
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  List<Segment> _sliceSegments(int start, int end) {
    final out = <Segment>[];
    int currentOffset = 0;
    for (final seg in _segments) {
      final len = seg.driverLength;
      final segStart = currentOffset;
      final segEnd = currentOffset + len;
      currentOffset = segEnd;

      if (segEnd <= start) continue;
      if (segStart >= end) break;

      if (seg is TextSegment) {
        final s = (start - segStart).clamp(0, seg.value.length);
        final e = (end - segStart).clamp(0, seg.value.length);
        if (s < e) out.add(TextSegment(seg.value.substring(s, e)));
      } else if (seg is MentionSegment) {
        // mention 视作原子：只要选区覆盖 placeholder，就带上整个 mention
        out.add(seg);
      }
    }
    return out;
  }

  static TextSelection _clampSelection(TextSelection selection, int len, {required int fallbackOffset}) {
    int clampPos(int p) => p.clamp(0, len);
    if (!selection.isValid) return TextSelection.collapsed(offset: fallbackOffset);
    if (selection.isCollapsed) return TextSelection.collapsed(offset: clampPos(selection.extentOffset));
    return TextSelection(
      baseOffset: clampPos(selection.baseOffset),
      extentOffset: clampPos(selection.extentOffset),
    );
  }

  static TextRange _clampComposing(TextRange composing, int len) {
    if (!composing.isValid) return TextRange.empty;
    final start = composing.start.clamp(0, len);
    final end = composing.end.clamp(0, len);
    if (start >= end) return TextRange.empty;
    return TextRange(start: start, end: end);
  }

  void _updateMentionState() {
    final driverText = text;
    final cursorPos = selection.extentOffset.clamp(0, driverText.length);
    int? atIndex;
    for (int i = cursorPos - 1; i >= 0; i--) {
      final char = driverText[i];
      if (char == ' ' || char == '\n' || char == _marker) break;
      if (char == '@') {
        atIndex = i;
        break;
      }
    }

    if (atIndex != null) {
      final query = driverText.substring(atIndex + 1, cursorPos).replaceAll(_marker, '');
      mentionState.value = (startIndex: atIndex, query: query);
    } else {
      mentionState.value = null;
    }
  }

  void _replaceRangeInSegments(int start, int end, List<Segment> inserted) {
    final result = <Segment>[];
    int currentOffset = 0;
    bool insertedAdded = false;

    for (final segment in _segments) {
      final len = segment.driverLength;
      final segStart = currentOffset;
      final segEnd = currentOffset + len;
      currentOffset = segEnd;

      // Segment 完全在删除范围之前，保留
      if (segEnd <= start) {
        result.add(segment);
        continue;
      }
      // Segment 完全在删除范围之后，保留（在插入内容之后）
      if (segStart >= end) {
        if (!insertedAdded) {
          result.addAll(inserted);
          insertedAdded = true;
        }
        result.add(segment);
        continue;
      }

      // Segment 与删除范围有重叠
      if (segment is TextSegment) {
        // 计算在当前 segment 内的删除范围
        final segDelStart = (start - segStart).clamp(0, segment.value.length);
        final segDelEnd = (end - segStart).clamp(0, segment.value.length);
        // 保留删除范围之前的部分
        if (segDelStart > 0) {
          result.add(TextSegment(segment.value.substring(0, segDelStart)));
        }
        // 插入新内容（如果有，只在第一次遇到删除范围时插入）
        if (!insertedAdded) {
          result.addAll(inserted);
          insertedAdded = true;
        }
        // 保留删除范围之后的部分
        if (segDelEnd < segment.value.length) {
          result.add(TextSegment(segment.value.substring(segDelEnd)));
        }
      } else {
        // MentionSegment 在删除范围内，完全删除它（不添加到 result）
        // 只在第一次遇到删除范围时插入新内容
        if (!insertedAdded) {
          result.addAll(inserted);
          insertedAdded = true;
        }
      }
    }
    // 如果删除范围在最后，确保插入的内容被添加
    if (!insertedAdded) result.addAll(inserted);
    _segments = result;
  }

  (int prefixLen, int suffixLen) _computeDiff(String oldText, String newText) {
    int prefixLen = 0;
    while (prefixLen < oldText.length && prefixLen < newText.length && oldText[prefixLen] == newText[prefixLen]) {
      prefixLen++;
    }
    int suffixLen = 0;
    final maxSuffix = (oldText.length - prefixLen).clamp(0, oldText.length);
    final maxNewSuffix = (newText.length - prefixLen).clamp(0, newText.length);
    while (suffixLen < maxSuffix &&
        suffixLen < maxNewSuffix &&
        oldText[oldText.length - 1 - suffixLen] == newText[newText.length - 1 - suffixLen]) {
      suffixLen++;
    }
    return (prefixLen, suffixLen);
  }

  @override
  void dispose() {
    mentionState.dispose();
    super.dispose();
  }
}

// Keep old name for backward compatibility
typedef MentionTextEditingController = MentionTextController;

class MentionTextField extends StatefulWidget {
  final MentionTextController controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final Color? selectionColor;
  final TextAlignVertical? textAlignVertical;
  final StrutStyle? strutStyle;
  final int? minLines;
  final int? maxLines;
  final bool? enabled;

  /// 只读模式，用于展示场景不可编辑
  final bool readOnly;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  final MentionCandidatesBuilder? mentionCandidatesBuilder;
  final MentionItemBuilder? mentionItemBuilder;

  const MentionTextField({
    super.key,
    required this.controller,
    this.decoration,
    this.style,
    this.selectionColor,
    this.textAlignVertical,
    this.strutStyle,
    this.minLines,
    this.maxLines,
    this.enabled,
    this.readOnly = false,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.mentionCandidatesBuilder,
    this.mentionItemBuilder,
  });

  @override
  State<MentionTextField> createState() => _MentionTextFieldState();
}

class _MentionTextFieldState extends State<MentionTextField> {
  late FocusNode _focusNode;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focusNode;

  final GlobalKey _inputKey = GlobalKey();
  OverlayPortalController? _overlayController;
  List<MentionCandidate> _candidates = [];
  late ValueNotifier<int> _selectedIndex;
  bool _overlayVisible = false;

  bool get _useOverlay => widget.mentionCandidatesBuilder != null;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) _focusNode = FocusNode();
    _selectedIndex = ValueNotifier(0);
    if (_useOverlay) {
      _overlayController = OverlayPortalController();
      widget.controller.mentionState.addListener(_onMentionStateChanged);
    }
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _effectiveFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (_useOverlay) {
      widget.controller.mentionState.removeListener(_onMentionStateChanged);
      if (_overlayController != null && _overlayController!.isShowing) {
        _overlayController!.hide();
      }
    }
    _selectedIndex.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onMentionStateChanged() {
    final state = widget.controller.mentionState.value;
    if (state == null) {
      _hideOverlay();
      return;
    }
    final build = widget.mentionCandidatesBuilder;
    if (build == null) return;
    _loadCandidates(state.query);
  }

  Future<void> _loadCandidates(String query) async {
    final list = await widget.mentionCandidatesBuilder!(query);
    if (!mounted) return;
    _candidates = list;
    _selectedIndex.value = 0;
    if (_candidates.isNotEmpty) {
      _overlayVisible = true;
      _overlayController?.show();
    } else {
      _hideOverlay();
    }
    setState(() {});
  }

  void _hideOverlay() {
    _overlayVisible = false;
    if (_overlayController != null && _overlayController!.isShowing) {
      _overlayController!.hide();
    }
  }

  bool _tryConfirmSelection() {
    if (_candidates.isEmpty || _selectedIndex.value >= _candidates.length) return false;
    final c = _candidates[_selectedIndex.value];
    widget.controller.insertMention(c.label);
    _hideOverlay();
    return true;
  }

  void handleArrowDown() {
    if (_overlayVisible && _candidates.isNotEmpty) {
      _selectedIndex.value = (_selectedIndex.value + 1) % _candidates.length;
    }
  }

  void handleArrowUp() {
    if (_overlayVisible && _candidates.isNotEmpty) {
      _selectedIndex.value = (_selectedIndex.value - 1 + _candidates.length) % _candidates.length;
    }
  }

  bool handleEnter() {
    // IME 组字确认依赖 Enter，组字中不抢键，否则会出现回车无响应/内容被清掉。
    final composing = widget.controller.value.composing;
    if (composing.isValid && !composing.isCollapsed) {
      return false;
    }
    if (_overlayVisible && _candidates.isNotEmpty) {
      return _tryConfirmSelection();
    }
    if (widget.onSubmitted != null) {
      widget.onSubmitted!(widget.controller.displayText);
      return true;
    }
    return false;
  }

  bool handleNewline() {
    // 规则：Shift+Enter / Ctrl+Enter 插入换行（桌面端：macOS / Windows / Linux）。
    // 这里通过直接更新 controller.value 来触发 segment 同步逻辑。
    final controller = widget.controller;
    final v = controller.value;
    final sel = v.selection;
    final start = sel.isValid ? math.min(sel.start, sel.end) : v.text.length;
    final end = sel.isValid ? math.max(sel.start, sel.end) : v.text.length;
    final newText = v.text.replaceRange(start, end, '\n');
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: (start + 1).clamp(0, newText.length)),
      composing: TextRange.empty,
    );
    return true;
  }

  bool handleCut() {
    widget.controller.cutSelectionToClipboard();
    return true;
  }

  bool handleTab() {
    if (_overlayVisible && _candidates.isNotEmpty) {
      return _tryConfirmSelection();
    }
    return false;
  }

  void handleEscape() {
    if (_overlayVisible) {
      _hideOverlay();
    }
  }

  Widget _defaultMentionItem(BuildContext context, MentionCandidate c, String query) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(c.label, style: theme.textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  @override
  Widget build(BuildContext context) {
    final useOverlay = widget.mentionCandidatesBuilder != null;

    final textField = TextSelectionTheme(
      data: TextSelectionTheme.of(context).copyWith(
        selectionColor: widget.selectionColor ?? Theme.of(context).colorScheme.primaryContainer, // 文字选择背景色
      ),
      child: Actions(
        actions: <Type, Action<Intent>>{
          CopySelectionTextIntent: CallbackAction<CopySelectionTextIntent>(
            onInvoke: (intent) {
              widget.controller.copySelectionToClipboard();
              return null;
            },
          ),
          PasteTextIntent: CallbackAction<PasteTextIntent>(
            onInvoke: (intent) {
              widget.controller.pasteFromClipboard();
              return null;
            },
          ),
        },
        child: TextField(
          key: _inputKey,
          controller: widget.controller,
          focusNode: _effectiveFocusNode,
          decoration: widget.decoration,
          style: widget.style,
          strutStyle: widget.strutStyle,
          textAlignVertical: widget.textAlignVertical,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          enabled: widget.enabled ?? true,
          readOnly: widget.readOnly,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted == null ? null : (_) => widget.onSubmitted!(widget.controller.displayText),
        ),
      ),
    );

    final shortcuts = <LogicalKeySet, Intent>{
      // 剪切：桌面端 Ctrl/⌘ + X
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyX): const _CutIntent(),
      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyX): const _CutIntent(),

      // 换行：Shift+Enter / Ctrl+Enter（同时兼容小键盘 Enter）
      LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.enter): const _NewlineIntent(),
      LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.numpadEnter): const _NewlineIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter): const _NewlineIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.numpadEnter): const _NewlineIntent(),

      // 发送：Enter（同时兼容小键盘 Enter）
      LogicalKeySet(LogicalKeyboardKey.enter): const _EnterIntent(),
      LogicalKeySet(LogicalKeyboardKey.numpadEnter): const _EnterIntent(),
    };

    if (useOverlay) {
      shortcuts.addAll(<LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const _ArrowDownIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const _ArrowUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.tab): const _TabIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const _EscapeIntent(),
      });
    }

    final actions = <Type, Action<Intent>>{
      _EnterIntent: _EnterAction(this),
      _NewlineIntent: _NewlineAction(this),
      _CutIntent: _CutAction(this),
      if (useOverlay) ...<Type, Action<Intent>>{
        _ArrowDownIntent: _ArrowDownAction(this),
        _ArrowUpIntent: _ArrowUpAction(this),
        _TabIntent: _TabAction(this),
        _EscapeIntent: _EscapeAction(this),
      },
    };

    final child = useOverlay
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              textField,
              if (_overlayController != null)
                OverlayPortal(
                  controller: _overlayController!,
                  overlayChildBuilder: _buildOverlay,
                ),
            ],
          )
        : textField;

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actions,
        child: child,
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    if (_candidates.isEmpty) return const SizedBox.shrink();

    final RenderBox? box = _inputKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox.shrink();

    final screen = MediaQuery.of(context).size;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;
    const itemHeight = 32.0;
    const maxHeight = 240.0;
    const menuWidth = 280.0;
    final menuHeight = (_candidates.length * itemHeight).clamp(0.0, maxHeight);

    double top = pos.dy + size.height + 4;
    if (top + menuHeight > screen.height) top = pos.dy - menuHeight - 4;
    double left = pos.dx;
    if (left + menuWidth > screen.width) left = screen.width - menuWidth - 8;
    if (left < 8) left = 8;

    final query = widget.controller.mentionState.value?.query ?? '';
    final itemBuilder = widget.mentionItemBuilder ?? _defaultMentionItem;
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _hideOverlay),
        ),
        Positioned(
          left: left,
          top: top,
          child: Material(
            child: Container(
              constraints: const BoxConstraints(maxWidth: menuWidth, maxHeight: maxHeight),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest, // mention text 提示窗口默认背景色
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.12), // mention text 提示窗口阴影颜色
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndex,
                builder: (context, selected, _) {
                  final surface = theme.colorScheme.surfaceContainer; // mention text 提示窗口选中项背景色
                  return ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      for (int i = 0; i < _candidates.length; i++)
                        InkWell(
                          onTap: () {
                            widget.controller.insertMention(_candidates[i].label);
                            _hideOverlay();
                          },
                          child: Container(
                            height: itemHeight,
                            color: i == selected ? surface : null,
                            child: itemBuilder(context, _candidates[i], query),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Intent classes
class _ArrowDownIntent extends Intent {
  const _ArrowDownIntent();
}

class _ArrowUpIntent extends Intent {
  const _ArrowUpIntent();
}

class _EnterIntent extends Intent {
  const _EnterIntent();
}

class _NewlineIntent extends Intent {
  const _NewlineIntent();
}

class _CutIntent extends Intent {
  const _CutIntent();
}

class _TabIntent extends Intent {
  const _TabIntent();
}

class _EscapeIntent extends Intent {
  const _EscapeIntent();
}

// Action classes
class _ArrowDownAction extends Action<_ArrowDownIntent> {
  final _MentionTextFieldState _state;
  _ArrowDownAction(this._state);

  @override
  Object? invoke(_ArrowDownIntent intent) {
    if (!_state._overlayVisible) return null;
    _state.handleArrowDown();
    return true;
  }
}

class _ArrowUpAction extends Action<_ArrowUpIntent> {
  final _MentionTextFieldState _state;
  _ArrowUpAction(this._state);

  @override
  Object? invoke(_ArrowUpIntent intent) {
    if (!_state._overlayVisible) return null;
    _state.handleArrowUp();
    return true;
  }
}

class _EnterAction extends Action<_EnterIntent> {
  final _MentionTextFieldState _state;
  _EnterAction(this._state);

  @override
  Object? invoke(_EnterIntent intent) {
    if (_state.handleEnter()) return true;
    return null;
  }
}

class _NewlineAction extends Action<_NewlineIntent> {
  final _MentionTextFieldState _state;
  _NewlineAction(this._state);

  @override
  Object? invoke(_NewlineIntent intent) {
    if (_state.handleNewline()) return true;
    return null;
  }
}

class _CutAction extends Action<_CutIntent> {
  final _MentionTextFieldState _state;
  _CutAction(this._state);

  @override
  Object? invoke(_CutIntent intent) {
    if (_state.handleCut()) return true;
    return null;
  }
}

class _TabAction extends Action<_TabIntent> {
  final _MentionTextFieldState _state;
  _TabAction(this._state);

  @override
  Object? invoke(_TabIntent intent) {
    if (_state.handleTab()) return true;
    return null;
  }
}

class _EscapeAction extends Action<_EscapeIntent> {
  final _MentionTextFieldState _state;
  _EscapeAction(this._state);

  @override
  Object? invoke(_EscapeIntent intent) {
    if (!_state._overlayVisible) return null;
    _state.handleEscape();
    return true;
  }
}

class _MentionToken extends StatefulWidget {
  final MentionTextController controller;
  final MentionSegment segment;
  final TextStyle baseStyle;
  final String fallbackLabel;

  const _MentionToken({
    required this.controller,
    required this.segment,
    required this.baseStyle,
    required this.fallbackLabel,
  });

  @override
  State<_MentionToken> createState() => _MentionTokenState();
}

class _MentionTokenState extends State<_MentionToken> {
  bool _hovering = false;

  void _setHover(bool v) {
    if (_hovering == v) return;
    setState(() => _hovering = v);
  }

  void _onDelete() {
    widget.controller.removeMention(widget.segment);
  }

  Widget _buildMentionWidget(
    BuildContext context,
    MentionSegment segment,
    TextStyle baseStyle,
    bool hovering,
    VoidCallback onDelete,
  ) {
    final fontSize = baseStyle.fontSize ?? 14;
    // 让 token 的高度尽量贴近 TextField 的行高（selection 背景高度也会更一致）。
    final heightFactor = baseStyle.height ?? 1.0;
    final tokenHeight = fontSize * heightFactor;
    final labelStyle = baseStyle.copyWith(color: Theme.of(context).colorScheme.onSurface, height: heightFactor);
    return Container(
      key: ValueKey('table_mention_${segment.label}'),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer, // mention text 提示窗口选中项背景色
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        height: tokenHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hovering)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDelete,
                child: Icon(
                  Icons.close_rounded,
                  size: fontSize,
                  color: Theme.of(context).colorScheme.onSurface, // mention text 里的删除icon颜色
                ),
              )
            else
              HugeIcon(
                icon: HugeIcons.strokeRoundedTable,
                size: fontSize,
                color: Theme.of(context).colorScheme.onSurface, // mention text 里的表格icon颜色
              ),
            const SizedBox(width: 4),
            Center(
              child: Text(
                segment.label,
                style: labelStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: _buildMentionWidget(context, widget.segment, widget.baseStyle, _hovering, _onDelete),
    );
  }
}
