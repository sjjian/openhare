import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:client/services/security/vault_service.dart';
import 'package:client/models/instances.dart';
import 'package:client/repositories/instances/instances.dart';
import 'package:db_driver/db_driver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureVaultService Tests', () {
    test('Write, Read, GetSync and Delete in Vault', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final vault = SecureVaultService();
      await vault.init();

      const testKey = 'test_secret_key';
      const testVal = 'my_super_secret_password';

      await vault.write(testKey, testVal);

      // Synchronous verification via in-memory cache
      expect(vault.getSync(testKey), equals(testVal));

      // Asynchronous verification
      final readVal = await vault.read(testKey);
      expect(readVal, equals(testVal));

      // Deletion
      await vault.delete(testKey);
      expect(vault.getSync(testKey), isNull);
      expect(await vault.read(testKey), isNull);
    });

    test('InstanceStorage.fromModel sanitizes passwords and ssh credentials', () {
      final model = InstanceModel(
        id: const InstanceId(value: 1),
        dbType: DatabaseType.pg,
        name: 'Production DB',
        target: const ConnectTarget.network(host: '10.0.0.1', port: 5432),
        sshTunnel: const SshTunnelConfig(
          enabled: true,
          host: 'bastion.example.com',
          port: 22,
          user: 'admin',
          password: 'ssh_secret_password',
          privateKeyPassphrase: 'ssh_private_key_passphrase',
        ),
        user: 'postgres',
        password: 'db_secret_password',
        desc: 'PostgreSQL Database',
        custom: {},
        initQuerys: [],
        activeSchemas: [],
        createdAt: DateTime.now(),
        latestOpenAt: DateTime.now(),
      );

      final storage = InstanceStorage.fromModel(model);

      // Password must be stored as empty string in ObjectBox
      expect(storage.password, equals(''));

      // SSH credentials must also be removed from saved JSON
      expect(storage.sshTunnelJson.contains('ssh_secret_password'), isFalse);
      expect(storage.sshTunnelJson.contains('ssh_private_key_passphrase'), isFalse);
    });

    test('InstanceStorage.toModel reconstructs secrets from SecureVaultService', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final vault = SecureVaultService();
      await vault.init();

      const instanceId = 42;
      await vault.write(
        SecureVaultService.instancePasswordKey(instanceId),
        'db_secret_password',
      );
      await vault.write(
        SecureVaultService.instanceSshPasswordKey(instanceId),
        'ssh_secret_password',
      );
      await vault.write(
        SecureVaultService.instanceSshPassphraseKey(instanceId),
        'ssh_private_key_passphrase',
      );

      final storage = InstanceStorage(
        id: instanceId,
        stDbType: DatabaseType.pg.index,
        name: 'Test DB',
        targetJson: '{"type":"network","host":"10.0.0.1","port":5432}',
        sshTunnelJson: '{"enabled":true,"host":"bastion.example.com","port":22,"user":"admin"}',
        host: 'deprecated',
        user: 'postgres',
        password: '', // Empty in ObjectBox
        desc: '',
        customJson: '{}',
        initQuerys: [],
      );

      final model = storage.toModel(vault: vault);

      expect(model.password, equals('db_secret_password'));
      expect(model.sshTunnel?.password, equals('ssh_secret_password'));
      expect(model.sshTunnel?.privateKeyPassphrase, equals('ssh_private_key_passphrase'));
    });
  });
}
