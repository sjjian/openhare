// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_drawer_metadata.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionMetadataStateHash() =>
    r'184e222c391343966dcb6371efb55b007daa90e3';

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

/// See also [sessionMetadataState].
@ProviderFor(sessionMetadataState)
const sessionMetadataStateProvider = SessionMetadataStateFamily();

/// See also [sessionMetadataState].
class SessionMetadataStateFamily extends Family<InstanceMetadataModel> {
  /// See also [sessionMetadataState].
  const SessionMetadataStateFamily();

  /// See also [sessionMetadataState].
  SessionMetadataStateProvider call(
    int sessionId,
  ) {
    return SessionMetadataStateProvider(
      sessionId,
    );
  }

  @override
  SessionMetadataStateProvider getProviderOverride(
    covariant SessionMetadataStateProvider provider,
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
  String? get name => r'sessionMetadataStateProvider';
}

/// See also [sessionMetadataState].
class SessionMetadataStateProvider extends Provider<InstanceMetadataModel> {
  /// See also [sessionMetadataState].
  SessionMetadataStateProvider(
    int sessionId,
  ) : this._internal(
          (ref) => sessionMetadataState(
            ref as SessionMetadataStateRef,
            sessionId,
          ),
          from: sessionMetadataStateProvider,
          name: r'sessionMetadataStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionMetadataStateHash,
          dependencies: SessionMetadataStateFamily._dependencies,
          allTransitiveDependencies:
              SessionMetadataStateFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionMetadataStateProvider._internal(
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
    InstanceMetadataModel Function(SessionMetadataStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionMetadataStateProvider._internal(
        (ref) => create(ref as SessionMetadataStateRef),
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
  ProviderElement<InstanceMetadataModel> createElement() {
    return _SessionMetadataStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionMetadataStateProvider &&
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
mixin SessionMetadataStateRef on ProviderRef<InstanceMetadataModel> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionMetadataStateProviderElement
    extends ProviderElement<InstanceMetadataModel>
    with SessionMetadataStateRef {
  _SessionMetadataStateProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionMetadataStateProvider).sessionId;
}

String _$sessionMetadataControllerHash() =>
    r'63e23f1c7a2559b77f08a7f07f688c6bdb944613';

/// See also [SessionMetadataController].
@ProviderFor(SessionMetadataController)
final sessionMetadataControllerProvider =
    NotifierProvider<SessionMetadataController, InstanceMetadataModel>.internal(
  SessionMetadataController.new,
  name: r'sessionMetadataControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionMetadataControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionMetadataController = Notifier<InstanceMetadataModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
