import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'db_driver_conn_meta.dart';

class SshTunnel {
  SshTunnel({
    required this.config,
    required String targetHost,
    required int targetPort,
  })  : _targetHost = targetHost.trim(),
        _targetPort = targetPort;

  final SshTunnelConfig config;
  final String _targetHost;
  final int _targetPort;

  String? _host;
  int? _port;
  SSHClient? _client;
  ServerSocket? _serverSocket;
  StreamSubscription<Socket>? _subscription;
  bool _closed = false;

  String get host {
    final localHost = _host;
    if (localHost == null) {
      throw StateError('ssh tunnel is not open');
    }
    return localHost;
  }

  int get port {
    final localPort = _port;
    if (localPort == null) {
      throw StateError('ssh tunnel is not open');
    }
    return localPort;
  }

  bool get isOpen => _host != null && !_closed;

  void _validateConfig(SshTunnelConfig config) {
    if (config.host.trim().isEmpty) {
      throw StateError('ssh: bastion host is required');
    }
    if (config.user.trim().isEmpty) {
      throw StateError('ssh: user is required');
    }
    if (config.port <= 0 || config.port > 65535) {
      throw StateError('ssh: invalid bastion port ${config.port}');
    }
  }

  void _validateTarget(String targetHost, int targetPort) {
    if (targetHost.trim().isEmpty) {
      throw StateError('ssh: forward target host is required');
    }
    if (targetPort <= 0 || targetPort > 65535) {
      throw StateError('ssh: invalid forward target port $targetPort');
    }
  }

  Future<void> open() async {
    if (isOpen) {
      return;
    }
    _validateConfig(config);
    _validateTarget(_targetHost, _targetPort);

    final authMethod = resolveSshTunnelAuthMethod(config);
    final password = config.password?.trim() ?? '';
    final privateKeyPath = config.privateKeyPath?.trim() ?? '';

    List<SSHKeyPair>? identities;
    Future<String> Function()? onPasswordRequest;

    switch (authMethod) {
      case SshTunnelAuthMethod.password:
        if (password.isEmpty) {
          throw StateError('ssh: password is required');
        }
        onPasswordRequest = () async => password;
      case SshTunnelAuthMethod.privateKey:
        if (privateKeyPath.isEmpty) {
          throw StateError('ssh: private key path is required');
        }
        final pem = await File(privateKeyPath).readAsString();
        identities = SSHKeyPair.fromPem(pem, config.privateKeyPassphrase);
        if (identities.isEmpty) {
          throw StateError('ssh: no private key loaded from $privateKeyPath');
        }
    }

    SSHClient? client;
    ServerSocket? serverSocket;
    StreamSubscription<Socket>? subscription;
    try {
      final socket = await SSHSocket.connect(config.host.trim(), config.port);
      client = SSHClient(
        socket,
        username: config.user.trim(),
        disableHostkeyVerification: true, // todo: 暂时不校验known_hosts。
        identities: identities,
        onPasswordRequest: onPasswordRequest,
      );

      serverSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final localPort = serverSocket.port;
      final sshClient = client;

      subscription = serverSocket.listen((localSocket) {
        unawaited(_forwardConnection(
          client: sshClient,
          localSocket: localSocket,
          targetHost: _targetHost,
          targetPort: _targetPort,
        ));
      });

      _host = InternetAddress.loopbackIPv4.address;
      _port = localPort;
      _client = sshClient;
      _serverSocket = serverSocket;
      _subscription = subscription;
      _closed = false;
    } catch (e) {
      await subscription?.cancel();
      await serverSocket?.close();
      if (client != null) {
        client.close();
        await client.done;
      }
      rethrow;
    }
  }

  Future<void> _forwardConnection({
    required SSHClient client,
    required Socket localSocket,
    required String targetHost,
    required int targetPort,
  }) async {
    try {
      final forward = await client.forwardLocal(targetHost, targetPort);
      forward.stream.listen(
        localSocket.add,
        onDone: () => localSocket.close(),
        onError: (_, __) => localSocket.close(),
        cancelOnError: true,
      );
      localSocket.listen(
        (data) => forward.sink.add(data),
        onDone: () => forward.sink.close(),
        onError: (_, __) => forward.sink.close(),
        cancelOnError: true,
      );
    } catch (_) {
      await localSocket.close();
    }
  }

  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    await _subscription?.cancel();
    await _serverSocket?.close();
    _client?.close();
    if (_client != null) {
      await _client!.done;
    }
    _subscription = null;
    _serverSocket = null;
    _client = null;
    _host = null;
    _port = null;
  }
}
