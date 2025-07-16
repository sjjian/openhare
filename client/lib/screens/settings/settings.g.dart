// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SettingNotifier)
const settingNotifierProvider = SettingNotifierProvider._();

final class SettingNotifierProvider
    extends $NotifierProvider<SettingNotifier, SettingModel> {
  const SettingNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingNotifierProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingNotifierHash();

  @$internal
  @override
  SettingNotifier create() => SettingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingModel>(value),
    );
  }
}

String _$settingNotifierHash() => r'ce3c6dd798beb52da17621f5db27fc84931eb172';

abstract class _$SettingNotifier extends $Notifier<SettingModel> {
  SettingModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SettingModel, SettingModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SettingModel, SettingModel>,
        SettingModel,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
