// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_drawer_body.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionDrawerStateHash() =>
    r'e8954f01db2960aebb5987624ffdc25084b99e3d';

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
class SessionDrawerStateFamily extends Family<SessionDrawerModel> {
  /// See also [sessionDrawerState].
  const SessionDrawerStateFamily();

  /// See also [sessionDrawerState].
  SessionDrawerStateProvider call(
    SessionId sessionId,
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
class SessionDrawerStateProvider extends Provider<SessionDrawerModel> {
  /// See also [sessionDrawerState].
  SessionDrawerStateProvider(
    SessionId sessionId,
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

  final SessionId sessionId;

  @override
  Override overrideWith(
    SessionDrawerModel Function(SessionDrawerStateRef provider) create,
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
  ProviderElement<SessionDrawerModel> createElement() {
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
mixin SessionDrawerStateRef on ProviderRef<SessionDrawerModel> {
  /// The parameter `sessionId` of this provider.
  SessionId get sessionId;
}

class _SessionDrawerStateProviderElement
    extends ProviderElement<SessionDrawerModel> with SessionDrawerStateRef {
  _SessionDrawerStateProviderElement(super.provider);

  @override
  SessionId get sessionId => (origin as SessionDrawerStateProvider).sessionId;
}

String _$sessionDrawerNotifierHash() =>
    r'a83e2d2145985bc65c6e66ea4679e82b578b0c3e';

/// See also [SessionDrawerNotifier].
@ProviderFor(SessionDrawerNotifier)
final sessionDrawerNotifierProvider =
    NotifierProvider<SessionDrawerNotifier, SessionDrawerModel>.internal(
  SessionDrawerNotifier.new,
  name: r'sessionDrawerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionDrawerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionDrawerNotifier = Notifier<SessionDrawerModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
