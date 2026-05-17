import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/models/keyboard.dart';

part 'settings.freezed.dart';

abstract class SettingsRepo {
  SystemSettingModel getSettings();
  void setLanguage(String language);
  void setTheme(String theme);
  String getShortcut(KeyboardShortcut kind);
  void setShortcut(KeyboardShortcut kind, String json);
}

@freezed
abstract class SystemSettingModel with _$SystemSettingModel {
  const factory SystemSettingModel({
    required String theme,
    required String language,

    /// 键为 [KeyboardShortcut.name], 值为 [ShortcutModel.toStorageJson]，缺失或空串表示内置默认。
    @Default(<String, String>{}) Map<String, String> shortcuts,
  }) = _SystemSettingModel;
}

enum SettingType {
  system,
  llmApi,
}

@freezed
abstract class SettingTabModel with _$SettingTabModel {
  const factory SettingTabModel({
    required SettingType selectedSettingType,
  }) = _SettingTabModel;
}

@freezed
abstract class SettingModel with _$SettingModel {
  const factory SettingModel({
    required SettingTabModel settingTab,
    required SystemSettingModel systemSetting,
    // required List<LLMApiSettingModel> llmApiSettings,
  }) = _SettingModel;
}
