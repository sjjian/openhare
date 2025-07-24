// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_body.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionSplitViewStateHash() =>
    r'1f3e904a48dd3977623cf68c07a8fcefddd5ca05';

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

/// See also [sessionSplitViewState].
@ProviderFor(sessionSplitViewState)
const sessionSplitViewStateProvider = SessionSplitViewStateFamily();

/// See also [sessionSplitViewState].
class SessionSplitViewStateFamily extends Family<SessionSplitViewModel> {
  /// See also [sessionSplitViewState].
  const SessionSplitViewStateFamily();

  /// See also [sessionSplitViewState].
  SessionSplitViewStateProvider call(
    SessionId sessionId,
  ) {
    return SessionSplitViewStateProvider(
      sessionId,
    );
  }

  @override
  SessionSplitViewStateProvider getProviderOverride(
    covariant SessionSplitViewStateProvider provider,
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
  String? get name => r'sessionSplitViewStateProvider';
}

/// See also [sessionSplitViewState].
class SessionSplitViewStateProvider extends Provider<SessionSplitViewModel> {
  /// See also [sessionSplitViewState].
  SessionSplitViewStateProvider(
    SessionId sessionId,
  ) : this._internal(
          (ref) => sessionSplitViewState(
            ref as SessionSplitViewStateRef,
            sessionId,
          ),
          from: sessionSplitViewStateProvider,
          name: r'sessionSplitViewStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionSplitViewStateHash,
          dependencies: SessionSplitViewStateFamily._dependencies,
          allTransitiveDependencies:
              SessionSplitViewStateFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionSplitViewStateProvider._internal(
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
    SessionSplitViewModel Function(SessionSplitViewStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionSplitViewStateProvider._internal(
        (ref) => create(ref as SessionSplitViewStateRef),
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
  ProviderElement<SessionSplitViewModel> createElement() {
    return _SessionSplitViewStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionSplitViewStateProvider &&
        other.sessionId == sessionId;
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
mixin SessionSplitViewStateRef on ProviderRef<SessionSplitViewModel> {
  /// The parameter `sessionId` of this provider.
  SessionId get sessionId;
}

class _SessionSplitViewStateProviderElement
    extends ProviderElement<SessionSplitViewModel>
    with SessionSplitViewStateRef {
  _SessionSplitViewStateProviderElement(super.provider);

  @override
  SessionId get sessionId =>
      (origin as SessionSplitViewStateProvider).sessionId;
}

String _$sessionSplitViewNotifierHash() =>
    r'73541b7a2440869576d70c9debf90175c5f69c50';

/// See also [SessionSplitViewNotifier].
@ProviderFor(SessionSplitViewNotifier)
final sessionSplitViewNotifierProvider =
    NotifierProvider<SessionSplitViewNotifier, SessionSplitViewModel>.internal(
  SessionSplitViewNotifier.new,
  name: r'sessionSplitViewNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionSplitViewNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionSplitViewNotifier = Notifier<SessionSplitViewModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
