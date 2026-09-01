import 'dart:convert';
import 'package:client/repositories/instances/instances.dart';
import 'package:client/repositories/ai/agent.dart';
import 'package:client/repositories/repo.dart';
import 'package:client/services/security/vault_service.dart';
import 'package:client/utils/logger.dart';
import 'package:objectbox/objectbox.dart';

/// Transparent credential migration routine executed during application startup.
/// Migrates legacy plaintext passwords and keys stored in ObjectBox
/// to the native secure vault and wipes the plaintext fields from the local database.
Future<void> migrateCredentialsToObjectBoxVault(
  ObjectBox ob,
  SecureVaultService vault,
) async {
  try {
    // 1. Migrate database instance credentials
    final Box<InstanceStorage> instanceBox = ob.store.box<InstanceStorage>();
    final instances = instanceBox.getAll();
    for (final instance in instances) {
      bool modified = false;

      // Migrate database password
      if (instance.password.isNotEmpty) {
        await vault.write(
          SecureVaultService.instancePasswordKey(instance.id),
          instance.password,
        );
        instance.password = "";
        modified = true;
      }

      // Migrate SSH tunnel credentials
      if (instance.sshTunnelJson.trim().isNotEmpty) {
        try {
          final Map<String, dynamic> sshMap =
              Map<String, dynamic>.from(jsonDecode(instance.sshTunnelJson));

          final dynamic sshPassword = sshMap['password'];
          if (sshPassword is String && sshPassword.isNotEmpty) {
            await vault.write(
              SecureVaultService.instanceSshPasswordKey(instance.id),
              sshPassword,
            );
            sshMap.remove('password');
            modified = true;
          }

          final dynamic passphrase = sshMap['privateKeyPassphrase'];
          if (passphrase is String && passphrase.isNotEmpty) {
            await vault.write(
              SecureVaultService.instanceSshPassphraseKey(instance.id),
              passphrase,
            );
            sshMap.remove('privateKeyPassphrase');
            modified = true;
          }

          if (modified) {
            instance.sshTunnelJson = jsonEncode(sshMap);
          }
        } catch (e) {
          log.e('Failed to migrate sshTunnelJson for instance ${instance.id}', error: e);
        }
      }

      if (modified) {
        instanceBox.put(instance);
      }
    }

    // 2. Migrate AI API keys
    final Box<LLMApiSettingStorage> aiBox =
        ob.store.box<LLMApiSettingStorage>();
    final aiSettings = aiBox.getAll();
    for (final setting in aiSettings) {
      if (setting.apiKey.isNotEmpty) {
        await vault.write(
          SecureVaultService.aiApiKey(setting.id),
          setting.apiKey,
        );
        setting.apiKey = "";
        aiBox.put(setting);
      }
    }

    log.i('Credential migration to secure vault completed successfully.');
  } catch (e, st) {
    log.e('Failure during credential migration to secure vault', error: e, stackTrace: st);
  }
}
