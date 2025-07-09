// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_tabs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SessionsTabNotifier)
const sessionsTabNotifierProvider = SessionsTabNotifierProvider._();

final class SessionsTabNotifierProvider
    extends $NotifierProvider<SessionsTabNotifier, SessionListModel> {
  const SessionsTabNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionsTabNotifierProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionsTabNotifierHash();

  @$internal
  @override
  SessionsTabNotifier create() => SessionsTabNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionListModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionListModel>(value),
    );
  }
}

String _$sessionsTabNotifierHash() =>
    r'd6bf2592d6a32b61fcf0f0b10a87f20b6b16c93d';

abstract class _$SessionsTabNotifier extends $Notifier<SessionListModel> {
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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
