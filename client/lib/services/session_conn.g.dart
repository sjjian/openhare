// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_conn.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionConnServicesHash() =>
    r'88bb07ab1f834757f5eac0d13c7040ef36341f6e';

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

abstract class _$SessionConnServices
    extends BuildlessNotifier<SessionConnModel> {
  late final int sessionId;

  SessionConnModel build(
    int sessionId,
  );
}

/// See also [SessionConnServices].
@ProviderFor(SessionConnServices)
const sessionConnServicesProvider = SessionConnServicesFamily();

/// See also [SessionConnServices].
class SessionConnServicesFamily extends Family<SessionConnModel> {
  /// See also [SessionConnServices].
  const SessionConnServicesFamily();

  /// See also [SessionConnServices].
  SessionConnServicesProvider call(
    int sessionId,
  ) {
    return SessionConnServicesProvider(
      sessionId,
    );
  }

  @override
  SessionConnServicesProvider getProviderOverride(
    covariant SessionConnServicesProvider provider,
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
  String? get name => r'sessionConnServicesProvider';
}

/// See also [SessionConnServices].
class SessionConnServicesProvider
    extends NotifierProviderImpl<SessionConnServices, SessionConnModel> {
  /// See also [SessionConnServices].
  SessionConnServicesProvider(
    int sessionId,
  ) : this._internal(
          () => SessionConnServices()..sessionId = sessionId,
          from: sessionConnServicesProvider,
          name: r'sessionConnServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionConnServicesHash,
          dependencies: SessionConnServicesFamily._dependencies,
          allTransitiveDependencies:
              SessionConnServicesFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionConnServicesProvider._internal(
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
  SessionConnModel runNotifierBuild(
    covariant SessionConnServices notifier,
  ) {
    return notifier.build(
      sessionId,
    );
  }

  @override
  Override overrideWith(SessionConnServices Function() create) {
    return ProviderOverride(
      origin: this,
      override: SessionConnServicesProvider._internal(
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
  NotifierProviderElement<SessionConnServices, SessionConnModel>
      createElement() {
    return _SessionConnServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionConnServicesProvider && other.sessionId == sessionId;
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
mixin SessionConnServicesRef on NotifierProviderRef<SessionConnModel> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionConnServicesProviderElement
    extends NotifierProviderElement<SessionConnServices, SessionConnModel>
    with SessionConnServicesRef {
  _SessionConnServicesProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionConnServicesProvider).sessionId;
}

String _$selectedSessionConnControllerHash() =>
    r'1078863ee1ac90a2ea52c868ea34d54a2bf2d404';

/// See also [SelectedSessionConnController].
@ProviderFor(SelectedSessionConnController)
final selectedSessionConnControllerProvider =
    NotifierProvider<SelectedSessionConnController, SessionConnModel?>.internal(
  SelectedSessionConnController.new,
  name: r'selectedSessionConnControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionConnControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionConnController = Notifier<SessionConnModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
