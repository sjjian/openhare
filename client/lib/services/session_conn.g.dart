// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_conn.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionConnsServicesHash() =>
    r'fa9b60334a050ebd445ce4fd58a9d3b8b24a62bd';

/// See also [SessionConnsServices].
@ProviderFor(SessionConnsServices)
final sessionConnsServicesProvider =
    NotifierProvider<SessionConnsServices, int>.internal(
  SessionConnsServices.new,
  name: r'sessionConnsServicesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionConnsServicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionConnsServices = Notifier<int>;
String _$sessionConnServicesHash() =>
    r'5174fbf4d170884b3bec486840c1567ee0c0d511';

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
  late final int connId;

  SessionConnModel build(
    int connId,
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
    int connId,
  ) {
    return SessionConnServicesProvider(
      connId,
    );
  }

  @override
  SessionConnServicesProvider getProviderOverride(
    covariant SessionConnServicesProvider provider,
  ) {
    return call(
      provider.connId,
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
    int connId,
  ) : this._internal(
          () => SessionConnServices()..connId = connId,
          from: sessionConnServicesProvider,
          name: r'sessionConnServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionConnServicesHash,
          dependencies: SessionConnServicesFamily._dependencies,
          allTransitiveDependencies:
              SessionConnServicesFamily._allTransitiveDependencies,
          connId: connId,
        );

  SessionConnServicesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.connId,
  }) : super.internal();

  final int connId;

  @override
  SessionConnModel runNotifierBuild(
    covariant SessionConnServices notifier,
  ) {
    return notifier.build(
      connId,
    );
  }

  @override
  Override overrideWith(SessionConnServices Function() create) {
    return ProviderOverride(
      origin: this,
      override: SessionConnServicesProvider._internal(
        () => create()..connId = connId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        connId: connId,
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
    return other is SessionConnServicesProvider && other.connId == connId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, connId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionConnServicesRef on NotifierProviderRef<SessionConnModel> {
  /// The parameter `connId` of this provider.
  int get connId;
}

class _SessionConnServicesProviderElement
    extends NotifierProviderElement<SessionConnServices, SessionConnModel>
    with SessionConnServicesRef {
  _SessionConnServicesProviderElement(super.provider);

  @override
  int get connId => (origin as SessionConnServicesProvider).connId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
