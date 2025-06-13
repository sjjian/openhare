// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sql_result.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sQLResultServicesHash() => r'5a589e77c6b142e21a5e6a44b2493efe652b315c';

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

abstract class _$SQLResultServices extends BuildlessNotifier<SQLResultModel> {
  late final int sessionId;
  late final int resultId;

  SQLResultModel build(
    int sessionId,
    int resultId,
  );
}

/// See also [SQLResultServices].
@ProviderFor(SQLResultServices)
const sQLResultServicesProvider = SQLResultServicesFamily();

/// See also [SQLResultServices].
class SQLResultServicesFamily extends Family<SQLResultModel> {
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
    extends NotifierProviderImpl<SQLResultServices, SQLResultModel> {
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
  SQLResultModel runNotifierBuild(
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
  NotifierProviderElement<SQLResultServices, SQLResultModel> createElement() {
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
mixin SQLResultServicesRef on NotifierProviderRef<SQLResultModel> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;

  /// The parameter `resultId` of this provider.
  int get resultId;
}

class _SQLResultServicesProviderElement
    extends NotifierProviderElement<SQLResultServices, SQLResultModel>
    with SQLResultServicesRef {
  _SQLResultServicesProviderElement(super.provider);

  @override
  int get sessionId => (origin as SQLResultServicesProvider).sessionId;
  @override
  int get resultId => (origin as SQLResultServicesProvider).resultId;
}

String _$sQLResultsServicesHash() =>
    r'0eb67b97cfdf8c58f6632e0c51b358ce92f73fca';

abstract class _$SQLResultsServices
    extends BuildlessNotifier<SQLResultListModel> {
  late final int sessionId;

  SQLResultListModel build(
    int sessionId,
  );
}

/// See also [SQLResultsServices].
@ProviderFor(SQLResultsServices)
const sQLResultsServicesProvider = SQLResultsServicesFamily();

/// See also [SQLResultsServices].
class SQLResultsServicesFamily extends Family<SQLResultListModel> {
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
    extends NotifierProviderImpl<SQLResultsServices, SQLResultListModel> {
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
  SQLResultListModel runNotifierBuild(
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
  NotifierProviderElement<SQLResultsServices, SQLResultListModel>
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
mixin SQLResultsServicesRef on NotifierProviderRef<SQLResultListModel> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SQLResultsServicesProviderElement
    extends NotifierProviderElement<SQLResultsServices, SQLResultListModel>
    with SQLResultsServicesRef {
  _SQLResultsServicesProviderElement(super.provider);

  @override
  int get sessionId => (origin as SQLResultsServicesProvider).sessionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
