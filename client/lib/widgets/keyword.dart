import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum KeyboardShortcut {
  sqlExecute,
  sqlExecuteAdd,
  sqlExplain,
  sqlExport,
  // 下面的快捷键由SQL编辑器库内部实现，这里仅定义用于展示
  copy,
  paste,
  selectAll,
  undo,
  redo,
}

class _KeyboardShortcutDefinition {
  const _KeyboardShortcutDefinition({
    required this.activator,
    required this.label,
  });

  final SingleActivator activator;
  final String label; // 用于展示
}

const _macOSKeyboardShortcuts = <KeyboardShortcut, _KeyboardShortcutDefinition>{
  KeyboardShortcut.copy: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.keyC, meta: true),
    label: '⌘ C',
  ),
  KeyboardShortcut.paste: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.keyV, meta: true),
    label: '⌘ V',
  ),
  KeyboardShortcut.selectAll: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.keyA, meta: true),
    label: '⌘ A',
  ),
  KeyboardShortcut.undo: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
    label: '⌘ Z',
  ),
  KeyboardShortcut.redo: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true),
    label: '⇧ ⌘ Z',
  ),
  KeyboardShortcut.sqlExecute: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.digit1, meta: true),
    label: '⌘ 1',
  ),
  KeyboardShortcut.sqlExecuteAdd: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.digit2, meta: true),
    label: '⌘ 2',
  ),
  KeyboardShortcut.sqlExplain: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.digit3, meta: true),
    label: '⌘ 3',
  ),
  KeyboardShortcut.sqlExport: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.digit4, meta: true),
    label: '⌘ 4',
  ),
};

const _commonKeyboardShortcuts = <KeyboardShortcut, _KeyboardShortcutDefinition>{
  KeyboardShortcut.copy: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.keyC, control: true),
    label: 'Ctrl + C',
  ),
  KeyboardShortcut.paste: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.keyV, control: true),
    label: 'Ctrl + V',
  ),
  KeyboardShortcut.selectAll: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.keyA, control: true),
    label: 'Ctrl + A',
  ),
  KeyboardShortcut.undo: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.keyZ, control: true),
    label: 'Ctrl + Z',
  ),
  KeyboardShortcut.redo: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true),
    label: 'Ctrl + Shift + Z',
  ),
  KeyboardShortcut.sqlExecute: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.digit1, control: true),
    label: 'Ctrl + 1',
  ),
  KeyboardShortcut.sqlExecuteAdd: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.digit2, control: true),
    label: 'Ctrl + 2',
  ),
  KeyboardShortcut.sqlExplain: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.digit3, control: true),
    label: 'Ctrl + 3',
  ),
  KeyboardShortcut.sqlExport: _KeyboardShortcutDefinition(
    activator: SingleActivator(LogicalKeyboardKey.digit4, control: true),
    label: 'Ctrl + 4',
  ),
};

const _platformKeyboardShortcuts = <TargetPlatform, Map<KeyboardShortcut, _KeyboardShortcutDefinition>>{
  TargetPlatform.macOS: _macOSKeyboardShortcuts,
  TargetPlatform.windows: _commonKeyboardShortcuts,
  TargetPlatform.linux: _commonKeyboardShortcuts,
};

SingleActivator keyboardShortcutActivator(KeyboardShortcut shortcut) {
  return _keyboardShortcutDefinition(shortcut).activator;
}

String keyboardShortcutLabel(KeyboardShortcut shortcut) {
  return _keyboardShortcutDefinition(shortcut).label;
}

String keyboardShortcutTooltip(String tooltip, KeyboardShortcut shortcut) {
  return '$tooltip (${keyboardShortcutLabel(shortcut)})';
}

_KeyboardShortcutDefinition _keyboardShortcutDefinition(KeyboardShortcut shortcut) {
  final shortcuts = _platformKeyboardShortcuts[defaultTargetPlatform] ?? _commonKeyboardShortcuts;
  return shortcuts[shortcut] ?? _commonKeyboardShortcuts[shortcut]!;
}
