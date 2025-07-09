// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instances.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(InstancesServices)
const instancesServicesProvider = InstancesServicesProvider._();

final class InstancesServicesProvider
    extends $NotifierProvider<InstancesServices, int> {
  const InstancesServicesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'instancesServicesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$instancesServicesHash();

  @$internal
  @override
  InstancesServices create() => InstancesServices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$instancesServicesHash() => r'eb17812f0255c23be92ff64ef5e10222d4ffdd38';

abstract class _$InstancesServices extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
