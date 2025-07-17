// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_conn.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SessionConnsServices)
const sessionConnsServicesProvider = SessionConnsServicesProvider._();

final class SessionConnsServicesProvider
    extends $NotifierProvider<SessionConnsServices, int> {
  const SessionConnsServicesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionConnsServicesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionConnsServicesHash();

  @$internal
  @override
  SessionConnsServices create() => SessionConnsServices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sessionConnsServicesHash() =>
    r'3770fe1a1a765806d8e9e490c6af5088766d1e43';

abstract class _$SessionConnsServices extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SessionConnServices)
const sessionConnServicesProvider = SessionConnServicesFamily._();

final class SessionConnServicesProvider
    extends $NotifierProvider<SessionConnServices, SessionConnModel?> {
  const SessionConnServicesProvider._(
      {required SessionConnServicesFamily super.from,
      required ConnId super.argument})
      : super(
          retry: null,
          name: r'sessionConnServicesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionConnServicesHash();

  @override
  String toString() {
    return r'sessionConnServicesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SessionConnServices create() => SessionConnServices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionConnModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionConnModel?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SessionConnServicesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionConnServicesHash() =>
    r'db85a3420f379f25c62fee47138a497fd8e7ddab';

final class SessionConnServicesFamily extends $Family
    with
        $ClassFamilyOverride<SessionConnServices, SessionConnModel?,
            SessionConnModel?, SessionConnModel?, ConnId> {
  const SessionConnServicesFamily._()
      : super(
          retry: null,
          name: r'sessionConnServicesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  SessionConnServicesProvider call(
    ConnId connId,
  ) =>
      SessionConnServicesProvider._(argument: connId, from: this);

  @override
  String toString() => r'sessionConnServicesProvider';
}

abstract class _$SessionConnServices extends $Notifier<SessionConnModel?> {
  late final _$args = ref.$arg as ConnId;
  ConnId get connId => _$args;

  SessionConnModel? build(
    ConnId connId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<SessionConnModel?, SessionConnModel?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionConnModel?, SessionConnModel?>,
        SessionConnModel?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
