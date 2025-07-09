// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sql_result.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(sqlResultsRepo)
const sqlResultsRepoProvider = SqlResultsRepoProvider._();

final class SqlResultsRepoProvider
    extends $FunctionalProvider<SQLResultRepo, SQLResultRepo, SQLResultRepo>
    with $Provider<SQLResultRepo> {
  const SqlResultsRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sqlResultsRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sqlResultsRepoHash();

  @$internal
  @override
  $ProviderElement<SQLResultRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SQLResultRepo create(Ref ref) {
    return sqlResultsRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SQLResultRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SQLResultRepo>(value),
    );
  }
}

String _$sqlResultsRepoHash() => r'9c25cb5933857678d0d543fa16d94d7489ef573e';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
