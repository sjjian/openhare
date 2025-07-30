// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionSplitViewStateHash() =>
    r'1f3e904a48dd3977623cf68c07a8fcefddd5ca05';

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

/// See also [sessionSplitViewState].
@ProviderFor(sessionSplitViewState)
const sessionSplitViewStateProvider = SessionSplitViewStateFamily();

/// See also [sessionSplitViewState].
class SessionSplitViewStateFamily extends Family<SessionSplitViewModel> {
  /// See also [sessionSplitViewState].
  const SessionSplitViewStateFamily();

  /// See also [sessionSplitViewState].
  SessionSplitViewStateProvider call(
    SessionId sessionId,
  ) {
    return SessionSplitViewStateProvider(
      sessionId,
    );
  }

  @override
  SessionSplitViewStateProvider getProviderOverride(
    covariant SessionSplitViewStateProvider provider,
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
  String? get name => r'sessionSplitViewStateProvider';
}

/// See also [sessionSplitViewState].
class SessionSplitViewStateProvider extends Provider<SessionSplitViewModel> {
  /// See also [sessionSplitViewState].
  SessionSplitViewStateProvider(
    SessionId sessionId,
  ) : this._internal(
          (ref) => sessionSplitViewState(
            ref as SessionSplitViewStateRef,
            sessionId,
          ),
          from: sessionSplitViewStateProvider,
          name: r'sessionSplitViewStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionSplitViewStateHash,
          dependencies: SessionSplitViewStateFamily._dependencies,
          allTransitiveDependencies:
              SessionSplitViewStateFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionSplitViewStateProvider._internal(
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
  Override overrideWith(
    SessionSplitViewModel Function(SessionSplitViewStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionSplitViewStateProvider._internal(
        (ref) => create(ref as SessionSplitViewStateRef),
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
  ProviderElement<SessionSplitViewModel> createElement() {
    return _SessionSplitViewStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionSplitViewStateProvider &&
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
mixin SessionSplitViewStateRef on ProviderRef<SessionSplitViewModel> {
  /// The parameter `sessionId` of this provider.
  SessionId get sessionId;
}

class _SessionSplitViewStateProviderElement
    extends ProviderElement<SessionSplitViewModel>
    with SessionSplitViewStateRef {
  _SessionSplitViewStateProviderElement(super.provider);

  @override
  SessionId get sessionId =>
      (origin as SessionSplitViewStateProvider).sessionId;
}

String _$sessionDrawerStateHash() =>
    r'e8954f01db2960aebb5987624ffdc25084b99e3d';

/// See also [sessionDrawerState].
@ProviderFor(sessionDrawerState)
const sessionDrawerStateProvider = SessionDrawerStateFamily();

/// See also [sessionDrawerState].
class SessionDrawerStateFamily extends Family<SessionDrawerModel> {
  /// See also [sessionDrawerState].
  const SessionDrawerStateFamily();

  /// See also [sessionDrawerState].
  SessionDrawerStateProvider call(
    SessionId sessionId,
  ) {
    return SessionDrawerStateProvider(
      sessionId,
    );
  }

  @override
  SessionDrawerStateProvider getProviderOverride(
    covariant SessionDrawerStateProvider provider,
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
  String? get name => r'sessionDrawerStateProvider';
}

/// See also [sessionDrawerState].
class SessionDrawerStateProvider extends Provider<SessionDrawerModel> {
  /// See also [sessionDrawerState].
  SessionDrawerStateProvider(
    SessionId sessionId,
  ) : this._internal(
          (ref) => sessionDrawerState(
            ref as SessionDrawerStateRef,
            sessionId,
          ),
          from: sessionDrawerStateProvider,
          name: r'sessionDrawerStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionDrawerStateHash,
          dependencies: SessionDrawerStateFamily._dependencies,
          allTransitiveDependencies:
              SessionDrawerStateFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionDrawerStateProvider._internal(
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
  Override overrideWith(
    SessionDrawerModel Function(SessionDrawerStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionDrawerStateProvider._internal(
        (ref) => create(ref as SessionDrawerStateRef),
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
  ProviderElement<SessionDrawerModel> createElement() {
    return _SessionDrawerStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionDrawerStateProvider && other.sessionId == sessionId;
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
mixin SessionDrawerStateRef on ProviderRef<SessionDrawerModel> {
  /// The parameter `sessionId` of this provider.
  SessionId get sessionId;
}

class _SessionDrawerStateProviderElement
    extends ProviderElement<SessionDrawerModel> with SessionDrawerStateRef {
  _SessionDrawerStateProviderElement(super.provider);

  @override
  SessionId get sessionId => (origin as SessionDrawerStateProvider).sessionId;
}

String _$sessionEditorHash() => r'25523e840883285f6d1dce3a71e7c5f5cf85ae46';

/// See also [sessionEditor].
@ProviderFor(sessionEditor)
const sessionEditorProvider = SessionEditorFamily();

/// See also [sessionEditor].
class SessionEditorFamily extends Family<SessionEditorModel> {
  /// See also [sessionEditor].
  const SessionEditorFamily();

  /// See also [sessionEditor].
  SessionEditorProvider call(
    SessionId sessionId,
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
    SessionId sessionId,
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

  final SessionId sessionId;

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
  SessionId get sessionId;
}

class _SessionEditorProviderElement extends ProviderElement<SessionEditorModel>
    with SessionEditorRef {
  _SessionEditorProviderElement(super.provider);

  @override
  SessionId get sessionId => (origin as SessionEditorProvider).sessionId;
}

String _$sessionsServicesHash() => r'59116a971831c23e57412ab4f6175f44ae8fc92e';

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
String _$sessionsNotifierHash() => r'b2abc950856cab92cc3cbcad51c9242538836f40';

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
String _$sessionSplitViewNotifierHash() =>
    r'f2149f2dd39202d91276d05b72c47f9e082a046e';

/// See also [SessionSplitViewNotifier].
@ProviderFor(SessionSplitViewNotifier)
final sessionSplitViewNotifierProvider =
    NotifierProvider<SessionSplitViewNotifier, SessionSplitViewModel>.internal(
  SessionSplitViewNotifier.new,
  name: r'sessionSplitViewNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionSplitViewNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionSplitViewNotifier = Notifier<SessionSplitViewModel>;
String _$sessionDrawerNotifierHash() =>
    r'3387e5a2348af6e5f5c15713616778de5410750e';

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
    r'c3ce4c7e1da0acbb1b7c2039f3fa3d4a16223fd4';

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
    r'50cddca3ec0f97d5a60e687b8a9049f139aa14ea';

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
    r'83754876e81f75d2c417aa16b6e627db8b8f14b4';

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
    r'7d3228cadde9ecc601b1e05d26aca5627f9ee828';

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
    r'd5fc23f6c760620d991f4efd2cf33f8058e57239';

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
String _$selectedSessionStatusNotifierHash() =>
    r'634ae1088ac7d9745aea9e8b09bfe8306b6c34ef';

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
