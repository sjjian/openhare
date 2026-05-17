import 'dart:convert';

import 'package:client/models/keyboard.dart';
import 'package:client/models/settings.dart';
import 'package:client/repositories/repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/repositories/objectbox.g.dart';
// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart'; // 必须引入, 不然objectbox不能正常使用

part 'settings.g.dart';

@Entity()
class SettingsStorage {
  @Id(assignable: true)
  int id;

  String theme;
  String language;

  String shortcutsJson;

  SettingsStorage({
    this.id = 1,
    required this.theme,
    required this.language,
    this.shortcutsJson = '{}',
  });
}

Map<String, String> _decodeShortcutsJson(String raw) {
  if (raw.isEmpty) {
    return {};
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return {};
    }
    return decoded.map((k, v) => MapEntry(k.toString(), v is String ? v : jsonEncode(v)));
  } catch (_) {
    return {};
  }
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
      return SettingsStorage(theme: 'light', language: 'en');
    }
  }

  @override
  SystemSettingModel getSettings() {
    final settings = _getSettings();
    return SystemSettingModel(
      theme: settings.theme,
      language: settings.language,
      shortcuts: _decodeShortcutsJson(settings.shortcutsJson),
    );
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
  String getShortcut(KeyboardShortcut kind) {
    assert(
      const {
        KeyboardShortcut.sqlExecute,
        KeyboardShortcut.sqlExecuteAdd,
        KeyboardShortcut.sqlExplain,
        KeyboardShortcut.sqlExport,
      }.contains(kind),
    );
    final settings = _getSettings();
    final map = _decodeShortcutsJson(settings.shortcutsJson);
    return map[kind.name] ?? '';
  }

  @override
  void setShortcut(KeyboardShortcut kind, String json) {
    assert(
      const {
        KeyboardShortcut.sqlExecute,
        KeyboardShortcut.sqlExecuteAdd,
        KeyboardShortcut.sqlExplain,
        KeyboardShortcut.sqlExport,
      }.contains(kind),
    );
    final settings = _getSettings();
    final map = _decodeShortcutsJson(settings.shortcutsJson);
    final key = kind.name;
    if (json.isEmpty) {
      map.remove(key);
    } else {
      map[key] = json;
    }
    settings.shortcutsJson = jsonEncode(map);
    _settingBox.put(settings);
  }
}

@Riverpod(keepAlive: true)
SettingsRepo settingsRepo(Ref ref) {
  ObjectBox ob = ref.watch(objectboxProvider);
  return SettingsRepoImpl(ob);
}
