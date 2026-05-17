import 'dart:convert';

import 'package:client/models/keyboard.dart';
import 'package:client/models/settings.dart';
import 'package:client/repositories/settings/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:client/models/keyboard.dart';

part 'settings.g.dart';

@Riverpod(keepAlive: true)
class SystemSettingService extends _$SystemSettingService {
  @override
  SystemSettingModel build() {
    return ref.watch(settingsRepoProvider).getSettings();
  }

  void setLanguage(String language) {
    ref.read(settingsRepoProvider).setLanguage(language);
    ref.invalidateSelf();
  }

  void setTheme(String theme) {
    ref.read(settingsRepoProvider).setTheme(theme);
    ref.invalidateSelf();
  }

  void setShortcutModel(KeyboardShortcut kind, ShortcutModel? model) {
    assert(canUpdateShortcutKinds.contains(kind));
    final json = model != null ? model.toStorageJson() : '';
    ref.read(settingsRepoProvider).setShortcut(kind, json);
    ref.invalidateSelf();
  }

  ShortcutModel getShortcutModel(KeyboardShortcut shortcut) {
    if (canUpdateShortcutKinds.contains(shortcut)) {
      return _shortcutModelResolved(shortcut);
    }
    return defaultShortcutModel(shortcut);
  }

  /// 将 [updating] 设为 [candidateForUpdating] 后，快捷键是否出现重复 [SingleActivator]。
  bool shortcutsConflict({
    required KeyboardShortcut updating,
    required ShortcutModel candidateForUpdating,
  }) {
    final seen = <SingleActivator>{};
    for (final kind in canUpdateShortcutKinds) {
      final m = kind == updating ? candidateForUpdating : _shortcutModelResolved(kind);
      if (!seen.add(m.toSingleActivator()!)) {
        return true;
      }
    }
    return false;
  }

  ShortcutModel _shortcutModelResolved(KeyboardShortcut shortcut) {
    final raw = state.shortcuts[shortcut.name] ?? '';
    if (raw.isNotEmpty) {
      try {
        final parsed = jsonDecode(raw);
        if (parsed is Map<String, dynamic>) {
          final decoded = ShortcutModel.fromJson(parsed);
          final activator = decoded.toSingleActivator();
          if (activator != null) {
            return ShortcutModel.fromSingleActivator(activator);
          }
        }
      } catch (_) {}
    }
    return defaultShortcutModel(shortcut);
  }
}

@Riverpod(keepAlive: true)
class SettingTabService extends _$SettingTabService {
  @override
  SettingTabModel build() {
    return const SettingTabModel(selectedSettingType: SettingType.system);
  }

  void setSelectedSettingType(SettingType settingType) {
    state = state.copyWith(selectedSettingType: settingType);
  }
}

@Riverpod(keepAlive: true)
class SystemSettingNotifier extends _$SystemSettingNotifier {
  @override
  SystemSettingModel build() {
    return ref.watch(systemSettingServiceProvider);
  }
}

@Riverpod(keepAlive: true)
class SettingNotifier extends _$SettingNotifier {
  @override
  SettingModel build() {
    return SettingModel(
      settingTab: ref.watch(settingTabServiceProvider),
      systemSetting: ref.watch(systemSettingServiceProvider),
    );
  }
}
