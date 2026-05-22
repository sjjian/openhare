import 'package:client/models/keyboard.dart';
import 'package:client/models/settings.dart';
import 'package:client/repositories/settings/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:client/models/keyboard.dart';

part 'settings.g.dart';

class ShortcutBindingConflictException implements Exception {
  ShortcutBindingConflictException();
}

class ShortcutCombinationRequiredException implements Exception {
  ShortcutCombinationRequiredException();
}

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

  void setShortcutModel(KeyboardShortcut kind, ShortcutModel model) {
    // precheck
    assert(canUpdateShortcutKinds.contains(kind));

    if (!model.isCombinationShortcut) {
      throw ShortcutCombinationRequiredException();
    }

    // check conflict
    for (final k in KeyboardShortcut.values) {
      if (k == kind) {
        continue;
      }
      final stored = getShortcutModel(k);
      if (stored == model) {
        throw ShortcutBindingConflictException();
      }
    }
    // save
    ref.read(settingsRepoProvider).setShortcut(kind, model);
    ref.invalidateSelf();
  }

  ShortcutModel getShortcutModel(KeyboardShortcut shortcut) {
    // 如何快捷键是可配置的，则从存储中获取，否则返回默认值
    if (canUpdateShortcutKinds.contains(shortcut)) {
      final stored = ref.read(settingsRepoProvider).getShortcut(shortcut);
      if (stored != null) {
        final activator = stored.toSingleActivator();
        if (activator != null) {
          return ShortcutModel.fromSingleActivator(activator);
        }
      }
      return defaultShortcutModel(shortcut);
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
