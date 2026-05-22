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

  SettingsStorage({
    this.id = 1,
    required this.theme,
    required this.language,
  });
}

@Entity()
class ShortcutStorage {
  @Id(assignable: true)
  int id;

  @Unique()
  String kind;

  String bindingJson;

  ShortcutStorage({
    this.id = 0,
    required this.kind,
    this.bindingJson = '',
  });
}

class SettingsRepoImpl implements SettingsRepo {
  final ObjectBox ob;
  final Box<SettingsStorage> _settingBox;
  final Box<ShortcutStorage> _shortcutBox;

  SettingsRepoImpl(this.ob)
    : _settingBox = ob.store.box<SettingsStorage>(),
      _shortcutBox = ob.store.box<ShortcutStorage>();

  SettingsStorage _getSettings() {
    final settings = _settingBox.get(1);
    if (settings != null) {
      return settings;
    } else {
      return SettingsStorage(theme: 'light', language: 'en');
    }
  }

  ShortcutStorage? _findShortcutStorage(String kindName) {
    final q = _shortcutBox.query(ShortcutStorage_.kind.equals(kindName)).build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  @override
  SystemSettingModel getSettings() {
    final settings = _getSettings();
    return SystemSettingModel(
      theme: settings.theme,
      language: settings.language,
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
  ShortcutModel? getShortcut(KeyboardShortcut kind) {
    assert(canUpdateShortcutKinds.contains(kind));
    final row = _findShortcutStorage(kind.name);
    if (row == null) {
      return null;
    }
    return ShortcutModel.fromStorageJson(row.bindingJson);
  }

  @override
  void setShortcut(KeyboardShortcut kind, ShortcutModel? model) {
    assert(canUpdateShortcutKinds.contains(kind));
    final key = kind.name;
    final existing = _findShortcutStorage(key);
    if (model == null) {
      if (existing != null) {
        _shortcutBox.remove(existing.id);
      }
      return;
    }
    final row = ShortcutStorage(
      id: existing?.id ?? 0,
      kind: key,
      bindingJson: model.toStorageJson(),
    );
    _shortcutBox.put(row);
  }
}

@Riverpod(keepAlive: true)
SettingsRepo settingsRepo(Ref ref) {
  ObjectBox ob = ref.watch(objectboxProvider);
  return SettingsRepoImpl(ob);
}
