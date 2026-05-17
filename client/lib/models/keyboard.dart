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
  // 下面的快捷键由 SQL 编辑器库内部实现，这里仅定义用于展示
  copy,
  paste,
  selectAll,
  undo,
  redo,
}

const canUpdateShortcutKinds = <KeyboardShortcut>{
  KeyboardShortcut.sqlExecute,
  KeyboardShortcut.sqlExecuteAdd,
  KeyboardShortcut.sqlExplain,
  KeyboardShortcut.sqlExport,
};

final _keyboardShortcutDefaultsMacOS = <KeyboardShortcut, ShortcutModel>{
  KeyboardShortcut.copy: ShortcutModel(keyId: LogicalKeyboardKey.keyC.keyId, meta: true),
  KeyboardShortcut.paste: ShortcutModel(keyId: LogicalKeyboardKey.keyV.keyId, meta: true),
  KeyboardShortcut.selectAll: ShortcutModel(keyId: LogicalKeyboardKey.keyA.keyId, meta: true),
  KeyboardShortcut.undo: ShortcutModel(keyId: LogicalKeyboardKey.keyZ.keyId, meta: true),
  KeyboardShortcut.redo: ShortcutModel(keyId: LogicalKeyboardKey.keyZ.keyId, meta: true, shift: true),
  KeyboardShortcut.sqlExecute: ShortcutModel(keyId: LogicalKeyboardKey.digit1.keyId, meta: true),
  KeyboardShortcut.sqlExecuteAdd: ShortcutModel(keyId: LogicalKeyboardKey.digit2.keyId, meta: true),
  KeyboardShortcut.sqlExplain: ShortcutModel(keyId: LogicalKeyboardKey.digit3.keyId, meta: true),
  KeyboardShortcut.sqlExport: ShortcutModel(keyId: LogicalKeyboardKey.digit4.keyId, meta: true),
};

final _keyboardShortcutDefaultsWinLinux = <KeyboardShortcut, ShortcutModel>{
  KeyboardShortcut.copy: ShortcutModel(keyId: LogicalKeyboardKey.keyC.keyId, control: true),
  KeyboardShortcut.paste: ShortcutModel(keyId: LogicalKeyboardKey.keyV.keyId, control: true),
  KeyboardShortcut.selectAll: ShortcutModel(keyId: LogicalKeyboardKey.keyA.keyId, control: true),
  KeyboardShortcut.undo: ShortcutModel(keyId: LogicalKeyboardKey.keyZ.keyId, control: true),
  KeyboardShortcut.redo: ShortcutModel(keyId: LogicalKeyboardKey.keyZ.keyId, control: true, shift: true),
  KeyboardShortcut.sqlExecute: ShortcutModel(keyId: LogicalKeyboardKey.digit1.keyId, control: true),
  KeyboardShortcut.sqlExecuteAdd: ShortcutModel(keyId: LogicalKeyboardKey.digit2.keyId, control: true),
  KeyboardShortcut.sqlExplain: ShortcutModel(keyId: LogicalKeyboardKey.digit3.keyId, control: true),
  KeyboardShortcut.sqlExport: ShortcutModel(keyId: LogicalKeyboardKey.digit4.keyId, control: true),
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

  String toStorageJson() => jsonEncode(toJson());

  String toDisplayString() {
    final trigger = LogicalKeyboardKey.findKeyByKeyId(keyId);
    final String triggerLabel;
    if (trigger == null) {
      triggerLabel = '?';
    } else {
      final label = trigger.keyLabel;
      if (label.isNotEmpty && label != ' ') {
        triggerLabel = label.length == 1 ? label.toUpperCase() : label;
      } else {
        triggerLabel = trigger.debugName ?? '?';
      }
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
