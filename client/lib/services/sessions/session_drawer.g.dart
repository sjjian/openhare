// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_drawer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionDrawerServicesHash() =>
    r'58338e9d1e863dbe2cc2b3daddd852ef108ed707';

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

abstract class _$SessionDrawerServices
    extends BuildlessNotifier<SessionDrawerModel> {
  late final SessionId sessionId;

  SessionDrawerModel build(
    SessionId sessionId,
  );
}

/// See also [SessionDrawerServices].
@ProviderFor(SessionDrawerServices)
const sessionDrawerServicesProvider = SessionDrawerServicesFamily();

/// See also [SessionDrawerServices].
class SessionDrawerServicesFamily extends Family<SessionDrawerModel> {
  /// See also [SessionDrawerServices].
  const SessionDrawerServicesFamily();

  /// See also [SessionDrawerServices].
  SessionDrawerServicesProvider call(
    SessionId sessionId,
  ) {
    return SessionDrawerServicesProvider(
      sessionId,
    );
  }

  @override
  SessionDrawerServicesProvider getProviderOverride(
    covariant SessionDrawerServicesProvider provider,
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
  String? get name => r'sessionDrawerServicesProvider';
}

/// See also [SessionDrawerServices].
class SessionDrawerServicesProvider
    extends NotifierProviderImpl<SessionDrawerServices, SessionDrawerModel> {
  /// See also [SessionDrawerServices].
  SessionDrawerServicesProvider(
    SessionId sessionId,
  ) : this._internal(
          () => SessionDrawerServices()..sessionId = sessionId,
          from: sessionDrawerServicesProvider,
          name: r'sessionDrawerServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionDrawerServicesHash,
          dependencies: SessionDrawerServicesFamily._dependencies,
          allTransitiveDependencies:
              SessionDrawerServicesFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionDrawerServicesProvider._internal(
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
  SessionDrawerModel runNotifierBuild(
    covariant SessionDrawerServices notifier,
  ) {
    return notifier.build(
      sessionId,
    );
  }

  @override
  Override overrideWith(SessionDrawerServices Function() create) {
    return ProviderOverride(
      origin: this,
      override: SessionDrawerServicesProvider._internal(
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
  NotifierProviderElement<SessionDrawerServices, SessionDrawerModel>
      createElement() {
    return _SessionDrawerServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionDrawerServicesProvider &&
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
mixin SessionDrawerServicesRef on NotifierProviderRef<SessionDrawerModel> {
  /// The parameter `sessionId` of this provider.
  SessionId get sessionId;
}

class _SessionDrawerServicesProviderElement
    extends NotifierProviderElement<SessionDrawerServices, SessionDrawerModel>
    with SessionDrawerServicesRef {
  _SessionDrawerServicesProviderElement(super.provider);

  @override
  SessionId get sessionId =>
      (origin as SessionDrawerServicesProvider).sessionId;
}

String _$sessionDrawerNotifierHash() =>
    r'3b5e7c3efd8ddba2c9136dc89b2a5a2d6d50a58b';

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
