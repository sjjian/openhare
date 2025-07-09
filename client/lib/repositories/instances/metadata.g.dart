// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(instanceMetadataRepo)
const instanceMetadataRepoProvider = InstanceMetadataRepoProvider._();

final class InstanceMetadataRepoProvider extends $FunctionalProvider<
    InstanceMetadataRepo,
    InstanceMetadataRepo,
    InstanceMetadataRepo> with $Provider<InstanceMetadataRepo> {
  const InstanceMetadataRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'instanceMetadataRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$instanceMetadataRepoHash();

  @$internal
  @override
  $ProviderElement<InstanceMetadataRepo> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InstanceMetadataRepo create(Ref ref) {
    return instanceMetadataRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstanceMetadataRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstanceMetadataRepo>(value),
    );
  }
}

String _$instanceMetadataRepoHash() =>
    r'3e30bcc8ff1c5d8a4b411bff69971b6f8e51670d';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
