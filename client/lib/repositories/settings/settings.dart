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

class SettingsRepoImpl implements SettingsRepo {
  final ObjectBox ob;
  final Box<SettingsStorage> _settingBox;

  SettingsRepoImpl(this.ob) : _settingBox = ob.store.box();

  SettingsStorage _getSettings() {
    final settings = _settingBox.get(1);
    if (settings != null) {
      return settings;
    } else {
      return SettingsStorage(theme: 'light', language: 'zh');
    }
  }

  @override
  SettingModel getSettings() {
    final settings = _getSettings();
    return SettingModel(theme: settings.theme, language: settings.language);
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
}

@Riverpod(keepAlive: true)
SettingsRepo settingsRepo(Ref ref) {
  ObjectBox ob = ref.watch(objectboxProvider);
  return SettingsRepoImpl(ob);
}
