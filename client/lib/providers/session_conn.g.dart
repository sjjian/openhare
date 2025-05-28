// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_conn.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionConnControllerHash() =>
    r'7801c5a2148c19e6a95b08f2da8b7c82cfbbf603';

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

abstract class _$SessionConnController
    extends BuildlessNotifier<SessionConnModel> {
  late final int sessionId;

  SessionConnModel build(
    int sessionId,
  );
}

/// See also [SessionConnController].
@ProviderFor(SessionConnController)
const sessionConnControllerProvider = SessionConnControllerFamily();

/// See also [SessionConnController].
class SessionConnControllerFamily extends Family<SessionConnModel> {
  /// See also [SessionConnController].
  const SessionConnControllerFamily();

  /// See also [SessionConnController].
  SessionConnControllerProvider call(
    int sessionId,
  ) {
    return SessionConnControllerProvider(
      sessionId,
    );
  }

  @override
  SessionConnControllerProvider getProviderOverride(
    covariant SessionConnControllerProvider provider,
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
  String? get name => r'sessionConnControllerProvider';
}

/// See also [SessionConnController].
class SessionConnControllerProvider
    extends NotifierProviderImpl<SessionConnController, SessionConnModel> {
  /// See also [SessionConnController].
  SessionConnControllerProvider(
    int sessionId,
  ) : this._internal(
          () => SessionConnController()..sessionId = sessionId,
          from: sessionConnControllerProvider,
          name: r'sessionConnControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionConnControllerHash,
          dependencies: SessionConnControllerFamily._dependencies,
          allTransitiveDependencies:
              SessionConnControllerFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionConnControllerProvider._internal(
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
    covariant SessionConnController notifier,
  ) {
    return notifier.build(
      sessionId,
    );
  }

  @override
  Override overrideWith(SessionConnController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SessionConnControllerProvider._internal(
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
  NotifierProviderElement<SessionConnController, SessionConnModel>
      createElement() {
    return _SessionConnControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionConnControllerProvider &&
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
mixin SessionConnControllerRef on NotifierProviderRef<SessionConnModel> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionConnControllerProviderElement
    extends NotifierProviderElement<SessionConnController, SessionConnModel>
    with SessionConnControllerRef {
  _SessionConnControllerProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionConnControllerProvider).sessionId;
}

String _$selectedSessionConnControllerHash() =>
    r'a22e0176f9f1baa3cf0f91c50192dcee0d58beb5';

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
