// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sql_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SelectedSessionSQLEditorNotifier)
const selectedSessionSQLEditorNotifierProvider =
    SelectedSessionSQLEditorNotifierProvider._();

final class SelectedSessionSQLEditorNotifierProvider extends $NotifierProvider<
    SelectedSessionSQLEditorNotifier, SessionSQLEditorModel> {
  const SelectedSessionSQLEditorNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedSessionSQLEditorNotifierProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedSessionSQLEditorNotifierHash();

  @$internal
  @override
  SelectedSessionSQLEditorNotifier create() =>
      SelectedSessionSQLEditorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionSQLEditorModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionSQLEditorModel>(value),
    );
  }
}

String _$selectedSessionSQLEditorNotifierHash() =>
    r'2550b087d9f5c70b04f1d478cebaeef57965ae19';

abstract class _$SelectedSessionSQLEditorNotifier
    extends $Notifier<SessionSQLEditorModel> {
  SessionSQLEditorModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SessionSQLEditorModel, SessionSQLEditorModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionSQLEditorModel, SessionSQLEditorModel>,
        SessionSQLEditorModel,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
