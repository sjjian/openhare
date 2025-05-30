// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionDrawerStateHash() =>
    r'253c562fbed2294539c4066cb1ed1458efdb5087';

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

/// See also [sessionDrawerState].
@ProviderFor(sessionDrawerState)
const sessionDrawerStateProvider = SessionDrawerStateFamily();

/// See also [sessionDrawerState].
class SessionDrawerStateFamily extends Family<CurrentSessionDrawer> {
  /// See also [sessionDrawerState].
  const SessionDrawerStateFamily();

  /// See also [sessionDrawerState].
  SessionDrawerStateProvider call(
    int sessionId,
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
class SessionDrawerStateProvider extends Provider<CurrentSessionDrawer> {
  /// See also [sessionDrawerState].
  SessionDrawerStateProvider(
    int sessionId,
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

  final int sessionId;

  @override
  Override overrideWith(
    CurrentSessionDrawer Function(SessionDrawerStateRef provider) create,
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
  ProviderElement<CurrentSessionDrawer> createElement() {
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
mixin SessionDrawerStateRef on ProviderRef<CurrentSessionDrawer> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionDrawerStateProviderElement
    extends ProviderElement<CurrentSessionDrawer> with SessionDrawerStateRef {
  _SessionDrawerStateProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionDrawerStateProvider).sessionId;
}

String _$sessionSplitViewStateHash() =>
    r'78724f95d90323f72d5adb3c2508ada6ae45a8aa';

/// See also [sessionSplitViewState].
@ProviderFor(sessionSplitViewState)
const sessionSplitViewStateProvider = SessionSplitViewStateFamily();

/// See also [sessionSplitViewState].
class SessionSplitViewStateFamily extends Family<CurrentSessionSplitView> {
  /// See also [sessionSplitViewState].
  const SessionSplitViewStateFamily();

  /// See also [sessionSplitViewState].
  SessionSplitViewStateProvider call(
    int sessionId,
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
class SessionSplitViewStateProvider extends Provider<CurrentSessionSplitView> {
  /// See also [sessionSplitViewState].
  SessionSplitViewStateProvider(
    int sessionId,
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

  final int sessionId;

  @override
  Override overrideWith(
    CurrentSessionSplitView Function(SessionSplitViewStateRef provider) create,
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
  ProviderElement<CurrentSessionSplitView> createElement() {
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
mixin SessionSplitViewStateRef on ProviderRef<CurrentSessionSplitView> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionSplitViewStateProviderElement
    extends ProviderElement<CurrentSessionSplitView>
    with SessionSplitViewStateRef {
  _SessionSplitViewStateProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionSplitViewStateProvider).sessionId;
}

String _$sessionMetadataStateHash() =>
    r'1c6d6dd0214abf854c807d3227fb564145ffb104';

/// See also [sessionMetadataState].
@ProviderFor(sessionMetadataState)
const sessionMetadataStateProvider = SessionMetadataStateFamily();

/// See also [sessionMetadataState].
class SessionMetadataStateFamily extends Family<CurrentSessionMetadata> {
  /// See also [sessionMetadataState].
  const SessionMetadataStateFamily();

  /// See also [sessionMetadataState].
  SessionMetadataStateProvider call(
    int sessionId,
  ) {
    return SessionMetadataStateProvider(
      sessionId,
    );
  }

  @override
  SessionMetadataStateProvider getProviderOverride(
    covariant SessionMetadataStateProvider provider,
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
  String? get name => r'sessionMetadataStateProvider';
}

/// See also [sessionMetadataState].
class SessionMetadataStateProvider extends Provider<CurrentSessionMetadata> {
  /// See also [sessionMetadataState].
  SessionMetadataStateProvider(
    int sessionId,
  ) : this._internal(
          (ref) => sessionMetadataState(
            ref as SessionMetadataStateRef,
            sessionId,
          ),
          from: sessionMetadataStateProvider,
          name: r'sessionMetadataStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionMetadataStateHash,
          dependencies: SessionMetadataStateFamily._dependencies,
          allTransitiveDependencies:
              SessionMetadataStateFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionMetadataStateProvider._internal(
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
    CurrentSessionMetadata Function(SessionMetadataStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionMetadataStateProvider._internal(
        (ref) => create(ref as SessionMetadataStateRef),
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
  ProviderElement<CurrentSessionMetadata> createElement() {
    return _SessionMetadataStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionMetadataStateProvider &&
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
mixin SessionMetadataStateRef on ProviderRef<CurrentSessionMetadata> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionMetadataStateProviderElement
    extends ProviderElement<CurrentSessionMetadata>
    with SessionMetadataStateRef {
  _SessionMetadataStateProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionMetadataStateProvider).sessionId;
}

String _$sessionEditorHash() => r'75d1f688113bd1cd339190c83477842de7bebebb';

/// See also [sessionEditor].
@ProviderFor(sessionEditor)
const sessionEditorProvider = SessionEditorFamily();

/// See also [sessionEditor].
class SessionEditorFamily extends Family<CurrentSessionEditor> {
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
class SessionEditorProvider extends Provider<CurrentSessionEditor> {
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
    CurrentSessionEditor Function(SessionEditorRef provider) create,
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
  ProviderElement<CurrentSessionEditor> createElement() {
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
mixin SessionEditorRef on ProviderRef<CurrentSessionEditor> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionEditorProviderElement
    extends ProviderElement<CurrentSessionEditor> with SessionEditorRef {
  _SessionEditorProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionEditorProvider).sessionId;
}

String _$sessionDrawerControllerHash() =>
    r'68905e8f14557e1cd1e4ef8670856af47fc89c2a';

/// See also [SessionDrawerController].
@ProviderFor(SessionDrawerController)
final sessionDrawerControllerProvider =
    NotifierProvider<SessionDrawerController, CurrentSessionDrawer>.internal(
  SessionDrawerController.new,
  name: r'sessionDrawerControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionDrawerControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionDrawerController = Notifier<CurrentSessionDrawer>;
String _$sessionSplitViewControllerHash() =>
    r'1157471642f90baaaf7ecaf79a2c12f3d29ccb4a';

/// See also [SessionSplitViewController].
@ProviderFor(SessionSplitViewController)
final sessionSplitViewControllerProvider = NotifierProvider<
    SessionSplitViewController, CurrentSessionSplitView>.internal(
  SessionSplitViewController.new,
  name: r'sessionSplitViewControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionSplitViewControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionSplitViewController = Notifier<CurrentSessionSplitView>;
String _$sessionMetadataControllerHash() =>
    r'40d88c33e11654ffde09122f31c3c25fbd79ad40';

/// See also [SessionMetadataController].
@ProviderFor(SessionMetadataController)
final sessionMetadataControllerProvider = NotifierProvider<
    SessionMetadataController, CurrentSessionMetadata>.internal(
  SessionMetadataController.new,
  name: r'sessionMetadataControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionMetadataControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionMetadataController = Notifier<CurrentSessionMetadata>;
String _$sessionEditorControllerHash() =>
    r'c7bd7423d35ed04e4029760170b594c6e9d1fee8';

/// See also [SessionEditorController].
@ProviderFor(SessionEditorController)
final sessionEditorControllerProvider =
    NotifierProvider<SessionEditorController, CurrentSessionEditor>.internal(
  SessionEditorController.new,
  name: r'sessionEditorControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionEditorControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionEditorController = Notifier<CurrentSessionEditor>;
String _$selectedSessionIdControllerHash() =>
    r'3237280e9ec9bae6f7e835828775d8c3c27c98d6';

/// See also [SelectedSessionIdController].
@ProviderFor(SelectedSessionIdController)
final selectedSessionIdControllerProvider =
    NotifierProvider<SelectedSessionIdController, SelectedSessionId?>.internal(
  SelectedSessionIdController.new,
  name: r'selectedSessionIdControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionIdControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionIdController = Notifier<SelectedSessionId?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
