import 'package:client/models/settings.dart';
import 'package:client/repositories/repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/repositories/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

part 'settings.g.dart';

@Entity()
class SettingsStorage {
  @Id(assignable: true)
  int id;

  String theme;
  String language;

  SettingsStorage({
    this.id = 1,
    required this.theme,
    required this.language,
  });
}

@Entity()
class LLMApiSettingStorage {
  @Id(assignable: true)
  int id;

  String name;
  String baseUrl;
  String apiKey;
  String modelName;

  LLMApiSettingStorage({
    this.id = 0,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    required this.modelName,
  });
}

class SettingsRepoImpl implements SettingsRepo {
  final ObjectBox ob;
  final Box<SettingsStorage> _settingBox;
  final Box<LLMApiSettingStorage> _llmApiSettingBox;

  SettingsRepoImpl(this.ob)
      : _settingBox = ob.store.box(),
        _llmApiSettingBox = ob.store.box();

  SettingsStorage _getSettings() {
    final settings = _settingBox.get(1);
    if (settings != null) {
      return settings;
    } else {
      return SettingsStorage(theme: 'light', language: 'zh');
    }
  }

  @override
  SystemSettingModel getSettings() {
    final settings = _getSettings();
    return SystemSettingModel(
        theme: settings.theme, language: settings.language);
  }

  @override
  void setLanguage(String language) {
    final settings = _getSettings();
    settings.language = language;
    _settingBox.put(settings);
  }

  @override
  void setTheme(String theme) {
    final settings = _getSettings();
    settings.theme = theme;
    _settingBox.put(settings);
  }

  @override
  void addLLMApiSetting(LLMApiSettingModel setting) {
    final llmApiSetting = LLMApiSettingStorage(
      name: setting.name,
      baseUrl: setting.baseUrl,
      apiKey: setting.apiKey,
      modelName: setting.modelName,
    );
    _llmApiSettingBox.put(llmApiSetting);
  }

  @override
  void updateLLMApiSetting(LLMApiSettingModel model) {
    final llmApiSetting = _llmApiSettingBox.get(model.id.value);
    if (llmApiSetting == null) {
      return;
    }
    llmApiSetting.name = model.name;
    llmApiSetting.baseUrl = model.baseUrl;
    llmApiSetting.apiKey = model.apiKey;
    llmApiSetting.modelName = model.modelName;

    _llmApiSettingBox.put(llmApiSetting);
  }

  @override
  List<LLMApiSettingModel> getLLMApiSettings() {
    final llmApiSettings = _llmApiSettingBox.getAll();
    return llmApiSettings
        .map((e) => LLMApiSettingModel(
              id: LLMApiSettingId(value: e.id),
              name: e.name,
              baseUrl: e.baseUrl,
              apiKey: e.apiKey,
              modelName: e.modelName,
            ))
        .toList();
  }

  @override
  void removeLLMApiSetting(LLMApiSettingId id) {
    _llmApiSettingBox.remove(id.value);
  }
}

@Riverpod(keepAlive: true)
SettingsRepo settingsRepo(Ref ref) {
  ObjectBox ob = ref.watch(objectboxProvider);
  return SettingsRepoImpl(ob);
}
