// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_drawer_body.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionDrawerStateHash() =>
    r'19bfa943162037345b32a367a5b440bb6d5c3390';

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
class SessionDrawerStateProvider extends Provider<SessionDrawerModel> {
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
  int get sessionId;
}

class _SessionDrawerStateProviderElement
    extends ProviderElement<SessionDrawerModel> with SessionDrawerStateRef {
  _SessionDrawerStateProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionDrawerStateProvider).sessionId;
}

String _$sessionDrawerControllerHash() =>
    r'ea10bb312b465fbff11c019e25e56ef614fc33d7';

/// See also [SessionDrawerController].
@ProviderFor(SessionDrawerController)
final sessionDrawerControllerProvider =
    NotifierProvider<SessionDrawerController, SessionDrawerModel>.internal(
  SessionDrawerController.new,
  name: r'sessionDrawerControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionDrawerControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionDrawerController = Notifier<SessionDrawerModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
