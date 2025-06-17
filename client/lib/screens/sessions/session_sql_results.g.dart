// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sql_results.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionEditorHash() => r'32a6237c3e8429e0d64e086c460900ca00d43227';

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

/// See also [sessionEditor].
@ProviderFor(sessionEditor)
const sessionEditorProvider = SessionEditorFamily();

/// See also [sessionEditor].
class SessionEditorFamily extends Family<SessionEditorModel> {
  /// See also [sessionEditor].
  const SessionEditorFamily();

  /// See also [sessionEditor].
  SessionEditorProvider call(
    int sessionId,
  ) {
    return SessionEditorProvider(
      sessionId,
    );
  }

  @override
  SessionEditorProvider getProviderOverride(
    covariant SessionEditorProvider provider,
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
  String? get name => r'sessionEditorProvider';
}

/// See also [sessionEditor].
class SessionEditorProvider extends Provider<SessionEditorModel> {
  /// See also [sessionEditor].
  SessionEditorProvider(
    int sessionId,
  ) : this._internal(
          (ref) => sessionEditor(
            ref as SessionEditorRef,
            sessionId,
          ),
          from: sessionEditorProvider,
          name: r'sessionEditorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionEditorHash,
          dependencies: SessionEditorFamily._dependencies,
          allTransitiveDependencies:
              SessionEditorFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionEditorProvider._internal(
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
    SessionEditorModel Function(SessionEditorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionEditorProvider._internal(
        (ref) => create(ref as SessionEditorRef),
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
  ProviderElement<SessionEditorModel> createElement() {
    return _SessionEditorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionEditorProvider && other.sessionId == sessionId;
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
mixin SessionEditorRef on ProviderRef<SessionEditorModel> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionEditorProviderElement extends ProviderElement<SessionEditorModel>
    with SessionEditorRef {
  _SessionEditorProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionEditorProvider).sessionId;
}

String _$sessionEditorControllerHash() =>
    r'92009187f5244d7707247520937d97fb78b410e4';

/// See also [SessionEditorController].
@ProviderFor(SessionEditorController)
final sessionEditorControllerProvider =
    NotifierProvider<SessionEditorController, SessionEditorModel>.internal(
  SessionEditorController.new,
  name: r'sessionEditorControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionEditorControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionEditorController = Notifier<SessionEditorModel>;
String _$selectedSQLResultTabNotifierHash() =>
    r'7e11334458d840b9d80219985621a201d335f448';

/// See also [SelectedSQLResultTabNotifier].
@ProviderFor(SelectedSQLResultTabNotifier)
final selectedSQLResultTabNotifierProvider = NotifierProvider<
    SelectedSQLResultTabNotifier, SQLResultListModel?>.internal(
  SelectedSQLResultTabNotifier.new,
  name: r'selectedSQLResultTabNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSQLResultTabNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSQLResultTabNotifier = Notifier<SQLResultListModel?>;
String _$selectedSQLResultNotifierHash() =>
    r'3a67457501d1569c8bf72a60519177f855524c15';

/// See also [SelectedSQLResultNotifier].
@ProviderFor(SelectedSQLResultNotifier)
final selectedSQLResultNotifierProvider =
    NotifierProvider<SelectedSQLResultNotifier, SQLResultModel?>.internal(
  SelectedSQLResultNotifier.new,
  name: r'selectedSQLResultNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSQLResultNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSQLResultNotifier = Notifier<SQLResultModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
