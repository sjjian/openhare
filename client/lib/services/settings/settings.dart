import 'package:client/models/settings.dart';
import 'package:client/repositories/settings/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

@Riverpod(keepAlive: true)
class SettingService extends _$SettingService {
  @override
  SettingModel build() {
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
