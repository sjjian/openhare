// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SessionsServices)
const sessionsServicesProvider = SessionsServicesProvider._();

final class SessionsServicesProvider
    extends $NotifierProvider<SessionsServices, SessionListModel> {
  const SessionsServicesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionsServicesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionsServicesHash();

  @$internal
  @override
  SessionsServices create() => SessionsServices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionListModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionListModel>(value),
    );
  }
}

String _$sessionsServicesHash() => r'6c5544005a6ea7c816bfdf46798446ac87607c8b';

abstract class _$SessionsServices extends $Notifier<SessionListModel> {
  SessionListModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SessionListModel, SessionListModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionListModel, SessionListModel>,
        SessionListModel,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelectedSessionIdServices)
const selectedSessionIdServicesProvider = SelectedSessionIdServicesProvider._();

final class SelectedSessionIdServicesProvider
    extends $NotifierProvider<SelectedSessionIdServices, SessionModel?> {
  const SelectedSessionIdServicesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedSessionIdServicesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedSessionIdServicesHash();

  @$internal
  @override
  SelectedSessionIdServices create() => SelectedSessionIdServices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionModel?>(value),
    );
  }
}

String _$selectedSessionIdServicesHash() =>
    r'10b45714e42cff1acac0702a0f305baf42aed5ad';

abstract class _$SelectedSessionIdServices extends $Notifier<SessionModel?> {
  SessionModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SessionModel?, SessionModel?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionModel?, SessionModel?>,
        SessionModel?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
