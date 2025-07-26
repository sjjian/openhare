import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';

abstract class SettingsRepo {
  SettingModel getSettings();
  void setLanguage(String language);
  void setTheme(String theme);
}

@freezed
abstract class SettingModel with _$SettingModel {
  const factory SettingModel({
    required String theme,
    required String language,
  }) = _SettingModel;
}
