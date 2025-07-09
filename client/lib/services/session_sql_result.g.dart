// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sql_result.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SQLResultServices)
const sQLResultServicesProvider = SQLResultServicesFamily._();

final class SQLResultServicesProvider
    extends $NotifierProvider<SQLResultServices, SQLResultModel> {
  const SQLResultServicesProvider._(
      {required SQLResultServicesFamily super.from,
      required ResultId super.argument})
      : super(
          retry: null,
          name: r'sQLResultServicesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sQLResultServicesHash();

  @override
  String toString() {
    return r'sQLResultServicesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SQLResultServices create() => SQLResultServices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SQLResultModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SQLResultModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SQLResultServicesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sQLResultServicesHash() => r'5bc4ac2bf3bcbbb105644b847bdf208e85c3d782';

final class SQLResultServicesFamily extends $Family
    with
        $ClassFamilyOverride<SQLResultServices, SQLResultModel, SQLResultModel,
            SQLResultModel, ResultId> {
  const SQLResultServicesFamily._()
      : super(
          retry: null,
          name: r'sQLResultServicesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  SQLResultServicesProvider call(
    ResultId resultId,
  ) =>
      SQLResultServicesProvider._(argument: resultId, from: this);

  @override
  String toString() => r'sQLResultServicesProvider';
}

abstract class _$SQLResultServices extends $Notifier<SQLResultModel> {
  late final _$args = ref.$arg as ResultId;
  ResultId get resultId => _$args;

  SQLResultModel build(
    ResultId resultId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<SQLResultModel, SQLResultModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SQLResultModel, SQLResultModel>,
        SQLResultModel,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SQLResultsServices)
const sQLResultsServicesProvider = SQLResultsServicesFamily._();

final class SQLResultsServicesProvider
    extends $NotifierProvider<SQLResultsServices, SQLResultListModel> {
  const SQLResultsServicesProvider._(
      {required SQLResultsServicesFamily super.from,
      required SessionId super.argument})
      : super(
          retry: null,
          name: r'sQLResultsServicesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sQLResultsServicesHash();

  @override
  String toString() {
    return r'sQLResultsServicesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SQLResultsServices create() => SQLResultsServices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SQLResultListModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SQLResultListModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SQLResultsServicesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sQLResultsServicesHash() =>
    r'5dbe293f44efc4b92f4cfc03f4f7414db0e8e1f2';

final class SQLResultsServicesFamily extends $Family
    with
        $ClassFamilyOverride<SQLResultsServices, SQLResultListModel,
            SQLResultListModel, SQLResultListModel, SessionId> {
  const SQLResultsServicesFamily._()
      : super(
          retry: null,
          name: r'sQLResultsServicesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  SQLResultsServicesProvider call(
    SessionId sessionId,
  ) =>
      SQLResultsServicesProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sQLResultsServicesProvider';
}

abstract class _$SQLResultsServices extends $Notifier<SQLResultListModel> {
  late final _$args = ref.$arg as SessionId;
  SessionId get sessionId => _$args;

  SQLResultListModel build(
    SessionId sessionId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<SQLResultListModel, SQLResultListModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SQLResultListModel, SQLResultListModel>,
        SQLResultListModel,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
