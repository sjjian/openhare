// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionsServicesHash() => r'c3fed1c100c372da1c3d0aeb2bb515f1dc41b427';

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
    r'df1a1be61e110d3eb4f103bcf8f66ed5ec26ae59';

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
