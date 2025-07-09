// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_body.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(sessionSplitViewState)
const sessionSplitViewStateProvider = SessionSplitViewStateFamily._();

final class SessionSplitViewStateProvider extends $FunctionalProvider<
    SessionSplitViewModel,
    SessionSplitViewModel,
    SessionSplitViewModel> with $Provider<SessionSplitViewModel> {
  const SessionSplitViewStateProvider._(
      {required SessionSplitViewStateFamily super.from,
      required SessionId super.argument})
      : super(
          retry: null,
          name: r'sessionSplitViewStateProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionSplitViewStateHash();

  @override
  String toString() {
    return r'sessionSplitViewStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SessionSplitViewModel> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionSplitViewModel create(Ref ref) {
    final argument = this.argument as SessionId;
    return sessionSplitViewState(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionSplitViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionSplitViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SessionSplitViewStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionSplitViewStateHash() =>
    r'1f3e904a48dd3977623cf68c07a8fcefddd5ca05';

final class SessionSplitViewStateFamily extends $Family
    with $FunctionalFamilyOverride<SessionSplitViewModel, SessionId> {
  const SessionSplitViewStateFamily._()
      : super(
          retry: null,
          name: r'sessionSplitViewStateProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  SessionSplitViewStateProvider call(
    SessionId sessionId,
  ) =>
      SessionSplitViewStateProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionSplitViewStateProvider';
}

@ProviderFor(SessionSplitViewController)
const sessionSplitViewControllerProvider =
    SessionSplitViewControllerProvider._();

final class SessionSplitViewControllerProvider extends $NotifierProvider<
    SessionSplitViewController, SessionSplitViewModel> {
  const SessionSplitViewControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionSplitViewControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionSplitViewControllerHash();

  @$internal
  @override
  SessionSplitViewController create() => SessionSplitViewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionSplitViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionSplitViewModel>(value),
    );
  }
}

String _$sessionSplitViewControllerHash() =>
    r'7e4190af2eff74ea8c7c6729cd242fb474741ddc';

abstract class _$SessionSplitViewController
    extends $Notifier<SessionSplitViewModel> {
  SessionSplitViewModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SessionSplitViewModel, SessionSplitViewModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionSplitViewModel, SessionSplitViewModel>,
        SessionSplitViewModel,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
