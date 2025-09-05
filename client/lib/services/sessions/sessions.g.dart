// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionsServicesHash() => r'328c4d822fe2b27b54da19ee98c4438462e090b1';

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

String _$selectedSessionNotifierHash() =>
    r'1a775e95895ff62781465bbecf5f107f38548fd7';

/// See also [SelectedSessionNotifier].
@ProviderFor(SelectedSessionNotifier)
final selectedSessionNotifierProvider =
    NotifierProvider<SelectedSessionNotifier, SessionModel?>.internal(
  SelectedSessionNotifier.new,
  name: r'selectedSessionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionNotifier = Notifier<SessionModel?>;
String _$sessionsDetailNotifierHash() =>
    r'0d2008c156b827fb25854f8e90636e69d5704498';

/// See also [SessionsDetailNotifier].
@ProviderFor(SessionsDetailNotifier)
final sessionsDetailNotifierProvider =
    NotifierProvider<SessionsDetailNotifier, SessionDetailListModel>.internal(
  SessionsDetailNotifier.new,
  name: r'sessionsDetailNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionsDetailNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionsDetailNotifier = Notifier<SessionDetailListModel>;
String _$selectedSessionDetailNotifierHash() =>
    r'0dcf1c781f6f004f2d672c388538823c6ae550e2';

/// See also [SelectedSessionDetailNotifier].
@ProviderFor(SelectedSessionDetailNotifier)
final selectedSessionDetailNotifierProvider = NotifierProvider<
    SelectedSessionDetailNotifier, SessionDetailModel?>.internal(
  SelectedSessionDetailNotifier.new,
  name: r'selectedSessionDetailNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionDetailNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionDetailNotifier = Notifier<SessionDetailModel?>;
String _$sessionDrawerNotifierHash() =>
    r'3b5e7c3efd8ddba2c9136dc89b2a5a2d6d50a58b';

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
String _$sessionMetadataServicesHash() =>
    r'201014dc7f2f6159b06c50b32777efda15843a8c';

abstract class _$SessionMetadataServices
    extends BuildlessNotifier<SessionMetadataTreeModel?> {
  late final SessionId sessionId;

  SessionMetadataTreeModel? build(
    SessionId sessionId,
  );
}

/// See also [SessionMetadataServices].
@ProviderFor(SessionMetadataServices)
const sessionMetadataServicesProvider = SessionMetadataServicesFamily();

/// See also [SessionMetadataServices].
class SessionMetadataServicesFamily extends Family<SessionMetadataTreeModel?> {
  /// See also [SessionMetadataServices].
  const SessionMetadataServicesFamily();

  /// See also [SessionMetadataServices].
  SessionMetadataServicesProvider call(
    SessionId sessionId,
  ) {
    return SessionMetadataServicesProvider(
      sessionId,
    );
  }

  @override
  SessionMetadataServicesProvider getProviderOverride(
    covariant SessionMetadataServicesProvider provider,
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
  String? get name => r'sessionMetadataServicesProvider';
}

/// See also [SessionMetadataServices].
class SessionMetadataServicesProvider extends NotifierProviderImpl<
    SessionMetadataServices, SessionMetadataTreeModel?> {
  /// See also [SessionMetadataServices].
  SessionMetadataServicesProvider(
    SessionId sessionId,
  ) : this._internal(
          () => SessionMetadataServices()..sessionId = sessionId,
          from: sessionMetadataServicesProvider,
          name: r'sessionMetadataServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionMetadataServicesHash,
          dependencies: SessionMetadataServicesFamily._dependencies,
          allTransitiveDependencies:
              SessionMetadataServicesFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionMetadataServicesProvider._internal(
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
  SessionMetadataTreeModel? runNotifierBuild(
    covariant SessionMetadataServices notifier,
  ) {
    return notifier.build(
      sessionId,
    );
  }

  @override
  Override overrideWith(SessionMetadataServices Function() create) {
    return ProviderOverride(
      origin: this,
      override: SessionMetadataServicesProvider._internal(
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
  NotifierProviderElement<SessionMetadataServices, SessionMetadataTreeModel?>
      createElement() {
    return _SessionMetadataServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionMetadataServicesProvider &&
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
mixin SessionMetadataServicesRef
    on NotifierProviderRef<SessionMetadataTreeModel?> {
  /// The parameter `sessionId` of this provider.
  SessionId get sessionId;
}

class _SessionMetadataServicesProviderElement extends NotifierProviderElement<
    SessionMetadataServices,
    SessionMetadataTreeModel?> with SessionMetadataServicesRef {
  _SessionMetadataServicesProviderElement(super.provider);

  @override
  SessionId get sessionId =>
      (origin as SessionMetadataServicesProvider).sessionId;
}

String _$sessionMetadataNotifierHash() =>
    r'12b3e508d687def19f7b5a0789c816312663206b';

/// See also [SessionMetadataNotifier].
@ProviderFor(SessionMetadataNotifier)
final sessionMetadataNotifierProvider = NotifierProvider<
    SessionMetadataNotifier, SessionMetadataTreeModel?>.internal(
  SessionMetadataNotifier.new,
  name: r'sessionMetadataNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionMetadataNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionMetadataNotifier = Notifier<SessionMetadataTreeModel?>;
String _$sessionOpBarNotifierHash() =>
    r'2a5dd08f23d5a1124ce760f7aa9c23675c610526';

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
String _$selectedSQLResultTabNotifierHash() =>
    r'32c57233cbf993985dbde8f6e7fee41f05701b15';

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
    r'bc31ff0547e16517fd1a1606afd31ffeb55581bf';

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
    r'fdd375f0c151b798d7992980e461e2da08c88588';

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
