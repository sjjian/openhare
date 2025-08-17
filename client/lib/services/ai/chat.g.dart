// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aIChatServiceHash() => r'878841e7749fbd3313b16e62c6e0513e65979fce';

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

abstract class _$AIChatService extends BuildlessNotifier<AIChatModel> {
  late final AIChatId id;

  AIChatModel build(
    AIChatId id,
  );
}

/// See also [AIChatService].
@ProviderFor(AIChatService)
const aIChatServiceProvider = AIChatServiceFamily();

/// See also [AIChatService].
class AIChatServiceFamily extends Family<AIChatModel> {
  /// See also [AIChatService].
  const AIChatServiceFamily();

  /// See also [AIChatService].
  AIChatServiceProvider call(
    AIChatId id,
  ) {
    return AIChatServiceProvider(
      id,
    );
  }

  @override
  AIChatServiceProvider getProviderOverride(
    covariant AIChatServiceProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'aIChatServiceProvider';
}

/// See also [AIChatService].
class AIChatServiceProvider
    extends NotifierProviderImpl<AIChatService, AIChatModel> {
  /// See also [AIChatService].
  AIChatServiceProvider(
    AIChatId id,
  ) : this._internal(
          () => AIChatService()..id = id,
          from: aIChatServiceProvider,
          name: r'aIChatServiceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$aIChatServiceHash,
          dependencies: AIChatServiceFamily._dependencies,
          allTransitiveDependencies:
              AIChatServiceFamily._allTransitiveDependencies,
          id: id,
        );

  AIChatServiceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final AIChatId id;

  @override
  AIChatModel runNotifierBuild(
    covariant AIChatService notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(AIChatService Function() create) {
    return ProviderOverride(
      origin: this,
      override: AIChatServiceProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  NotifierProviderElement<AIChatService, AIChatModel> createElement() {
    return _AIChatServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AIChatServiceProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AIChatServiceRef on NotifierProviderRef<AIChatModel> {
  /// The parameter `id` of this provider.
  AIChatId get id;
}

class _AIChatServiceProviderElement
    extends NotifierProviderElement<AIChatService, AIChatModel>
    with AIChatServiceRef {
  _AIChatServiceProviderElement(super.provider);

  @override
  AIChatId get id => (origin as AIChatServiceProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
