// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sql_results.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(sessionEditor)
const sessionEditorProvider = SessionEditorFamily._();

final class SessionEditorProvider extends $FunctionalProvider<
    SessionEditorModel,
    SessionEditorModel,
    SessionEditorModel> with $Provider<SessionEditorModel> {
  const SessionEditorProvider._(
      {required SessionEditorFamily super.from,
      required SessionId super.argument})
      : super(
          retry: null,
          name: r'sessionEditorProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionEditorHash();

  @override
  String toString() {
    return r'sessionEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SessionEditorModel> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionEditorModel create(Ref ref) {
    final argument = this.argument as SessionId;
    return sessionEditor(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionEditorModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionEditorModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SessionEditorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionEditorHash() => r'25523e840883285f6d1dce3a71e7c5f5cf85ae46';

final class SessionEditorFamily extends $Family
    with $FunctionalFamilyOverride<SessionEditorModel, SessionId> {
  const SessionEditorFamily._()
      : super(
          retry: null,
          name: r'sessionEditorProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  SessionEditorProvider call(
    SessionId sessionId,
  ) =>
      SessionEditorProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionEditorProvider';
}

@ProviderFor(SessionEditorController)
const sessionEditorControllerProvider = SessionEditorControllerProvider._();

final class SessionEditorControllerProvider
    extends $NotifierProvider<SessionEditorController, SessionEditorModel> {
  const SessionEditorControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionEditorControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionEditorControllerHash();

  @$internal
  @override
  SessionEditorController create() => SessionEditorController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionEditorModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionEditorModel>(value),
    );
  }
}

String _$sessionEditorControllerHash() =>
    r'e29fc0e0195205c135b9c62b26994fb9cbe60f18';

abstract class _$SessionEditorController extends $Notifier<SessionEditorModel> {
  SessionEditorModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SessionEditorModel, SessionEditorModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionEditorModel, SessionEditorModel>,
        SessionEditorModel,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelectedSQLResultTabNotifier)
const selectedSQLResultTabNotifierProvider =
    SelectedSQLResultTabNotifierProvider._();

final class SelectedSQLResultTabNotifierProvider extends $NotifierProvider<
    SelectedSQLResultTabNotifier, SQLResultListModel?> {
  const SelectedSQLResultTabNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedSQLResultTabNotifierProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedSQLResultTabNotifierHash();

  @$internal
  @override
  SelectedSQLResultTabNotifier create() => SelectedSQLResultTabNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SQLResultListModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SQLResultListModel?>(value),
    );
  }
}

String _$selectedSQLResultTabNotifierHash() =>
    r'7e11334458d840b9d80219985621a201d335f448';

abstract class _$SelectedSQLResultTabNotifier
    extends $Notifier<SQLResultListModel?> {
  SQLResultListModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SQLResultListModel?, SQLResultListModel?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SQLResultListModel?, SQLResultListModel?>,
        SQLResultListModel?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelectedSQLResultNotifier)
const selectedSQLResultNotifierProvider = SelectedSQLResultNotifierProvider._();

final class SelectedSQLResultNotifierProvider
    extends $NotifierProvider<SelectedSQLResultNotifier, SQLResultModel?> {
  const SelectedSQLResultNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedSQLResultNotifierProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedSQLResultNotifierHash();

  @$internal
  @override
  SelectedSQLResultNotifier create() => SelectedSQLResultNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SQLResultModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SQLResultModel?>(value),
    );
  }
}

String _$selectedSQLResultNotifierHash() =>
    r'9733dc390a9d5deb260ae4d7dcab550e05e493b7';

abstract class _$SelectedSQLResultNotifier extends $Notifier<SQLResultModel?> {
  SQLResultModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SQLResultModel?, SQLResultModel?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SQLResultModel?, SQLResultModel?>,
        SQLResultModel?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
