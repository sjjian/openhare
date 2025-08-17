import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';

abstract class SettingsRepo {
  SystemSettingModel getSettings();
  void setLanguage(String language);
  void setTheme(String theme);
  // void addLLMApiSetting(LLMApiSettingModel setting);
  // void updateLLMApiSetting(LLMApiSettingModel setting);
  // List<LLMApiSettingModel> getLLMApiSettings();
  // void removeLLMApiSetting(LLMApiSettingId id);
}

@freezed
abstract class SystemSettingModel with _$SystemSettingModel {
  const factory SystemSettingModel({
    required String theme,
    required String language,
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