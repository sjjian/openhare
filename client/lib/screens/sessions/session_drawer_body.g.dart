// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_drawer_body.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(sessionDrawerState)
const sessionDrawerStateProvider = SessionDrawerStateFamily._();

final class SessionDrawerStateProvider extends $FunctionalProvider<
    SessionDrawerModel,
    SessionDrawerModel,
    SessionDrawerModel> with $Provider<SessionDrawerModel> {
  const SessionDrawerStateProvider._(
      {required SessionDrawerStateFamily super.from,
      required SessionId super.argument})
      : super(
          retry: null,
          name: r'sessionDrawerStateProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionDrawerStateHash();

  @override
  String toString() {
    return r'sessionDrawerStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SessionDrawerModel> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionDrawerModel create(Ref ref) {
    final argument = this.argument as SessionId;
    return sessionDrawerState(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionDrawerModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionDrawerModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SessionDrawerStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionDrawerStateHash() =>
    r'e8954f01db2960aebb5987624ffdc25084b99e3d';

final class SessionDrawerStateFamily extends $Family
    with $FunctionalFamilyOverride<SessionDrawerModel, SessionId> {
  const SessionDrawerStateFamily._()
      : super(
          retry: null,
          name: r'sessionDrawerStateProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  SessionDrawerStateProvider call(
    SessionId sessionId,
  ) =>
      SessionDrawerStateProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionDrawerStateProvider';
}

@ProviderFor(SessionDrawerController)
const sessionDrawerControllerProvider = SessionDrawerControllerProvider._();

final class SessionDrawerControllerProvider
    extends $NotifierProvider<SessionDrawerController, SessionDrawerModel> {
  const SessionDrawerControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionDrawerControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionDrawerControllerHash();

  @$internal
  @override
  SessionDrawerController create() => SessionDrawerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionDrawerModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionDrawerModel>(value),
    );
  }
}

String _$sessionDrawerControllerHash() =>
    r'01deafb1ca96e13b4d4a0bd9321ae7b6be6e5936';

abstract class _$SessionDrawerController extends $Notifier<SessionDrawerModel> {
  SessionDrawerModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SessionDrawerModel, SessionDrawerModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionDrawerModel, SessionDrawerModel>,
        SessionDrawerModel,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
