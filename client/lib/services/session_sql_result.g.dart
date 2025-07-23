// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sql_result.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sQLResultServicesHash() => r'5bc4ac2bf3bcbbb105644b847bdf208e85c3d782';

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

abstract class _$SQLResultServices
    extends BuildlessAutoDisposeNotifier<SQLResultModel> {
  late final ResultId resultId;

  SQLResultModel build(
    ResultId resultId,
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
    ResultId resultId,
  ) {
    return SQLResultServicesProvider(
      resultId,
    );
  }

  @override
  SQLResultServicesProvider getProviderOverride(
    covariant SQLResultServicesProvider provider,
  ) {
    return call(
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
    extends AutoDisposeNotifierProviderImpl<SQLResultServices, SQLResultModel> {
  /// See also [SQLResultServices].
  SQLResultServicesProvider(
    ResultId resultId,
  ) : this._internal(
          () => SQLResultServices()..resultId = resultId,
          from: sQLResultServicesProvider,
          name: r'sQLResultServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sQLResultServicesHash,
          dependencies: SQLResultServicesFamily._dependencies,
          allTransitiveDependencies:
              SQLResultServicesFamily._allTransitiveDependencies,
          resultId: resultId,
        );

  SQLResultServicesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.resultId,
  }) : super.internal();

  final ResultId resultId;

  @override
  SQLResultModel runNotifierBuild(
    covariant SQLResultServices notifier,
  ) {
    return notifier.build(
      resultId,
    );
  }

  @override
  Override overrideWith(SQLResultServices Function() create) {
    return ProviderOverride(
      origin: this,
      override: SQLResultServicesProvider._internal(
        () => create()..resultId = resultId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        resultId: resultId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SQLResultServices, SQLResultModel>
      createElement() {
    return _SQLResultServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SQLResultServicesProvider && other.resultId == resultId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, resultId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SQLResultServicesRef on AutoDisposeNotifierProviderRef<SQLResultModel> {
  /// The parameter `resultId` of this provider.
  ResultId get resultId;
}

class _SQLResultServicesProviderElement
    extends AutoDisposeNotifierProviderElement<SQLResultServices,
        SQLResultModel> with SQLResultServicesRef {
  _SQLResultServicesProviderElement(super.provider);

  @override
  ResultId get resultId => (origin as SQLResultServicesProvider).resultId;
}

String _$sQLResultsServicesHash() =>
    r'5dbe293f44efc4b92f4cfc03f4f7414db0e8e1f2';

abstract class _$SQLResultsServices
    extends BuildlessAutoDisposeNotifier<SQLResultListModel> {
  late final SessionId sessionId;

  SQLResultListModel build(
    SessionId sessionId,
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
    SessionId sessionId,
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
class SQLResultsServicesProvider extends AutoDisposeNotifierProviderImpl<
    SQLResultsServices, SQLResultListModel> {
  /// See also [SQLResultsServices].
  SQLResultsServicesProvider(
    SessionId sessionId,
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

  final SessionId sessionId;

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
  AutoDisposeNotifierProviderElement<SQLResultsServices, SQLResultListModel>
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
mixin SQLResultsServicesRef
    on AutoDisposeNotifierProviderRef<SQLResultListModel> {
  /// The parameter `sessionId` of this provider.
  SessionId get sessionId;
}

class _SQLResultsServicesProviderElement
    extends AutoDisposeNotifierProviderElement<SQLResultsServices,
        SQLResultListModel> with SQLResultsServicesRef {
  _SQLResultsServicesProviderElement(super.provider);

  @override
  SessionId get sessionId => (origin as SQLResultsServicesProvider).sessionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
