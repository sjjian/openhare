// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_drawer_metadata.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SessionMetadataNotifier)
const sessionMetadataNotifierProvider = SessionMetadataNotifierProvider._();

final class SessionMetadataNotifierProvider
    extends $NotifierProvider<SessionMetadataNotifier, InstanceMetadataModel?> {
  const SessionMetadataNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionMetadataNotifierProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionMetadataNotifierHash();

  @$internal
  @override
  SessionMetadataNotifier create() => SessionMetadataNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstanceMetadataModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstanceMetadataModel?>(value),
    );
  }
}

String _$sessionMetadataNotifierHash() =>
    r'5e8bc8ba060d65672bc4cbb098d0c4942dda6358';

abstract class _$SessionMetadataNotifier
    extends $Notifier<InstanceMetadataModel?> {
  InstanceMetadataModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<InstanceMetadataModel?, InstanceMetadataModel?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<InstanceMetadataModel?, InstanceMetadataModel?>,
        InstanceMetadataModel?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
