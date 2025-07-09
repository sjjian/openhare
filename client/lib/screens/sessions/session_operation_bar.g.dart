// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_operation_bar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SessionOpBarNotifier)
const sessionOpBarNotifierProvider = SessionOpBarNotifierProvider._();

final class SessionOpBarNotifierProvider
    extends $NotifierProvider<SessionOpBarNotifier, SessionOpBarModel?> {
  const SessionOpBarNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionOpBarNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionOpBarNotifierHash();

  @$internal
  @override
  SessionOpBarNotifier create() => SessionOpBarNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionOpBarModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionOpBarModel?>(value),
    );
  }
}

String _$sessionOpBarNotifierHash() =>
    r'363fbd9baf4e404ada3aeeb5fe1b5c5b210c4af5';

abstract class _$SessionOpBarNotifier extends $Notifier<SessionOpBarModel?> {
  SessionOpBarModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SessionOpBarModel?, SessionOpBarModel?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionOpBarModel?, SessionOpBarModel?>,
        SessionOpBarModel?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
