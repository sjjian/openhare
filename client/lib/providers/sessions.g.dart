// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionTabProviderHash() =>
    r'a0bea35a0ded25838b92c8d47e945ac7e106ad6e';

/// See also [SessionTabProvider].
@ProviderFor(SessionTabProvider)
final sessionTabProviderProvider = AutoDisposeNotifierProvider<
    SessionTabProvider, ReorderSelectedList<BaseSession>>.internal(
  SessionTabProvider.new,
  name: r'sessionTabProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionTabProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionTabProvider
    = AutoDisposeNotifier<ReorderSelectedList<BaseSession>>;
String _$sessionConnControllerHash() =>
    r'11d8bb1e04b702e7c635d4df6f519c91fcc88ad4';

/// See also [SessionConnController].
@ProviderFor(SessionConnController)
final sessionConnControllerProvider =
    AutoDisposeNotifierProvider<SessionConnController, SessionConn>.internal(
  SessionConnController.new,
  name: r'sessionConnControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionConnControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionConnController = AutoDisposeNotifier<SessionConn>;
String _$sessionControllerHash() => r'c5997d36b8c860bb200beb43bbbbaee7322bc2e8';

/// See also [SessionController].
@ProviderFor(SessionController)
final sessionControllerProvider =
    AutoDisposeNotifierProvider<SessionController, CurrentSession>.internal(
  SessionController.new,
  name: r'sessionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionController = AutoDisposeNotifier<CurrentSession>;
String _$sessionDrawerControllerHash() =>
    r'032e05fb445d1d489805a2f5b3a65d0f274cb863';

/// See also [SessionDrawerController].
@ProviderFor(SessionDrawerController)
final sessionDrawerControllerProvider =
    NotifierProvider<SessionDrawerController, CurrentSessionDrawer>.internal(
  SessionDrawerController.new,
  name: r'sessionDrawerControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionDrawerControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionDrawerController = Notifier<CurrentSessionDrawer>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
