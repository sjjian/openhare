// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_metadata_tree.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionMetadataServicesHash() =>
    r'201014dc7f2f6159b06c50b32777efda15843a8c';

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

abstract class _$SessionMetadataServices
    extends BuildlessNotifier<SessionMetadataTreeModel?> {
  late final SessionId sessionId;

  SessionMetadataTreeModel? build(
    SessionId sessionId,
  );
}

/// See also [SessionMetadataServices].
@ProviderFor(SessionMetadataServices)
const sessionMetadataServicesProvider = SessionMetadataServicesFamily();

/// See also [SessionMetadataServices].
class SessionMetadataServicesFamily extends Family<SessionMetadataTreeModel?> {
  /// See also [SessionMetadataServices].
  const SessionMetadataServicesFamily();

  /// See also [SessionMetadataServices].
  SessionMetadataServicesProvider call(
    SessionId sessionId,
  ) {
    return SessionMetadataServicesProvider(
      sessionId,
    );
  }

  @override
  SessionMetadataServicesProvider getProviderOverride(
    covariant SessionMetadataServicesProvider provider,
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
  String? get name => r'sessionMetadataServicesProvider';
}

/// See also [SessionMetadataServices].
class SessionMetadataServicesProvider extends NotifierProviderImpl<
    SessionMetadataServices, SessionMetadataTreeModel?> {
  /// See also [SessionMetadataServices].
  SessionMetadataServicesProvider(
    SessionId sessionId,
  ) : this._internal(
          () => SessionMetadataServices()..sessionId = sessionId,
          from: sessionMetadataServicesProvider,
          name: r'sessionMetadataServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionMetadataServicesHash,
          dependencies: SessionMetadataServicesFamily._dependencies,
          allTransitiveDependencies:
              SessionMetadataServicesFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionMetadataServicesProvider._internal(
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
  SessionMetadataTreeModel? runNotifierBuild(
    covariant SessionMetadataServices notifier,
  ) {
    return notifier.build(
      sessionId,
    );
  }

  @override
  Override overrideWith(SessionMetadataServices Function() create) {
    return ProviderOverride(
      origin: this,
      override: SessionMetadataServicesProvider._internal(
        () => create()..sessionId = sessionId,
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
  NotifierProviderElement<SessionMetadataServices, SessionMetadataTreeModel?>
      createElement() {
    return _SessionMetadataServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionMetadataServicesProvider &&
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
mixin SessionMetadataServicesRef
    on NotifierProviderRef<SessionMetadataTreeModel?> {
  /// The parameter `sessionId` of this provider.
  SessionId get sessionId;
}

class _SessionMetadataServicesProviderElement extends NotifierProviderElement<
    SessionMetadataServices,
    SessionMetadataTreeModel?> with SessionMetadataServicesRef {
  _SessionMetadataServicesProviderElement(super.provider);

  @override
  SessionId get sessionId =>
      (origin as SessionMetadataServicesProvider).sessionId;
}

String _$sessionMetadataNotifierHash() =>
    r'12b3e508d687def19f7b5a0789c816312663206b';

/// See also [SessionMetadataNotifier].
@ProviderFor(SessionMetadataNotifier)
final sessionMetadataNotifierProvider = NotifierProvider<
    SessionMetadataNotifier, SessionMetadataTreeModel?>.internal(
  SessionMetadataNotifier.new,
  name: r'sessionMetadataNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionMetadataNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionMetadataNotifier = Notifier<SessionMetadataTreeModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
