// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(sessionRepo)
const sessionRepoProvider = SessionRepoProvider._();

final class SessionRepoProvider
    extends $FunctionalProvider<SessionRepo, SessionRepo, SessionRepo>
    with $Provider<SessionRepo> {
  const SessionRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionRepoHash();

  @$internal
  @override
  $ProviderElement<SessionRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionRepo create(Ref ref) {
    return sessionRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionRepo>(value),
    );
  }
}

String _$sessionRepoHash() => r'ebbf9671f9c007f7c75ac4e4285db207833744d5';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
