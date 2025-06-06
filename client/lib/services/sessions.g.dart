// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionsServicesHash() => r'0e2e8bce41c18123fb374ad0528ee2a6c2a941ca';

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
String _$selectedSessionIdServicesHash() =>
    r'bee8f6579f3e736d951b74f593c29c2cbda842ff';

/// See also [SelectedSessionIdServices].
@ProviderFor(SelectedSessionIdServices)
final selectedSessionIdServicesProvider =
    NotifierProvider<SelectedSessionIdServices, SessionModel?>.internal(
  SelectedSessionIdServices.new,
  name: r'selectedSessionIdServicesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionIdServicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionIdServices = Notifier<SessionModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
