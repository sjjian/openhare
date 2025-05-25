// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sql_result.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentSQLResultsHash() => r'883d23be1841adca58d208fd76b6f04d178d1710';

/// See also [currentSQLResults].
@ProviderFor(currentSQLResults)
final currentSQLResultsProvider =
    Provider<ReorderSelectedList<SQLResult>>.internal(
  currentSQLResults,
  name: r'currentSQLResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentSQLResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentSQLResultsRef = ProviderRef<ReorderSelectedList<SQLResult>>;
String _$currentSQLResultHash() => r'ea6dcb2820de2d362fa6551a54833d08cc3eddf7';

/// See also [currentSQLResult].
@ProviderFor(currentSQLResult)
final currentSQLResultProvider = Provider<SQLResult?>.internal(
  currentSQLResult,
  name: r'currentSQLResultProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentSQLResultHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentSQLResultRef = ProviderRef<SQLResult?>;
String _$sQLResultControllerHash() =>
    r'09511afedc7c8884b204db7f16b73a84df41df24';

/// See also [SQLResultController].
@ProviderFor(SQLResultController)
final sQLResultControllerProvider =
    NotifierProvider<SQLResultController, SQLResult?>.internal(
  SQLResultController.new,
  name: r'sQLResultControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sQLResultControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SQLResultController = Notifier<SQLResult?>;
String _$sQLResultTabControllerHash() =>
    r'9864f67de914d2521d5462563a0e07216696f01e';

/// See also [SQLResultTabController].
@ProviderFor(SQLResultTabController)
final sQLResultTabControllerProvider = NotifierProvider<SQLResultTabController,
    ReorderSelectedList<SQLResult>>.internal(
  SQLResultTabController.new,
  name: r'sQLResultTabControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sQLResultTabControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SQLResultTabController
    = Notifier<ReorderSelectedList<SQLResult>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
