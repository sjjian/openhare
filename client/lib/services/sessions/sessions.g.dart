// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionsServicesHash() => r'328c4d822fe2b27b54da19ee98c4438462e090b1';

/// See also [SessionsServices].
@ProviderFor(SessionsServices)
final sessionsServicesProvider =
    NotifierProvider<SessionsServices, SessionListModel>.internal(
  SessionsServices.new,
  name: r'sessionsServicesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionsServicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionsServices = Notifier<SessionListModel>;
String _$selectedSessionNotifierHash() =>
    r'1a775e95895ff62781465bbecf5f107f38548fd7';

/// See also [SelectedSessionNotifier].
@ProviderFor(SelectedSessionNotifier)
final selectedSessionNotifierProvider =
    NotifierProvider<SelectedSessionNotifier, SessionModel?>.internal(
  SelectedSessionNotifier.new,
  name: r'selectedSessionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionNotifier = Notifier<SessionModel?>;
String _$sessionsDetailNotifierHash() =>
    r'0d2008c156b827fb25854f8e90636e69d5704498';

/// See also [SessionsDetailNotifier].
@ProviderFor(SessionsDetailNotifier)
final sessionsDetailNotifierProvider =
    NotifierProvider<SessionsDetailNotifier, SessionDetailListModel>.internal(
  SessionsDetailNotifier.new,
  name: r'sessionsDetailNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionsDetailNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionsDetailNotifier = Notifier<SessionDetailListModel>;
String _$selectedSessionDetailNotifierHash() =>
    r'0dcf1c781f6f004f2d672c388538823c6ae550e2';

/// See also [SelectedSessionDetailNotifier].
@ProviderFor(SelectedSessionDetailNotifier)
final selectedSessionDetailNotifierProvider = NotifierProvider<
    SelectedSessionDetailNotifier, SessionDetailModel?>.internal(
  SelectedSessionDetailNotifier.new,
  name: r'selectedSessionDetailNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionDetailNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionDetailNotifier = Notifier<SessionDetailModel?>;
String _$sessionOpBarNotifierHash() =>
    r'2a5dd08f23d5a1124ce760f7aa9c23675c610526';

/// See also [SessionOpBarNotifier].
@ProviderFor(SessionOpBarNotifier)
final sessionOpBarNotifierProvider = AutoDisposeNotifierProvider<
    SessionOpBarNotifier, SessionOpBarModel?>.internal(
  SessionOpBarNotifier.new,
  name: r'sessionOpBarNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionOpBarNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionOpBarNotifier = AutoDisposeNotifier<SessionOpBarModel?>;
String _$selectedSessionStatusNotifierHash() =>
    r'fdd375f0c151b798d7992980e461e2da08c88588';

/// See also [SelectedSessionStatusNotifier].
@ProviderFor(SelectedSessionStatusNotifier)
final selectedSessionStatusNotifierProvider = NotifierProvider<
    SelectedSessionStatusNotifier, SessionStatusModel?>.internal(
  SelectedSessionStatusNotifier.new,
  name: r'selectedSessionStatusNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionStatusNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionStatusNotifier = Notifier<SessionStatusModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
