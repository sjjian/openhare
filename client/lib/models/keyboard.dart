import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show SingleActivator;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'keyboard.freezed.dart';
part 'keyboard.g.dart';

enum KeyboardShortcut {
  sqlExecute,
  sqlExecuteAdd,
  sqlExplain,
  sqlExport,
  // 以下与 pkg/sql-editor CodeShortcutType 对应（仅含组合键；单键如方向键/Tab/Enter 等不纳入）
  sqlEditorSelectAll,
  sqlEditorCut,
  sqlEditorCopy,
  sqlEditorPaste,
  sqlEditorUndo,
  sqlEditorRedo,
  sqlEditorLineSelect,
  sqlEditorLineDelete,
  sqlEditorLineDeleteForward,
  sqlEditorLineDeleteBackward,
  sqlEditorLineMoveUp,
  sqlEditorLineMoveDown,
  sqlEditorCursorMoveLineStart,
  sqlEditorCursorMoveLineEnd,
  sqlEditorCursorMovePageStart,
  sqlEditorCursorMovePageEnd,
  sqlEditorCursorMoveWordBoundaryForward,
  sqlEditorCursorMoveWordBoundaryBackward,
  sqlEditorSelectionExtendUp,
  sqlEditorSelectionExtendDown,
  sqlEditorSelectionExtendForward,
  sqlEditorSelectionExtendBackward,
  sqlEditorSelectionExtendLineStart,
  sqlEditorSelectionExtendLineEnd,
  sqlEditorSelectionExtendPageStart,
  sqlEditorSelectionExtendPageEnd,
  sqlEditorSelectionExtendWordBoundaryForward,
  sqlEditorSelectionExtendWordBoundaryBackward,
  sqlEditorWordDeleteForward,
  sqlEditorWordDeleteBackward,
  sqlEditorOutdent,
  sqlEditorTransposeCharacters,
  sqlEditorSingleLineComment,
  sqlEditorMultiLineComment,
  sqlEditorFind,
  sqlEditorFindToggleMatchCase,
  sqlEditorFindToggleRegex,
  sqlEditorReplace,
  sqlEditorSave;

  static KeyboardShortcut fromName(String name) {
    return KeyboardShortcut.values.firstWhere((e) => e.name == name, orElse: () => KeyboardShortcut.values.first);
  }
}

const canUpdateShortcutKinds = <KeyboardShortcut>{
  KeyboardShortcut.sqlExecute,
  KeyboardShortcut.sqlExecuteAdd,
  KeyboardShortcut.sqlExplain,
  KeyboardShortcut.sqlExport,
};

/// 内置 SQL 编辑器快捷键（不含可配置的 sqlExecute*）
List<KeyboardShortcut> get sqlEditorBuiltinShortcutKinds =>
    KeyboardShortcut.values.where((k) => !canUpdateShortcutKinds.contains(k)).toList(growable: false);

/// 已登记默认键位、客户端/sql-editor 侧尚未完整接入（设置弹窗中灰色展示，仍参与冲突检测）。
const sqlEditorShortcutKindsNotYetImplemented = <KeyboardShortcut>{
  KeyboardShortcut.sqlEditorFind,
  KeyboardShortcut.sqlEditorFindToggleMatchCase,
  KeyboardShortcut.sqlEditorFindToggleRegex,
  KeyboardShortcut.sqlEditorReplace,
  KeyboardShortcut.sqlEditorSingleLineComment,
  KeyboardShortcut.sqlEditorMultiLineComment,
  KeyboardShortcut.sqlEditorSave,
};

bool isSqlEditorShortcutNotYetImplemented(KeyboardShortcut kind) =>
    sqlEditorShortcutKindsNotYetImplemented.contains(kind);

ShortcutModel _shortcut(
  LogicalKeyboardKey key, {
  bool meta = false,
  bool control = false,
  bool alt = false,
  bool shift = false,
}) => ShortcutModel(keyId: key.keyId, meta: meta, control: control, alt: alt, shift: shift);

final _keyboardShortcutDefaultsMacOS = <KeyboardShortcut, ShortcutModel>{
  KeyboardShortcut.sqlExecute: _shortcut(LogicalKeyboardKey.digit1, meta: true),
  KeyboardShortcut.sqlExecuteAdd: _shortcut(LogicalKeyboardKey.digit2, meta: true),
  KeyboardShortcut.sqlExplain: _shortcut(LogicalKeyboardKey.digit3, meta: true),
  KeyboardShortcut.sqlExport: _shortcut(LogicalKeyboardKey.digit4, meta: true),
  KeyboardShortcut.sqlEditorSelectAll: _shortcut(LogicalKeyboardKey.keyA, meta: true),
  KeyboardShortcut.sqlEditorCut: _shortcut(LogicalKeyboardKey.keyX, meta: true),
  KeyboardShortcut.sqlEditorCopy: _shortcut(LogicalKeyboardKey.keyC, meta: true),
  KeyboardShortcut.sqlEditorPaste: _shortcut(LogicalKeyboardKey.keyV, meta: true),
  KeyboardShortcut.sqlEditorUndo: _shortcut(LogicalKeyboardKey.keyZ, meta: true),
  KeyboardShortcut.sqlEditorRedo: _shortcut(LogicalKeyboardKey.keyZ, meta: true, shift: true),
  KeyboardShortcut.sqlEditorLineSelect: _shortcut(LogicalKeyboardKey.keyL, meta: true),
  KeyboardShortcut.sqlEditorLineDelete: _shortcut(LogicalKeyboardKey.keyD, meta: true),
  KeyboardShortcut.sqlEditorLineDeleteForward: _shortcut(LogicalKeyboardKey.delete, meta: true),
  KeyboardShortcut.sqlEditorLineDeleteBackward: _shortcut(LogicalKeyboardKey.backspace, meta: true),
  KeyboardShortcut.sqlEditorLineMoveUp: _shortcut(LogicalKeyboardKey.arrowUp, alt: true),
  KeyboardShortcut.sqlEditorLineMoveDown: _shortcut(LogicalKeyboardKey.arrowDown, alt: true),
  KeyboardShortcut.sqlEditorCursorMoveLineStart: _shortcut(LogicalKeyboardKey.arrowLeft, meta: true),
  KeyboardShortcut.sqlEditorCursorMoveLineEnd: _shortcut(LogicalKeyboardKey.arrowRight, meta: true),
  KeyboardShortcut.sqlEditorCursorMovePageStart: _shortcut(LogicalKeyboardKey.arrowUp, meta: true),
  KeyboardShortcut.sqlEditorCursorMovePageEnd: _shortcut(LogicalKeyboardKey.arrowDown, meta: true),
  KeyboardShortcut.sqlEditorCursorMoveWordBoundaryForward: _shortcut(LogicalKeyboardKey.arrowRight, alt: true),
  KeyboardShortcut.sqlEditorCursorMoveWordBoundaryBackward: _shortcut(LogicalKeyboardKey.arrowLeft, alt: true),
  KeyboardShortcut.sqlEditorSelectionExtendUp: _shortcut(LogicalKeyboardKey.arrowUp, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendDown: _shortcut(LogicalKeyboardKey.arrowDown, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendForward: _shortcut(LogicalKeyboardKey.arrowRight, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendBackward: _shortcut(LogicalKeyboardKey.arrowLeft, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendLineStart: _shortcut(LogicalKeyboardKey.arrowLeft, meta: true, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendLineEnd: _shortcut(LogicalKeyboardKey.arrowRight, meta: true, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendPageStart: _shortcut(LogicalKeyboardKey.arrowUp, meta: true, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendPageEnd: _shortcut(LogicalKeyboardKey.arrowDown, meta: true, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendWordBoundaryForward: _shortcut(
    LogicalKeyboardKey.arrowLeft,
    alt: true,
    shift: true,
  ),
  KeyboardShortcut.sqlEditorSelectionExtendWordBoundaryBackward: _shortcut(
    LogicalKeyboardKey.arrowRight,
    alt: true,
    shift: true,
  ),
  KeyboardShortcut.sqlEditorWordDeleteForward: _shortcut(LogicalKeyboardKey.delete, alt: true),
  KeyboardShortcut.sqlEditorWordDeleteBackward: _shortcut(LogicalKeyboardKey.backspace, alt: true),
  KeyboardShortcut.sqlEditorOutdent: _shortcut(LogicalKeyboardKey.tab, shift: true),
  KeyboardShortcut.sqlEditorTransposeCharacters: _shortcut(LogicalKeyboardKey.keyT, control: true),
  KeyboardShortcut.sqlEditorSingleLineComment: _shortcut(LogicalKeyboardKey.slash, meta: true),
  KeyboardShortcut.sqlEditorMultiLineComment: _shortcut(LogicalKeyboardKey.slash, meta: true, shift: true),
  KeyboardShortcut.sqlEditorFind: _shortcut(LogicalKeyboardKey.keyF, meta: true),
  KeyboardShortcut.sqlEditorFindToggleMatchCase: _shortcut(LogicalKeyboardKey.keyC, meta: true, alt: true),
  KeyboardShortcut.sqlEditorFindToggleRegex: _shortcut(LogicalKeyboardKey.keyR, meta: true, alt: true),
  KeyboardShortcut.sqlEditorReplace: _shortcut(LogicalKeyboardKey.keyF, meta: true, alt: true),
  KeyboardShortcut.sqlEditorSave: _shortcut(LogicalKeyboardKey.keyS, meta: true),
};

final _keyboardShortcutDefaultsWinLinux = <KeyboardShortcut, ShortcutModel>{
  KeyboardShortcut.sqlExecute: _shortcut(LogicalKeyboardKey.digit1, control: true),
  KeyboardShortcut.sqlExecuteAdd: _shortcut(LogicalKeyboardKey.digit2, control: true),
  KeyboardShortcut.sqlExplain: _shortcut(LogicalKeyboardKey.digit3, control: true),
  KeyboardShortcut.sqlExport: _shortcut(LogicalKeyboardKey.digit4, control: true),
  KeyboardShortcut.sqlEditorSelectAll: _shortcut(LogicalKeyboardKey.keyA, control: true),
  KeyboardShortcut.sqlEditorCut: _shortcut(LogicalKeyboardKey.keyX, control: true),
  KeyboardShortcut.sqlEditorCopy: _shortcut(LogicalKeyboardKey.keyC, control: true),
  KeyboardShortcut.sqlEditorPaste: _shortcut(LogicalKeyboardKey.keyV, control: true),
  KeyboardShortcut.sqlEditorUndo: _shortcut(LogicalKeyboardKey.keyZ, control: true),
  KeyboardShortcut.sqlEditorRedo: _shortcut(LogicalKeyboardKey.keyZ, control: true, shift: true),
  KeyboardShortcut.sqlEditorLineSelect: _shortcut(LogicalKeyboardKey.keyL, control: true),
  KeyboardShortcut.sqlEditorLineDelete: _shortcut(LogicalKeyboardKey.keyD, control: true),
  KeyboardShortcut.sqlEditorLineDeleteForward: _shortcut(LogicalKeyboardKey.delete, control: true),
  KeyboardShortcut.sqlEditorLineDeleteBackward: _shortcut(LogicalKeyboardKey.backspace, control: true),
  KeyboardShortcut.sqlEditorLineMoveUp: _shortcut(LogicalKeyboardKey.arrowUp, alt: true),
  KeyboardShortcut.sqlEditorLineMoveDown: _shortcut(LogicalKeyboardKey.arrowDown, alt: true),
  KeyboardShortcut.sqlEditorCursorMoveLineStart: _shortcut(LogicalKeyboardKey.arrowLeft, control: true),
  KeyboardShortcut.sqlEditorCursorMoveLineEnd: _shortcut(LogicalKeyboardKey.arrowRight, control: true),
  KeyboardShortcut.sqlEditorCursorMovePageStart: _shortcut(LogicalKeyboardKey.arrowUp, control: true),
  KeyboardShortcut.sqlEditorCursorMovePageEnd: _shortcut(LogicalKeyboardKey.arrowDown, control: true),
  KeyboardShortcut.sqlEditorCursorMoveWordBoundaryForward: _shortcut(LogicalKeyboardKey.arrowRight, alt: true),
  KeyboardShortcut.sqlEditorCursorMoveWordBoundaryBackward: _shortcut(LogicalKeyboardKey.arrowLeft, alt: true),
  KeyboardShortcut.sqlEditorSelectionExtendUp: _shortcut(LogicalKeyboardKey.arrowUp, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendDown: _shortcut(LogicalKeyboardKey.arrowDown, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendForward: _shortcut(LogicalKeyboardKey.arrowRight, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendBackward: _shortcut(LogicalKeyboardKey.arrowLeft, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendLineStart: _shortcut(LogicalKeyboardKey.home, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendLineEnd: _shortcut(LogicalKeyboardKey.end, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendPageStart: _shortcut(LogicalKeyboardKey.home, control: true, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendPageEnd: _shortcut(LogicalKeyboardKey.end, control: true, shift: true),
  KeyboardShortcut.sqlEditorSelectionExtendWordBoundaryForward: _shortcut(
    LogicalKeyboardKey.arrowLeft,
    alt: true,
    shift: true,
  ),
  KeyboardShortcut.sqlEditorSelectionExtendWordBoundaryBackward: _shortcut(
    LogicalKeyboardKey.arrowRight,
    alt: true,
    shift: true,
  ),
  KeyboardShortcut.sqlEditorWordDeleteForward: _shortcut(LogicalKeyboardKey.delete, alt: true),
  KeyboardShortcut.sqlEditorWordDeleteBackward: _shortcut(LogicalKeyboardKey.backspace, alt: true),
  KeyboardShortcut.sqlEditorOutdent: _shortcut(LogicalKeyboardKey.tab, shift: true),
  KeyboardShortcut.sqlEditorTransposeCharacters: _shortcut(LogicalKeyboardKey.keyT, control: true),
  KeyboardShortcut.sqlEditorSingleLineComment: _shortcut(LogicalKeyboardKey.slash, control: true),
  KeyboardShortcut.sqlEditorMultiLineComment: _shortcut(LogicalKeyboardKey.slash, control: true, shift: true),
  KeyboardShortcut.sqlEditorFind: _shortcut(LogicalKeyboardKey.keyF, control: true),
  KeyboardShortcut.sqlEditorFindToggleMatchCase: _shortcut(LogicalKeyboardKey.keyC, control: true, alt: true),
  KeyboardShortcut.sqlEditorFindToggleRegex: _shortcut(LogicalKeyboardKey.keyR, control: true, alt: true),
  KeyboardShortcut.sqlEditorReplace: _shortcut(LogicalKeyboardKey.keyF, control: true, alt: true),
  KeyboardShortcut.sqlEditorSave: _shortcut(LogicalKeyboardKey.keyS, control: true),
};

final _keyboardShortcutDefaultsByPlatform = <TargetPlatform, Map<KeyboardShortcut, ShortcutModel>>{
  TargetPlatform.macOS: _keyboardShortcutDefaultsMacOS,
  TargetPlatform.windows: _keyboardShortcutDefaultsWinLinux,
  TargetPlatform.linux: _keyboardShortcutDefaultsWinLinux,
};

ShortcutModel defaultShortcutModel(KeyboardShortcut shortcut) {
  final map = _keyboardShortcutDefaultsByPlatform[defaultTargetPlatform] ?? _keyboardShortcutDefaultsWinLinux;
  return map[shortcut] ?? _keyboardShortcutDefaultsWinLinux[shortcut]!;
}

@freezed
abstract class ShortcutModel with _$ShortcutModel {
  const ShortcutModel._();

  const factory ShortcutModel({
    required int keyId,
    @Default(false) bool meta,
    @Default(false) bool control,
    @Default(false) bool alt,
    @Default(false) bool shift,
  }) = _ShortcutModel;

  factory ShortcutModel.fromJson(Map<String, dynamic> json) => _$ShortcutModelFromJson(json);

  factory ShortcutModel.fromSingleActivator(SingleActivator a) {
    return ShortcutModel(
      keyId: a.trigger.keyId,
      meta: a.meta,
      control: a.control,
      alt: a.alt,
      shift: a.shift,
    );
  }

  SingleActivator? toSingleActivator() {
    final trigger = LogicalKeyboardKey.findKeyByKeyId(keyId);
    if (trigger == null) {
      return null;
    }
    return SingleActivator(
      trigger,
      meta: meta,
      control: control,
      alt: alt,
      shift: shift,
    );
  }

  static ShortcutModel? fromStorageJson(String raw) {
    if (raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final model = ShortcutModel.fromJson(decoded);
      final activator = model.toSingleActivator();
      if (activator == null) {
        return null;
      }
      return ShortcutModel.fromSingleActivator(activator);
    } catch (_) {
      return null;
    }
  }

  String toStorageJson() => jsonEncode(toJson());

  static final Map<int, String> _triggerDisplaySymbolByKeyId = {
    LogicalKeyboardKey.arrowUp.keyId: '↑',
    LogicalKeyboardKey.arrowDown.keyId: '↓',
    LogicalKeyboardKey.arrowLeft.keyId: '←',
    LogicalKeyboardKey.arrowRight.keyId: '→',
    LogicalKeyboardKey.pageUp.keyId: 'PgUp',
    LogicalKeyboardKey.pageDown.keyId: 'PgDn',
    LogicalKeyboardKey.enter.keyId: '↵',
    LogicalKeyboardKey.numpadEnter.keyId: '↵',
    LogicalKeyboardKey.tab.keyId: 'Tab',
    LogicalKeyboardKey.backspace.keyId: 'Backspace',
    LogicalKeyboardKey.delete.keyId: 'Delete',
    LogicalKeyboardKey.escape.keyId: 'Esc',
  };

  static String _triggerDisplayLabel(LogicalKeyboardKey trigger) {
    final symbol = _triggerDisplaySymbolByKeyId[trigger.keyId];
    if (symbol != null) {
      return symbol;
    }
    final label = trigger.keyLabel;
    if (label.isNotEmpty && label != ' ') {
      return label.length == 1 ? label.toUpperCase() : label;
    }
    return trigger.debugName ?? '?';
  }

  String toDisplayString() {
    final trigger = LogicalKeyboardKey.findKeyByKeyId(keyId);
    final String triggerLabel;
    if (trigger == null) {
      triggerLabel = '?';
    } else {
      triggerLabel = _triggerDisplayLabel(trigger);
    }
    final mac = defaultTargetPlatform == TargetPlatform.macOS;
    final mods = <String>[];
    if (mac) {
      if (meta) mods.add('⌘');
      if (control) mods.add('⌃');
      if (alt) mods.add('⌥');
      if (shift) mods.add('⇧');
    } else {
      if (meta) mods.add('Meta');
      if (control) mods.add('Ctrl');
      if (alt) mods.add('Alt');
      if (shift) mods.add('Shift');
    }
    return mac ? [...mods, triggerLabel].join(' ') : [...mods, triggerLabel].join(' + ');
  }
}
