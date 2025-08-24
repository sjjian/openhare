import 'package:client/models/settings.dart';
import 'package:client/repositories/settings/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
