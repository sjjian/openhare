// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SelectedSessionStatusNotifier)
const selectedSessionStatusNotifierProvider =
    SelectedSessionStatusNotifierProvider._();

final class SelectedSessionStatusNotifierProvider extends $NotifierProvider<
    SelectedSessionStatusNotifier, SessionStatusModel?> {
  const SelectedSessionStatusNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedSessionStatusNotifierProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedSessionStatusNotifierHash();

  @$internal
  @override
  SelectedSessionStatusNotifier create() => SelectedSessionStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionStatusModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionStatusModel?>(value),
    );
  }
}

String _$selectedSessionStatusNotifierHash() =>
    r'8184048987ad66051cf7ecc6e79af499240c132c';

abstract class _$SelectedSessionStatusNotifier
    extends $Notifier<SessionStatusModel?> {
  SessionStatusModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SessionStatusModel?, SessionStatusModel?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionStatusModel?, SessionStatusModel?>,
        SessionStatusModel?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
