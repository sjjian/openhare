// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_conn.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(sessionConnRepo)
const sessionConnRepoProvider = SessionConnRepoProvider._();

final class SessionConnRepoProvider extends $FunctionalProvider<SessionConnRepo,
    SessionConnRepo, SessionConnRepo> with $Provider<SessionConnRepo> {
  const SessionConnRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionConnRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionConnRepoHash();

  @$internal
  @override
  $ProviderElement<SessionConnRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionConnRepo create(Ref ref) {
    return sessionConnRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionConnRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionConnRepo>(value),
    );
  }
}

String _$sessionConnRepoHash() => r'68c4a3afd00dc5fcedf306eb8cd1efe7493454fe';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
