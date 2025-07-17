// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(settingsRepo)
const settingsRepoProvider = SettingsRepoProvider._();

final class SettingsRepoProvider
    extends $FunctionalProvider<SettingsRepo, SettingsRepo, SettingsRepo>
    with $Provider<SettingsRepo> {
  const SettingsRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingsRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingsRepoHash();

  @$internal
  @override
  $ProviderElement<SettingsRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsRepo create(Ref ref) {
    return settingsRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepo>(value),
    );
  }
}

String _$settingsRepoHash() => r'f49caaf5239aee4643cb4377d2aa31952e3a6039';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
