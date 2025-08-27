// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionsServicesHash() => r'91f7c9def6d2d27bbd4796a84eb7d330e9825639';

/// See also [SessionsServices].
@ProviderFor(SessionsServices)
final sessionsServicesProvider =
    NotifierProvider<SessionsServices, SessionListModel>.internal(
  SessionsServices.new,
  name: r'sessionsServicesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionsServicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionsServices = Notifier<SessionListModel>;
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

String _$sessionDrawerServicesHash() =>
    r'58338e9d1e863dbe2cc2b3daddd852ef108ed707';

abstract class _$SessionDrawerServices
    extends BuildlessNotifier<SessionDrawerModel> {
  late final SessionId sessionId;

  SessionDrawerModel build(
    SessionId sessionId,
  );
}

/// See also [SessionDrawerServices].
@ProviderFor(SessionDrawerServices)
const sessionDrawerServicesProvider = SessionDrawerServicesFamily();

/// See also [SessionDrawerServices].
class SessionDrawerServicesFamily extends Family<SessionDrawerModel> {
  /// See also [SessionDrawerServices].
  const SessionDrawerServicesFamily();

  /// See also [SessionDrawerServices].
  SessionDrawerServicesProvider call(
    SessionId sessionId,
  ) {
    return SessionDrawerServicesProvider(
      sessionId,
    );
  }

  @override
  SessionDrawerServicesProvider getProviderOverride(
    covariant SessionDrawerServicesProvider provider,
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
  String? get name => r'sessionDrawerServicesProvider';
}

/// See also [SessionDrawerServices].
class SessionDrawerServicesProvider
    extends NotifierProviderImpl<SessionDrawerServices, SessionDrawerModel> {
  /// See also [SessionDrawerServices].
  SessionDrawerServicesProvider(
    SessionId sessionId,
  ) : this._internal(
          () => SessionDrawerServices()..sessionId = sessionId,
          from: sessionDrawerServicesProvider,
          name: r'sessionDrawerServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionDrawerServicesHash,
          dependencies: SessionDrawerServicesFamily._dependencies,
          allTransitiveDependencies:
              SessionDrawerServicesFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionDrawerServicesProvider._internal(
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
  SessionDrawerModel runNotifierBuild(
    covariant SessionDrawerServices notifier,
  ) {
    return notifier.build(
      sessionId,
    );
  }

  @override
  Override overrideWith(SessionDrawerServices Function() create) {
    return ProviderOverride(
      origin: this,
      override: SessionDrawerServicesProvider._internal(
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
  NotifierProviderElement<SessionDrawerServices, SessionDrawerModel>
      createElement() {
    return _SessionDrawerServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionDrawerServicesProvider &&
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
mixin SessionDrawerServicesRef on NotifierProviderRef<SessionDrawerModel> {
  /// The parameter `sessionId` of this provider.
  SessionId get sessionId;
}

class _SessionDrawerServicesProviderElement
    extends NotifierProviderElement<SessionDrawerServices, SessionDrawerModel>
    with SessionDrawerServicesRef {
  _SessionDrawerServicesProviderElement(super.provider);

  @override
  SessionId get sessionId =>
      (origin as SessionDrawerServicesProvider).sessionId;
}

String _$sessionsNotifierHash() => r'212cae0abe875e854818233fea3f558b4f4937e1';

/// See also [SessionsNotifier].
@ProviderFor(SessionsNotifier)
final sessionsNotifierProvider =
    NotifierProvider<SessionsNotifier, SessionDetailListModel>.internal(
  SessionsNotifier.new,
  name: r'sessionsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionsNotifier = Notifier<SessionDetailListModel>;
String _$selectedSessionNotifierHash() =>
    r'0c574b88274a3e3398eb45a4578f0cfd8a937a7a';

/// See also [SelectedSessionNotifier].
@ProviderFor(SelectedSessionNotifier)
final selectedSessionNotifierProvider =
    NotifierProvider<SelectedSessionNotifier, SessionDetailModel?>.internal(
  SelectedSessionNotifier.new,
  name: r'selectedSessionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionNotifier = Notifier<SessionDetailModel?>;
String _$sessionDrawerNotifierHash() =>
    r'7b54f771fba9160ed2869cb44557b9f4e5f7beb5';

/// See also [SessionDrawerNotifier].
@ProviderFor(SessionDrawerNotifier)
final sessionDrawerNotifierProvider =
    NotifierProvider<SessionDrawerNotifier, SessionDrawerModel>.internal(
  SessionDrawerNotifier.new,
  name: r'sessionDrawerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionDrawerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionDrawerNotifier = Notifier<SessionDrawerModel>;
String _$sessionMetadataNotifierHash() =>
    r'6f5a3f76177ed4185619767efcb65c063851dd23';

/// See also [SessionMetadataNotifier].
@ProviderFor(SessionMetadataNotifier)
final sessionMetadataNotifierProvider =
    NotifierProvider<SessionMetadataNotifier, InstanceMetadataModel?>.internal(
  SessionMetadataNotifier.new,
  name: r'sessionMetadataNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionMetadataNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionMetadataNotifier = Notifier<InstanceMetadataModel?>;
String _$sessionOpBarNotifierHash() =>
    r'dbb26e7ddc0617ce4dda534b460c1e9686eded9b';

/// See also [SessionOpBarNotifier].
@ProviderFor(SessionOpBarNotifier)
final sessionOpBarNotifierProvider = AutoDisposeNotifierProvider<
    SessionOpBarNotifier, SessionOpBarModel?>.internal(
  SessionOpBarNotifier.new,
  name: r'sessionOpBarNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionOpBarNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionOpBarNotifier = AutoDisposeNotifier<SessionOpBarModel?>;
String _$selectedSessionSQLEditorNotifierHash() =>
    r'2e8fe32b94e3018aa00d5d023834e003e612c3b5';

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
    r'66c05081ee89f9d4bdcde6758fa0560c2bc8a875';

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
String _$selectedSQLResultTabNotifierHash() =>
    r'b704a8604cf1b91e02b547c4708d91f4583d961e';

/// See also [SelectedSQLResultTabNotifier].
@ProviderFor(SelectedSQLResultTabNotifier)
final selectedSQLResultTabNotifierProvider = NotifierProvider<
    SelectedSQLResultTabNotifier, SessionSQLResultsModel?>.internal(
  SelectedSQLResultTabNotifier.new,
  name: r'selectedSQLResultTabNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSQLResultTabNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSQLResultTabNotifier = Notifier<SessionSQLResultsModel?>;
String _$selectedSQLResultNotifierHash() =>
    r'711988cfda75a87cad5dc61d7d7946149c2efe29';

/// See also [SelectedSQLResultNotifier].
@ProviderFor(SelectedSQLResultNotifier)
final selectedSQLResultNotifierProvider =
    NotifierProvider<SelectedSQLResultNotifier, SQLResultDetailModel?>.internal(
  SelectedSQLResultNotifier.new,
  name: r'selectedSQLResultNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSQLResultNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSQLResultNotifier = Notifier<SQLResultDetailModel?>;
String _$selectedSessionStatusNotifierHash() =>
    r'9dcd0ea6b92a40cf73d34ce3dd68753cbfb83b36';

/// See also [SelectedSessionStatusNotifier].
@ProviderFor(SelectedSessionStatusNotifier)
final selectedSessionStatusNotifierProvider = NotifierProvider<
    SelectedSessionStatusNotifier, SessionStatusModel?>.internal(
  SelectedSessionStatusNotifier.new,
  name: r'selectedSessionStatusNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionStatusNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionStatusNotifier = Notifier<SessionStatusModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
