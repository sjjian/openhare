// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conn.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connManagerHash() => r'696868a23e4ddf119ad1e2798d3c90ae41005185';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [connManager].
@ProviderFor(connManager)
const connManagerProvider = ConnManagerFamily();

/// See also [connManager].
class ConnManagerFamily extends Family<ConnManager> {
  /// See also [connManager].
  const ConnManagerFamily();

  /// See also [connManager].
  ConnManagerProvider call(
    int sessionId,
  ) {
    return ConnManagerProvider(
      sessionId,
    );
  }

  @override
  ConnManagerProvider getProviderOverride(
    covariant ConnManagerProvider provider,
  ) {
    return call(
      provider.sessionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'connManagerProvider';
}

/// See also [connManager].
class ConnManagerProvider extends Provider<ConnManager> {
  /// See also [connManager].
  ConnManagerProvider(
    int sessionId,
  ) : this._internal(
          (ref) => connManager(
            ref as ConnManagerRef,
            sessionId,
          ),
          from: connManagerProvider,
          name: r'connManagerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$connManagerHash,
          dependencies: ConnManagerFamily._dependencies,
          allTransitiveDependencies:
              ConnManagerFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  ConnManagerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final int sessionId;

  @override
  Override overrideWith(
    ConnManager Function(ConnManagerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConnManagerProvider._internal(
        (ref) => create(ref as ConnManagerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  ProviderElement<ConnManager> createElement() {
    return _ConnManagerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConnManagerProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConnManagerRef on ProviderRef<ConnManager> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _ConnManagerProviderElement extends ProviderElement<ConnManager>
    with ConnManagerRef {
  _ConnManagerProviderElement(super.provider);

  @override
  int get sessionId => (origin as ConnManagerProvider).sessionId;
}

String _$sessionConnHash() => r'925ab6c1a55e00299a4f2885203cdd7828770d74';

/// See also [sessionConn].
@ProviderFor(sessionConn)
const sessionConnProvider = SessionConnFamily();

/// See also [sessionConn].
class SessionConnFamily extends Family<SessionConn> {
  /// See also [sessionConn].
  const SessionConnFamily();

  /// See also [sessionConn].
  SessionConnProvider call(
    int sessionId,
  ) {
    return SessionConnProvider(
      sessionId,
    );
  }

  @override
  SessionConnProvider getProviderOverride(
    covariant SessionConnProvider provider,
  ) {
    return call(
      provider.sessionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sessionConnProvider';
}

/// See also [sessionConn].
class SessionConnProvider extends Provider<SessionConn> {
  /// See also [sessionConn].
  SessionConnProvider(
    int sessionId,
  ) : this._internal(
          (ref) => sessionConn(
            ref as SessionConnRef,
            sessionId,
          ),
          from: sessionConnProvider,
          name: r'sessionConnProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionConnHash,
          dependencies: SessionConnFamily._dependencies,
          allTransitiveDependencies:
              SessionConnFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionConnProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final int sessionId;

  @override
  Override overrideWith(
    SessionConn Function(SessionConnRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionConnProvider._internal(
        (ref) => create(ref as SessionConnRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  ProviderElement<SessionConn> createElement() {
    return _SessionConnProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionConnProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionConnRef on ProviderRef<SessionConn> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionConnProviderElement extends ProviderElement<SessionConn>
    with SessionConnRef {
  _SessionConnProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionConnProvider).sessionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
