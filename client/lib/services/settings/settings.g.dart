// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SettingService)
const settingServiceProvider = SettingServiceProvider._();

final class SettingServiceProvider
    extends $NotifierProvider<SettingService, SettingModel> {
  const SettingServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingServiceHash();

  @$internal
  @override
  SettingService create() => SettingService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingModel>(value),
    );
  }
}

String _$settingServiceHash() => r'45bb07fa28acc4fa6187e0ce474c7833f8c5d69e';

abstract class _$SettingService extends $Notifier<SettingModel> {
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
