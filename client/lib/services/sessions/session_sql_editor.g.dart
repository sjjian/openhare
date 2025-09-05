// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sql_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionSQLEditorServiceHash() =>
    r'1c0767cd0f6599ed0ab5b396c77228271f2f1f59';

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

abstract class _$SessionSQLEditorService
    extends BuildlessNotifier<SessionEditorModel> {
  late final SessionId sessionId;

  SessionEditorModel build(
    SessionId sessionId,
  );
}

/// See also [SessionSQLEditorService].
@ProviderFor(SessionSQLEditorService)
const sessionSQLEditorServiceProvider = SessionSQLEditorServiceFamily();

/// See also [SessionSQLEditorService].
class SessionSQLEditorServiceFamily extends Family<SessionEditorModel> {
  /// See also [SessionSQLEditorService].
  const SessionSQLEditorServiceFamily();

  /// See also [SessionSQLEditorService].
  SessionSQLEditorServiceProvider call(
    SessionId sessionId,
  ) {
    return SessionSQLEditorServiceProvider(
      sessionId,
    );
  }

  @override
  SessionSQLEditorServiceProvider getProviderOverride(
    covariant SessionSQLEditorServiceProvider provider,
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
  String? get name => r'sessionSQLEditorServiceProvider';
}

/// See also [SessionSQLEditorService].
class SessionSQLEditorServiceProvider
    extends NotifierProviderImpl<SessionSQLEditorService, SessionEditorModel> {
  /// See also [SessionSQLEditorService].
  SessionSQLEditorServiceProvider(
    SessionId sessionId,
  ) : this._internal(
          () => SessionSQLEditorService()..sessionId = sessionId,
          from: sessionSQLEditorServiceProvider,
          name: r'sessionSQLEditorServiceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionSQLEditorServiceHash,
          dependencies: SessionSQLEditorServiceFamily._dependencies,
          allTransitiveDependencies:
              SessionSQLEditorServiceFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionSQLEditorServiceProvider._internal(
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
  SessionEditorModel runNotifierBuild(
    covariant SessionSQLEditorService notifier,
  ) {
    return notifier.build(
      sessionId,
    );
  }

  @override
  Override overrideWith(SessionSQLEditorService Function() create) {
    return ProviderOverride(
      origin: this,
      override: SessionSQLEditorServiceProvider._internal(
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
  NotifierProviderElement<SessionSQLEditorService, SessionEditorModel>
      createElement() {
    return _SessionSQLEditorServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionSQLEditorServiceProvider &&
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
mixin SessionSQLEditorServiceRef on NotifierProviderRef<SessionEditorModel> {
  /// The parameter `sessionId` of this provider.
  SessionId get sessionId;
}

class _SessionSQLEditorServiceProviderElement
    extends NotifierProviderElement<SessionSQLEditorService, SessionEditorModel>
    with SessionSQLEditorServiceRef {
  _SessionSQLEditorServiceProviderElement(super.provider);

  @override
  SessionId get sessionId =>
      (origin as SessionSQLEditorServiceProvider).sessionId;
}

String _$selectedSessionSQLEditorNotifierHash() =>
    r'16c275d47303f525f1c63d110880390e1663f701';

/// See also [SelectedSessionSQLEditorNotifier].
@ProviderFor(SelectedSessionSQLEditorNotifier)
final selectedSessionSQLEditorNotifierProvider = NotifierProvider<
    SelectedSessionSQLEditorNotifier, SessionSQLEditorModel>.internal(
  SelectedSessionSQLEditorNotifier.new,
  name: r'selectedSessionSQLEditorNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionSQLEditorNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionSQLEditorNotifier = Notifier<SessionSQLEditorModel>;
String _$sessionEditorNotifierHash() =>
    r'c820c274d50eca8b98d63636195beedafb2e937a';

/// See also [SessionEditorNotifier].
@ProviderFor(SessionEditorNotifier)
final sessionEditorNotifierProvider =
    NotifierProvider<SessionEditorNotifier, SessionEditorModel>.internal(
  SessionEditorNotifier.new,
  name: r'sessionEditorNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionEditorNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionEditorNotifier = Notifier<SessionEditorModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
