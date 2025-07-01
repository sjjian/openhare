// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$instanceMetadataServicesHash() =>
    r'095dc93cda9e5af9b57123dc5834769417f41714';

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

abstract class _$InstanceMetadataServices
    extends BuildlessNotifier<InstanceMetadataModel> {
  late final InstanceId instanceId;

  InstanceMetadataModel build(
    InstanceId instanceId,
  );
}

/// See also [InstanceMetadataServices].
@ProviderFor(InstanceMetadataServices)
const instanceMetadataServicesProvider = InstanceMetadataServicesFamily();

/// See also [InstanceMetadataServices].
class InstanceMetadataServicesFamily extends Family<InstanceMetadataModel> {
  /// See also [InstanceMetadataServices].
  const InstanceMetadataServicesFamily();

  /// See also [InstanceMetadataServices].
  InstanceMetadataServicesProvider call(
    InstanceId instanceId,
  ) {
    return InstanceMetadataServicesProvider(
      instanceId,
    );
  }

  @override
  InstanceMetadataServicesProvider getProviderOverride(
    covariant InstanceMetadataServicesProvider provider,
  ) {
    return call(
      provider.instanceId,
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
  String? get name => r'instanceMetadataServicesProvider';
}

/// See also [InstanceMetadataServices].
class InstanceMetadataServicesProvider extends NotifierProviderImpl<
    InstanceMetadataServices, InstanceMetadataModel> {
  /// See also [InstanceMetadataServices].
  InstanceMetadataServicesProvider(
    InstanceId instanceId,
  ) : this._internal(
          () => InstanceMetadataServices()..instanceId = instanceId,
          from: instanceMetadataServicesProvider,
          name: r'instanceMetadataServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$instanceMetadataServicesHash,
          dependencies: InstanceMetadataServicesFamily._dependencies,
          allTransitiveDependencies:
              InstanceMetadataServicesFamily._allTransitiveDependencies,
          instanceId: instanceId,
        );

  InstanceMetadataServicesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.instanceId,
  }) : super.internal();

  final InstanceId instanceId;

  @override
  InstanceMetadataModel runNotifierBuild(
    covariant InstanceMetadataServices notifier,
  ) {
    return notifier.build(
      instanceId,
    );
  }

  @override
  Override overrideWith(InstanceMetadataServices Function() create) {
    return ProviderOverride(
      origin: this,
      override: InstanceMetadataServicesProvider._internal(
        () => create()..instanceId = instanceId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        instanceId: instanceId,
      ),
    );
  }

  @override
  NotifierProviderElement<InstanceMetadataServices, InstanceMetadataModel>
      createElement() {
    return _InstanceMetadataServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InstanceMetadataServicesProvider &&
        other.instanceId == instanceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, instanceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InstanceMetadataServicesRef
    on NotifierProviderRef<InstanceMetadataModel> {
  /// The parameter `instanceId` of this provider.
  InstanceId get instanceId;
}

class _InstanceMetadataServicesProviderElement extends NotifierProviderElement<
    InstanceMetadataServices,
    InstanceMetadataModel> with InstanceMetadataServicesRef {
  _InstanceMetadataServicesProviderElement(super.provider);

  @override
  InstanceId get instanceId =>
      (origin as InstanceMetadataServicesProvider).instanceId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
