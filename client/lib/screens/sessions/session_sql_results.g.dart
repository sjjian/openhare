// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sql_results.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionEditorHash() => r'75d1f688113bd1cd339190c83477842de7bebebb';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
