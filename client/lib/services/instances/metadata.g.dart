// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(InstanceMetadataServices)
const instanceMetadataServicesProvider = InstanceMetadataServicesFamily._();

final class InstanceMetadataServicesProvider
    extends $NotifierProvider<InstanceMetadataServices, InstanceMetadataModel> {
  const InstanceMetadataServicesProvider._(
      {required InstanceMetadataServicesFamily super.from,
      required InstanceId super.argument})
      : super(
          retry: null,
          name: r'instanceMetadataServicesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$instanceMetadataServicesHash();

  @override
  String toString() {
    return r'instanceMetadataServicesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  InstanceMetadataServices create() => InstanceMetadataServices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstanceMetadataModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstanceMetadataModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InstanceMetadataServicesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$instanceMetadataServicesHash() =>
    r'795b9174e2f236e08ff34466eaf2ad6beaf3b7ba';

final class InstanceMetadataServicesFamily extends $Family
    with
        $ClassFamilyOverride<InstanceMetadataServices, InstanceMetadataModel,
            InstanceMetadataModel, InstanceMetadataModel, InstanceId> {
  const InstanceMetadataServicesFamily._()
      : super(
          retry: null,
          name: r'instanceMetadataServicesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  InstanceMetadataServicesProvider call(
    InstanceId instanceId,
  ) =>
      InstanceMetadataServicesProvider._(argument: instanceId, from: this);

  @override
  String toString() => r'instanceMetadataServicesProvider';
}

abstract class _$InstanceMetadataServices
    extends $Notifier<InstanceMetadataModel> {
  late final _$args = ref.$arg as InstanceId;
  InstanceId get instanceId => _$args;

  InstanceMetadataModel build(
    InstanceId instanceId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<InstanceMetadataModel, InstanceMetadataModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<InstanceMetadataModel, InstanceMetadataModel>,
        InstanceMetadataModel,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
