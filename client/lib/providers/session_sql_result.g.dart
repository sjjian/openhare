// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sql_result.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sqlResultsHash() => r'fb6586e2673be7fa18203f21440c86979c72a773';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [sqlResults].
@ProviderFor(sqlResults)
const sqlResultsProvider = SqlResultsFamily();

/// See also [sqlResults].
class SqlResultsFamily extends Family<SQLResultsModel?> {
  /// See also [sqlResults].
  const SqlResultsFamily();

  /// See also [sqlResults].
  SqlResultsProvider call(
    int sessionId,
  ) {
    return SqlResultsProvider(
      sessionId,
    );
  }

  @override
  SqlResultsProvider getProviderOverride(
    covariant SqlResultsProvider provider,
  ) {
    return call(
      provider.sessionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sqlResultsProvider';
}

/// See also [sqlResults].
class SqlResultsProvider extends Provider<SQLResultsModel?> {
  /// See also [sqlResults].
  SqlResultsProvider(
    int sessionId,
  ) : this._internal(
          (ref) => sqlResults(
            ref as SqlResultsRef,
            sessionId,
          ),
          from: sqlResultsProvider,
          name: r'sqlResultsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sqlResultsHash,
          dependencies: SqlResultsFamily._dependencies,
          allTransitiveDependencies:
              SqlResultsFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SqlResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final int sessionId;

  @override
  Override overrideWith(
    SQLResultsModel? Function(SqlResultsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SqlResultsProvider._internal(
        (ref) => create(ref as SqlResultsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  ProviderElement<SQLResultsModel?> createElement() {
    return _SqlResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SqlResultsProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SqlResultsRef on ProviderRef<SQLResultsModel?> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SqlResultsProviderElement extends ProviderElement<SQLResultsModel?>
    with SqlResultsRef {
  _SqlResultsProviderElement(super.provider);

  @override
  int get sessionId => (origin as SqlResultsProvider).sessionId;
}

String _$sqlResultHash() => r'cf99d3464ac9691e874bc5330ba1e17c12f8c3de';

/// See also [sqlResult].
@ProviderFor(sqlResult)
const sqlResultProvider = SqlResultFamily();

/// See also [sqlResult].
class SqlResultFamily extends Family<SQLResultModel?> {
  /// See also [sqlResult].
  const SqlResultFamily();

  /// See also [sqlResult].
  SqlResultProvider call(
    int sessionId,
    int resultId,
  ) {
    return SqlResultProvider(
      sessionId,
      resultId,
    );
  }

  @override
  SqlResultProvider getProviderOverride(
    covariant SqlResultProvider provider,
  ) {
    return call(
      provider.sessionId,
      provider.resultId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sqlResultProvider';
}

/// See also [sqlResult].
class SqlResultProvider extends Provider<SQLResultModel?> {
  /// See also [sqlResult].
  SqlResultProvider(
    int sessionId,
    int resultId,
  ) : this._internal(
          (ref) => sqlResult(
            ref as SqlResultRef,
            sessionId,
            resultId,
          ),
          from: sqlResultProvider,
          name: r'sqlResultProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sqlResultHash,
          dependencies: SqlResultFamily._dependencies,
          allTransitiveDependencies: SqlResultFamily._allTransitiveDependencies,
          sessionId: sessionId,
          resultId: resultId,
        );

  SqlResultProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
    required this.resultId,
  }) : super.internal();

  final int sessionId;
  final int resultId;

  @override
  Override overrideWith(
    SQLResultModel? Function(SqlResultRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SqlResultProvider._internal(
        (ref) => create(ref as SqlResultRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
        resultId: resultId,
      ),
    );
  }

  @override
  ProviderElement<SQLResultModel?> createElement() {
    return _SqlResultProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SqlResultProvider &&
        other.sessionId == sessionId &&
        other.resultId == resultId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);
    hash = _SystemHash.combine(hash, resultId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SqlResultRef on ProviderRef<SQLResultModel?> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;

  /// The parameter `resultId` of this provider.
  int get resultId;
}

class _SqlResultProviderElement extends ProviderElement<SQLResultModel?>
    with SqlResultRef {
  _SqlResultProviderElement(super.provider);

  @override
  int get sessionId => (origin as SqlResultProvider).sessionId;
  @override
  int get resultId => (origin as SqlResultProvider).resultId;
}

String _$sQLResultControllerHash() =>
    r'b0ebf68f846e99886fae05ea49c67ea29f45c261';

abstract class _$SQLResultController
    extends BuildlessNotifier<SQLResultModel?> {
  late final int sessionId;
  late final int resultId;

  SQLResultModel? build(
    int sessionId,
    int resultId,
  );
}

/// See also [SQLResultController].
@ProviderFor(SQLResultController)
const sQLResultControllerProvider = SQLResultControllerFamily();

/// See also [SQLResultController].
class SQLResultControllerFamily extends Family<SQLResultModel?> {
  /// See also [SQLResultController].
  const SQLResultControllerFamily();

  /// See also [SQLResultController].
  SQLResultControllerProvider call(
    int sessionId,
    int resultId,
  ) {
    return SQLResultControllerProvider(
      sessionId,
      resultId,
    );
  }

  @override
  SQLResultControllerProvider getProviderOverride(
    covariant SQLResultControllerProvider provider,
  ) {
    return call(
      provider.sessionId,
      provider.resultId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sQLResultControllerProvider';
}

/// See also [SQLResultController].
class SQLResultControllerProvider
    extends NotifierProviderImpl<SQLResultController, SQLResultModel?> {
  /// See also [SQLResultController].
  SQLResultControllerProvider(
    int sessionId,
    int resultId,
  ) : this._internal(
          () => SQLResultController()
            ..sessionId = sessionId
            ..resultId = resultId,
          from: sQLResultControllerProvider,
          name: r'sQLResultControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sQLResultControllerHash,
          dependencies: SQLResultControllerFamily._dependencies,
          allTransitiveDependencies:
              SQLResultControllerFamily._allTransitiveDependencies,
          sessionId: sessionId,
          resultId: resultId,
        );

  SQLResultControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
    required this.resultId,
  }) : super.internal();

  final int sessionId;
  final int resultId;

  @override
  SQLResultModel? runNotifierBuild(
    covariant SQLResultController notifier,
  ) {
    return notifier.build(
      sessionId,
      resultId,
    );
  }

  @override
  Override overrideWith(SQLResultController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SQLResultControllerProvider._internal(
        () => create()
          ..sessionId = sessionId
          ..resultId = resultId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
        resultId: resultId,
      ),
    );
  }

  @override
  NotifierProviderElement<SQLResultController, SQLResultModel?>
      createElement() {
    return _SQLResultControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SQLResultControllerProvider &&
        other.sessionId == sessionId &&
        other.resultId == resultId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);
    hash = _SystemHash.combine(hash, resultId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SQLResultControllerRef on NotifierProviderRef<SQLResultModel?> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;

  /// The parameter `resultId` of this provider.
  int get resultId;
}

class _SQLResultControllerProviderElement
    extends NotifierProviderElement<SQLResultController, SQLResultModel?>
    with SQLResultControllerRef {
  _SQLResultControllerProviderElement(super.provider);

  @override
  int get sessionId => (origin as SQLResultControllerProvider).sessionId;
  @override
  int get resultId => (origin as SQLResultControllerProvider).resultId;
}

String _$sQLResultTabControllerHash() =>
    r'18140d7dd565524c4964104732db2812b58620ed';

abstract class _$SQLResultTabController
    extends BuildlessNotifier<SQLResultsModel?> {
  late final int sessionId;

  SQLResultsModel? build(
    int sessionId,
  );
}

/// See also [SQLResultTabController].
@ProviderFor(SQLResultTabController)
const sQLResultTabControllerProvider = SQLResultTabControllerFamily();

/// See also [SQLResultTabController].
class SQLResultTabControllerFamily extends Family<SQLResultsModel?> {
  /// See also [SQLResultTabController].
  const SQLResultTabControllerFamily();

  /// See also [SQLResultTabController].
  SQLResultTabControllerProvider call(
    int sessionId,
  ) {
    return SQLResultTabControllerProvider(
      sessionId,
    );
  }

  @override
  SQLResultTabControllerProvider getProviderOverride(
    covariant SQLResultTabControllerProvider provider,
  ) {
    return call(
      provider.sessionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sQLResultTabControllerProvider';
}

/// See also [SQLResultTabController].
class SQLResultTabControllerProvider
    extends NotifierProviderImpl<SQLResultTabController, SQLResultsModel?> {
  /// See also [SQLResultTabController].
  SQLResultTabControllerProvider(
    int sessionId,
  ) : this._internal(
          () => SQLResultTabController()..sessionId = sessionId,
          from: sQLResultTabControllerProvider,
          name: r'sQLResultTabControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sQLResultTabControllerHash,
          dependencies: SQLResultTabControllerFamily._dependencies,
          allTransitiveDependencies:
              SQLResultTabControllerFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SQLResultTabControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final int sessionId;

  @override
  SQLResultsModel? runNotifierBuild(
    covariant SQLResultTabController notifier,
  ) {
    return notifier.build(
      sessionId,
    );
  }

  @override
  Override overrideWith(SQLResultTabController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SQLResultTabControllerProvider._internal(
        () => create()..sessionId = sessionId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  NotifierProviderElement<SQLResultTabController, SQLResultsModel?>
      createElement() {
    return _SQLResultTabControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SQLResultTabControllerProvider &&
        other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SQLResultTabControllerRef on NotifierProviderRef<SQLResultsModel?> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SQLResultTabControllerProviderElement
    extends NotifierProviderElement<SQLResultTabController, SQLResultsModel?>
    with SQLResultTabControllerRef {
  _SQLResultTabControllerProviderElement(super.provider);

  @override
  int get sessionId => (origin as SQLResultTabControllerProvider).sessionId;
}

String _$selectedSQLResultControllerHash() =>
    r'98c7b34436bc6f1655edcd547cfceddfb470af4c';

/// See also [SelectedSQLResultController].
@ProviderFor(SelectedSQLResultController)
final selectedSQLResultControllerProvider =
    NotifierProvider<SelectedSQLResultController, SQLResultModel?>.internal(
  SelectedSQLResultController.new,
  name: r'selectedSQLResultControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSQLResultControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSQLResultController = Notifier<SQLResultModel?>;
String _$selectedSQLResultTabControllerHash() =>
    r'654f1be0891d05ed9276e74de2c21e5585b97236';

/// See also [SelectedSQLResultTabController].
@ProviderFor(SelectedSQLResultTabController)
final selectedSQLResultTabControllerProvider =
    NotifierProvider<SelectedSQLResultTabController, SQLResultsModel?>.internal(
  SelectedSQLResultTabController.new,
  name: r'selectedSQLResultTabControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSQLResultTabControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSQLResultTabController = Notifier<SQLResultsModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
