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

String _$sQLResultServicesHash() => r'c8060dbcd91654b7f8742cb7570cb2e0e68673e2';

abstract class _$SQLResultServices extends BuildlessNotifier<SQLResultModel?> {
  late final int sessionId;
  late final int resultId;

  SQLResultModel? build(
    int sessionId,
    int resultId,
  );
}

/// See also [SQLResultServices].
@ProviderFor(SQLResultServices)
const sQLResultServicesProvider = SQLResultServicesFamily();

/// See also [SQLResultServices].
class SQLResultServicesFamily extends Family<SQLResultModel?> {
  /// See also [SQLResultServices].
  const SQLResultServicesFamily();

  /// See also [SQLResultServices].
  SQLResultServicesProvider call(
    int sessionId,
    int resultId,
  ) {
    return SQLResultServicesProvider(
      sessionId,
      resultId,
    );
  }

  @override
  SQLResultServicesProvider getProviderOverride(
    covariant SQLResultServicesProvider provider,
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
  String? get name => r'sQLResultServicesProvider';
}

/// See also [SQLResultServices].
class SQLResultServicesProvider
    extends NotifierProviderImpl<SQLResultServices, SQLResultModel?> {
  /// See also [SQLResultServices].
  SQLResultServicesProvider(
    int sessionId,
    int resultId,
  ) : this._internal(
          () => SQLResultServices()
            ..sessionId = sessionId
            ..resultId = resultId,
          from: sQLResultServicesProvider,
          name: r'sQLResultServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sQLResultServicesHash,
          dependencies: SQLResultServicesFamily._dependencies,
          allTransitiveDependencies:
              SQLResultServicesFamily._allTransitiveDependencies,
          sessionId: sessionId,
          resultId: resultId,
        );

  SQLResultServicesProvider._internal(
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
    covariant SQLResultServices notifier,
  ) {
    return notifier.build(
      sessionId,
      resultId,
    );
  }

  @override
  Override overrideWith(SQLResultServices Function() create) {
    return ProviderOverride(
      origin: this,
      override: SQLResultServicesProvider._internal(
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
  NotifierProviderElement<SQLResultServices, SQLResultModel?> createElement() {
    return _SQLResultServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SQLResultServicesProvider &&
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
mixin SQLResultServicesRef on NotifierProviderRef<SQLResultModel?> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;

  /// The parameter `resultId` of this provider.
  int get resultId;
}

class _SQLResultServicesProviderElement
    extends NotifierProviderElement<SQLResultServices, SQLResultModel?>
    with SQLResultServicesRef {
  _SQLResultServicesProviderElement(super.provider);

  @override
  int get sessionId => (origin as SQLResultServicesProvider).sessionId;
  @override
  int get resultId => (origin as SQLResultServicesProvider).resultId;
}

String _$sQLResultsServicesHash() =>
    r'8e2d3bc223b60198608219ac1fe99a5d78a6a348';

abstract class _$SQLResultsServices
    extends BuildlessNotifier<SQLResultsModel?> {
  late final int sessionId;

  SQLResultsModel? build(
    int sessionId,
  );
}

/// See also [SQLResultsServices].
@ProviderFor(SQLResultsServices)
const sQLResultsServicesProvider = SQLResultsServicesFamily();

/// See also [SQLResultsServices].
class SQLResultsServicesFamily extends Family<SQLResultsModel?> {
  /// See also [SQLResultsServices].
  const SQLResultsServicesFamily();

  /// See also [SQLResultsServices].
  SQLResultsServicesProvider call(
    int sessionId,
  ) {
    return SQLResultsServicesProvider(
      sessionId,
    );
  }

  @override
  SQLResultsServicesProvider getProviderOverride(
    covariant SQLResultsServicesProvider provider,
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
  String? get name => r'sQLResultsServicesProvider';
}

/// See also [SQLResultsServices].
class SQLResultsServicesProvider
    extends NotifierProviderImpl<SQLResultsServices, SQLResultsModel?> {
  /// See also [SQLResultsServices].
  SQLResultsServicesProvider(
    int sessionId,
  ) : this._internal(
          () => SQLResultsServices()..sessionId = sessionId,
          from: sQLResultsServicesProvider,
          name: r'sQLResultsServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sQLResultsServicesHash,
          dependencies: SQLResultsServicesFamily._dependencies,
          allTransitiveDependencies:
              SQLResultsServicesFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SQLResultsServicesProvider._internal(
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
    covariant SQLResultsServices notifier,
  ) {
    return notifier.build(
      sessionId,
    );
  }

  @override
  Override overrideWith(SQLResultsServices Function() create) {
    return ProviderOverride(
      origin: this,
      override: SQLResultsServicesProvider._internal(
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
  NotifierProviderElement<SQLResultsServices, SQLResultsModel?>
      createElement() {
    return _SQLResultsServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SQLResultsServicesProvider && other.sessionId == sessionId;
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
mixin SQLResultsServicesRef on NotifierProviderRef<SQLResultsModel?> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SQLResultsServicesProviderElement
    extends NotifierProviderElement<SQLResultsServices, SQLResultsModel?>
    with SQLResultsServicesRef {
  _SQLResultsServicesProviderElement(super.provider);

  @override
  int get sessionId => (origin as SQLResultsServicesProvider).sessionId;
}

String _$selectedSQLResultTabControllerHash() =>
    r'5858a25f16e85cfb3e73a6d49a77ac488243ab63';

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
String _$selectedSQLResultControllerHash() =>
    r'a509f7489ea37664627fbba98b9f5bd6c629f345';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
