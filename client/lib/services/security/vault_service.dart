import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_service.g.dart';

class SecureVaultService {
  final FlutterSecureStorage _storage;
  final Map<String, String> _cache = {};
  bool _isInitialized = false;

  SecureVaultService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              mOptions:
                  MacOsOptions(accessibility: KeychainAccessibility.unlocked),
              lOptions: LinuxOptions(),
              wOptions: WindowsOptions(),
            );

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final all = await _storage.readAll();
      _cache.addAll(all);
    } catch (_) {
      // In headless / non-Secret Service desktop environments, in-memory cache continues to work
    }
    _isInitialized = true;
  }

  String? getSync(String key) => _cache[key];

  Future<String?> read(String key) async {
    if (_cache.containsKey(key)) {
      return _cache[key];
    }
    try {
      final val = await _storage.read(key: key);
      if (val != null) {
        _cache[key] = val;
      }
      return val;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    _cache[key] = value;
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  Future<void> delete(String key) async {
    _cache.remove(key);
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  // Keys for database instances
  static String instancePasswordKey(int id) => 'instance_pwd_$id';
  static String instanceSshPasswordKey(int id) => 'instance_ssh_pwd_$id';
  static String instanceSshPassphraseKey(int id) => 'instance_ssh_passphrase_$id';

  // Key for AI agents and API keys
  static String aiApiKey(int id) => 'ai_agent_key_$id';
}

SecureVaultService defaultVaultService = SecureVaultService();

Future<void> initVaultService() async {
  defaultVaultService = SecureVaultService();
  await defaultVaultService.init();
}

@Riverpod(keepAlive: true)
SecureVaultService secureVaultService(Ref ref) {
  return defaultVaultService;
}
