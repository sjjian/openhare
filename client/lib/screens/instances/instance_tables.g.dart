// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instance_tables.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(InstancesNotifier)
const instancesNotifierProvider = InstancesNotifierProvider._();

final class InstancesNotifierProvider
    extends $NotifierProvider<InstancesNotifier, PaginationInstanceListModel> {
  const InstancesNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'instancesNotifierProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$instancesNotifierHash();

  @$internal
  @override
  InstancesNotifier create() => InstancesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginationInstanceListModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginationInstanceListModel>(value),
    );
  }
}

String _$instancesNotifierHash() => r'aac152ecb963da96f9f967617e79b772ae85627d';

abstract class _$InstancesNotifier
    extends $Notifier<PaginationInstanceListModel> {
  PaginationInstanceListModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<PaginationInstanceListModel, PaginationInstanceListModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PaginationInstanceListModel, PaginationInstanceListModel>,
        PaginationInstanceListModel,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
