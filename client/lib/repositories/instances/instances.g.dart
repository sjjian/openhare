// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instances.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(instanceRepo)
const instanceRepoProvider = InstanceRepoProvider._();

final class InstanceRepoProvider
    extends $FunctionalProvider<InstanceRepo, InstanceRepo, InstanceRepo>
    with $Provider<InstanceRepo> {
  const InstanceRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'instanceRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$instanceRepoHash();

  @$internal
  @override
  $ProviderElement<InstanceRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InstanceRepo create(Ref ref) {
    return instanceRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstanceRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstanceRepo>(value),
    );
  }
}

String _$instanceRepoHash() => r'e34eb7dc6f7ef4eda56ab23e4b330d875ac804de';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
