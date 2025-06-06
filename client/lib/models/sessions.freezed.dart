// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sessions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionModel implements DiagnosticableTreeMixin {
  int get sessionId;
  int? get instanceId;
  String? get instanceName;
  DatabaseType? get dbType;

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionModelCopyWith<SessionModel> get copyWith =>
      _$SessionModelCopyWithImpl<SessionModel>(
          this as SessionModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('instanceId', instanceId))
      ..add(DiagnosticsProperty('instanceName', instanceName))
      ..add(DiagnosticsProperty('dbType', dbType));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.instanceName, instanceName) ||
                other.instanceName == instanceName) &&
            (identical(other.dbType, dbType) || other.dbType == dbType));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, sessionId, instanceId, instanceName, dbType);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionModel(sessionId: $sessionId, instanceId: $instanceId, instanceName: $instanceName, dbType: $dbType)';
  }
}

/// @nodoc
abstract mixin class $SessionModelCopyWith<$Res> {
  factory $SessionModelCopyWith(
          SessionModel value, $Res Function(SessionModel) _then) =
      _$SessionModelCopyWithImpl;
  @useResult
  $Res call(
      {int sessionId,
      int? instanceId,
      String? instanceName,
      DatabaseType? dbType});
}

/// @nodoc
class _$SessionModelCopyWithImpl<$Res> implements $SessionModelCopyWith<$Res> {
  _$SessionModelCopyWithImpl(this._self, this._then);

  final SessionModel _self;
  final $Res Function(SessionModel) _then;

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? instanceId = freezed,
    Object? instanceName = freezed,
    Object? dbType = freezed,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      instanceId: freezed == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as int?,
      instanceName: freezed == instanceName
          ? _self.instanceName
          : instanceName // ignore: cast_nullable_to_non_nullable
              as String?,
      dbType: freezed == dbType
          ? _self.dbType
          : dbType // ignore: cast_nullable_to_non_nullable
              as DatabaseType?,
    ));
  }
}

/// @nodoc

class _SessionModel with DiagnosticableTreeMixin implements SessionModel {
  const _SessionModel(
      {required this.sessionId,
      this.instanceId,
      this.instanceName,
      this.dbType});

  @override
  final int sessionId;
  @override
  final int? instanceId;
  @override
  final String? instanceName;
  @override
  final DatabaseType? dbType;

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionModelCopyWith<_SessionModel> get copyWith =>
      __$SessionModelCopyWithImpl<_SessionModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('instanceId', instanceId))
      ..add(DiagnosticsProperty('instanceName', instanceName))
      ..add(DiagnosticsProperty('dbType', dbType));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.instanceName, instanceName) ||
                other.instanceName == instanceName) &&
            (identical(other.dbType, dbType) || other.dbType == dbType));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, sessionId, instanceId, instanceName, dbType);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionModel(sessionId: $sessionId, instanceId: $instanceId, instanceName: $instanceName, dbType: $dbType)';
  }
}

/// @nodoc
abstract mixin class _$SessionModelCopyWith<$Res>
    implements $SessionModelCopyWith<$Res> {
  factory _$SessionModelCopyWith(
          _SessionModel value, $Res Function(_SessionModel) _then) =
      __$SessionModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int sessionId,
      int? instanceId,
      String? instanceName,
      DatabaseType? dbType});
}

/// @nodoc
class __$SessionModelCopyWithImpl<$Res>
    implements _$SessionModelCopyWith<$Res> {
  __$SessionModelCopyWithImpl(this._self, this._then);

  final _SessionModel _self;
  final $Res Function(_SessionModel) _then;

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? instanceId = freezed,
    Object? instanceName = freezed,
    Object? dbType = freezed,
  }) {
    return _then(_SessionModel(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      instanceId: freezed == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as int?,
      instanceName: freezed == instanceName
          ? _self.instanceName
          : instanceName // ignore: cast_nullable_to_non_nullable
              as String?,
      dbType: freezed == dbType
          ? _self.dbType
          : dbType // ignore: cast_nullable_to_non_nullable
              as DatabaseType?,
    ));
  }
}

/// @nodoc
mixin _$SessionListModel implements DiagnosticableTreeMixin {
  List<SessionModel> get sessions;
  SessionModel? get selectedSession;

  /// Create a copy of SessionListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionListModelCopyWith<SessionListModel> get copyWith =>
      _$SessionListModelCopyWithImpl<SessionListModel>(
          this as SessionListModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionListModel'))
      ..add(DiagnosticsProperty('sessions', sessions))
      ..add(DiagnosticsProperty('selectedSession', selectedSession));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionListModel &&
            const DeepCollectionEquality().equals(other.sessions, sessions) &&
            (identical(other.selectedSession, selectedSession) ||
                other.selectedSession == selectedSession));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(sessions), selectedSession);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionListModel(sessions: $sessions, selectedSession: $selectedSession)';
  }
}

/// @nodoc
abstract mixin class $SessionListModelCopyWith<$Res> {
  factory $SessionListModelCopyWith(
          SessionListModel value, $Res Function(SessionListModel) _then) =
      _$SessionListModelCopyWithImpl;
  @useResult
  $Res call({List<SessionModel> sessions, SessionModel? selectedSession});

  $SessionModelCopyWith<$Res>? get selectedSession;
}

/// @nodoc
class _$SessionListModelCopyWithImpl<$Res>
    implements $SessionListModelCopyWith<$Res> {
  _$SessionListModelCopyWithImpl(this._self, this._then);

  final SessionListModel _self;
  final $Res Function(SessionListModel) _then;

  /// Create a copy of SessionListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessions = null,
    Object? selectedSession = freezed,
  }) {
    return _then(_self.copyWith(
      sessions: null == sessions
          ? _self.sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<SessionModel>,
      selectedSession: freezed == selectedSession
          ? _self.selectedSession
          : selectedSession // ignore: cast_nullable_to_non_nullable
              as SessionModel?,
    ));
  }

  /// Create a copy of SessionListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionModelCopyWith<$Res>? get selectedSession {
    if (_self.selectedSession == null) {
      return null;
    }

    return $SessionModelCopyWith<$Res>(_self.selectedSession!, (value) {
      return _then(_self.copyWith(selectedSession: value));
    });
  }
}

/// @nodoc

class _SessionListModel
    with DiagnosticableTreeMixin
    implements SessionListModel {
  const _SessionListModel(
      {required final List<SessionModel> sessions, this.selectedSession})
      : _sessions = sessions;

  final List<SessionModel> _sessions;
  @override
  List<SessionModel> get sessions {
    if (_sessions is EqualUnmodifiableListView) return _sessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessions);
  }

  @override
  final SessionModel? selectedSession;

  /// Create a copy of SessionListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionListModelCopyWith<_SessionListModel> get copyWith =>
      __$SessionListModelCopyWithImpl<_SessionListModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionListModel'))
      ..add(DiagnosticsProperty('sessions', sessions))
      ..add(DiagnosticsProperty('selectedSession', selectedSession));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionListModel &&
            const DeepCollectionEquality().equals(other._sessions, _sessions) &&
            (identical(other.selectedSession, selectedSession) ||
                other.selectedSession == selectedSession));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_sessions), selectedSession);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionListModel(sessions: $sessions, selectedSession: $selectedSession)';
  }
}

/// @nodoc
abstract mixin class _$SessionListModelCopyWith<$Res>
    implements $SessionListModelCopyWith<$Res> {
  factory _$SessionListModelCopyWith(
          _SessionListModel value, $Res Function(_SessionListModel) _then) =
      __$SessionListModelCopyWithImpl;
  @override
  @useResult
  $Res call({List<SessionModel> sessions, SessionModel? selectedSession});

  @override
  $SessionModelCopyWith<$Res>? get selectedSession;
}

/// @nodoc
class __$SessionListModelCopyWithImpl<$Res>
    implements _$SessionListModelCopyWith<$Res> {
  __$SessionListModelCopyWithImpl(this._self, this._then);

  final _SessionListModel _self;
  final $Res Function(_SessionListModel) _then;

  /// Create a copy of SessionListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessions = null,
    Object? selectedSession = freezed,
  }) {
    return _then(_SessionListModel(
      sessions: null == sessions
          ? _self._sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<SessionModel>,
      selectedSession: freezed == selectedSession
          ? _self.selectedSession
          : selectedSession // ignore: cast_nullable_to_non_nullable
              as SessionModel?,
    ));
  }

  /// Create a copy of SessionListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionModelCopyWith<$Res>? get selectedSession {
    if (_self.selectedSession == null) {
      return null;
    }

    return $SessionModelCopyWith<$Res>(_self.selectedSession!, (value) {
      return _then(_self.copyWith(selectedSession: value));
    });
  }
}

/// @nodoc
mixin _$SessionOpBarModel implements DiagnosticableTreeMixin {
  int get sessionId;
  bool get canQuery;
  String get currentSchema;
  bool get isRightPageOpen;

  /// Create a copy of SessionOpBarModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionOpBarModelCopyWith<SessionOpBarModel> get copyWith =>
      _$SessionOpBarModelCopyWithImpl<SessionOpBarModel>(
          this as SessionOpBarModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionOpBarModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('canQuery', canQuery))
      ..add(DiagnosticsProperty('currentSchema', currentSchema))
      ..add(DiagnosticsProperty('isRightPageOpen', isRightPageOpen));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionOpBarModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.canQuery, canQuery) ||
                other.canQuery == canQuery) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.isRightPageOpen, isRightPageOpen) ||
                other.isRightPageOpen == isRightPageOpen));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, sessionId, canQuery, currentSchema, isRightPageOpen);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionOpBarModel(sessionId: $sessionId, canQuery: $canQuery, currentSchema: $currentSchema, isRightPageOpen: $isRightPageOpen)';
  }
}

/// @nodoc
abstract mixin class $SessionOpBarModelCopyWith<$Res> {
  factory $SessionOpBarModelCopyWith(
          SessionOpBarModel value, $Res Function(SessionOpBarModel) _then) =
      _$SessionOpBarModelCopyWithImpl;
  @useResult
  $Res call(
      {int sessionId,
      bool canQuery,
      String currentSchema,
      bool isRightPageOpen});
}

/// @nodoc
class _$SessionOpBarModelCopyWithImpl<$Res>
    implements $SessionOpBarModelCopyWith<$Res> {
  _$SessionOpBarModelCopyWithImpl(this._self, this._then);

  final SessionOpBarModel _self;
  final $Res Function(SessionOpBarModel) _then;

  /// Create a copy of SessionOpBarModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? canQuery = null,
    Object? currentSchema = null,
    Object? isRightPageOpen = null,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      canQuery: null == canQuery
          ? _self.canQuery
          : canQuery // ignore: cast_nullable_to_non_nullable
              as bool,
      currentSchema: null == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String,
      isRightPageOpen: null == isRightPageOpen
          ? _self.isRightPageOpen
          : isRightPageOpen // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _SessionOpBarModel
    with DiagnosticableTreeMixin
    implements SessionOpBarModel {
  const _SessionOpBarModel(
      {required this.sessionId,
      required this.canQuery,
      required this.currentSchema,
      required this.isRightPageOpen});

  @override
  final int sessionId;
  @override
  final bool canQuery;
  @override
  final String currentSchema;
  @override
  final bool isRightPageOpen;

  /// Create a copy of SessionOpBarModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionOpBarModelCopyWith<_SessionOpBarModel> get copyWith =>
      __$SessionOpBarModelCopyWithImpl<_SessionOpBarModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionOpBarModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('canQuery', canQuery))
      ..add(DiagnosticsProperty('currentSchema', currentSchema))
      ..add(DiagnosticsProperty('isRightPageOpen', isRightPageOpen));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionOpBarModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.canQuery, canQuery) ||
                other.canQuery == canQuery) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.isRightPageOpen, isRightPageOpen) ||
                other.isRightPageOpen == isRightPageOpen));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, sessionId, canQuery, currentSchema, isRightPageOpen);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionOpBarModel(sessionId: $sessionId, canQuery: $canQuery, currentSchema: $currentSchema, isRightPageOpen: $isRightPageOpen)';
  }
}

/// @nodoc
abstract mixin class _$SessionOpBarModelCopyWith<$Res>
    implements $SessionOpBarModelCopyWith<$Res> {
  factory _$SessionOpBarModelCopyWith(
          _SessionOpBarModel value, $Res Function(_SessionOpBarModel) _then) =
      __$SessionOpBarModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int sessionId,
      bool canQuery,
      String currentSchema,
      bool isRightPageOpen});
}

/// @nodoc
class __$SessionOpBarModelCopyWithImpl<$Res>
    implements _$SessionOpBarModelCopyWith<$Res> {
  __$SessionOpBarModelCopyWithImpl(this._self, this._then);

  final _SessionOpBarModel _self;
  final $Res Function(_SessionOpBarModel) _then;

  /// Create a copy of SessionOpBarModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? canQuery = null,
    Object? currentSchema = null,
    Object? isRightPageOpen = null,
  }) {
    return _then(_SessionOpBarModel(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      canQuery: null == canQuery
          ? _self.canQuery
          : canQuery // ignore: cast_nullable_to_non_nullable
              as bool,
      currentSchema: null == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String,
      isRightPageOpen: null == isRightPageOpen
          ? _self.isRightPageOpen
          : isRightPageOpen // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
