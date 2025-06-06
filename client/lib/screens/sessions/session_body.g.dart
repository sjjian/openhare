// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_body.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionSplitViewStateHash() =>
    r'78724f95d90323f72d5adb3c2508ada6ae45a8aa';

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
class SessionSplitViewStateFamily extends Family<CurrentSessionSplitView> {
  /// See also [sessionSplitViewState].
  const SessionSplitViewStateFamily();

  /// See also [sessionSplitViewState].
  SessionSplitViewStateProvider call(
    int sessionId,
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
class SessionSplitViewStateProvider extends Provider<CurrentSessionSplitView> {
  /// See also [sessionSplitViewState].
  SessionSplitViewStateProvider(
    int sessionId,
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

  final int sessionId;

  @override
  Override overrideWith(
    CurrentSessionSplitView Function(SessionSplitViewStateRef provider) create,
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
  ProviderElement<CurrentSessionSplitView> createElement() {
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
mixin SessionSplitViewStateRef on ProviderRef<CurrentSessionSplitView> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionSplitViewStateProviderElement
    extends ProviderElement<CurrentSessionSplitView>
    with SessionSplitViewStateRef {
  _SessionSplitViewStateProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionSplitViewStateProvider).sessionId;
}

String _$sessionSplitViewControllerHash() =>
    r'1157471642f90baaaf7ecaf79a2c12f3d29ccb4a';

/// See also [SessionSplitViewController].
@ProviderFor(SessionSplitViewController)
final sessionSplitViewControllerProvider = NotifierProvider<
    SessionSplitViewController, CurrentSessionSplitView>.internal(
  SessionSplitViewController.new,
  name: r'sessionSplitViewControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionSplitViewControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionSplitViewController = Notifier<CurrentSessionSplitView>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
