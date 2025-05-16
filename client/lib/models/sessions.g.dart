// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionRepoHash() => r'e430ea4ab66b65bcd4bb1647ce2a886b6e32b66a';

/// See also [sessionRepo].
@ProviderFor(sessionRepo)
final sessionRepoProvider = Provider<SessionRepo>.internal(
  sessionRepo,
  name: r'sessionRepoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sessionRepoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionRepoRef = ProviderRef<SessionRepo>;
String _$currentSessionHash() => r'7a845125b710449daef1784e4ab318cd5500a0d0';

/// See also [currentSession].
@ProviderFor(currentSession)
final currentSessionProvider = Provider<CurrentSession?>.internal(
  currentSession,
  name: r'currentSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentSessionRef = ProviderRef<CurrentSession?>;
String _$sessionDrawerStateHash() =>
    r'626fd64b436d1add45920f977dfa0f878fda5258';

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

/// See also [sessionDrawerState].
@ProviderFor(sessionDrawerState)
const sessionDrawerStateProvider = SessionDrawerStateFamily();

/// See also [sessionDrawerState].
class SessionDrawerStateFamily extends Family<CurrentSessionDrawer?> {
  /// See also [sessionDrawerState].
  const SessionDrawerStateFamily();

  /// See also [sessionDrawerState].
  SessionDrawerStateProvider call(
    int sessionId,
  ) {
    return SessionDrawerStateProvider(
      sessionId,
    );
  }

  @override
  SessionDrawerStateProvider getProviderOverride(
    covariant SessionDrawerStateProvider provider,
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
  String? get name => r'sessionDrawerStateProvider';
}

/// See also [sessionDrawerState].
class SessionDrawerStateProvider extends Provider<CurrentSessionDrawer?> {
  /// See also [sessionDrawerState].
  SessionDrawerStateProvider(
    int sessionId,
  ) : this._internal(
          (ref) => sessionDrawerState(
            ref as SessionDrawerStateRef,
            sessionId,
          ),
          from: sessionDrawerStateProvider,
          name: r'sessionDrawerStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionDrawerStateHash,
          dependencies: SessionDrawerStateFamily._dependencies,
          allTransitiveDependencies:
              SessionDrawerStateFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionDrawerStateProvider._internal(
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
    CurrentSessionDrawer? Function(SessionDrawerStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionDrawerStateProvider._internal(
        (ref) => create(ref as SessionDrawerStateRef),
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
  ProviderElement<CurrentSessionDrawer?> createElement() {
    return _SessionDrawerStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionDrawerStateProvider && other.sessionId == sessionId;
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
mixin SessionDrawerStateRef on ProviderRef<CurrentSessionDrawer?> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionDrawerStateProviderElement
    extends ProviderElement<CurrentSessionDrawer?> with SessionDrawerStateRef {
  _SessionDrawerStateProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionDrawerStateProvider).sessionId;
}

String _$sessionConnHash() => r'a25cd0d5b7b77efd136a24d69ae097cb2d4370ad';

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
