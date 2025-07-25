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
mixin _$SessionId implements DiagnosticableTreeMixin {
  int get value;

  /// Create a copy of SessionId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionIdCopyWith<SessionId> get copyWith =>
      _$SessionIdCopyWithImpl<SessionId>(this as SessionId, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionId'))
      ..add(DiagnosticsProperty('value', value));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionId(value: $value)';
  }
}

/// @nodoc
abstract mixin class $SessionIdCopyWith<$Res> {
  factory $SessionIdCopyWith(SessionId value, $Res Function(SessionId) _then) =
      _$SessionIdCopyWithImpl;
  @useResult
  $Res call({int value});
}

/// @nodoc
class _$SessionIdCopyWithImpl<$Res> implements $SessionIdCopyWith<$Res> {
  _$SessionIdCopyWithImpl(this._self, this._then);

  final SessionId _self;
  final $Res Function(SessionId) _then;

  /// Create a copy of SessionId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_self.copyWith(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _SessionId with DiagnosticableTreeMixin implements SessionId {
  const _SessionId({required this.value});

  @override
  final int value;

  /// Create a copy of SessionId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionIdCopyWith<_SessionId> get copyWith =>
      __$SessionIdCopyWithImpl<_SessionId>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionId'))
      ..add(DiagnosticsProperty('value', value));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionId(value: $value)';
  }
}

/// @nodoc
abstract mixin class _$SessionIdCopyWith<$Res>
    implements $SessionIdCopyWith<$Res> {
  factory _$SessionIdCopyWith(
          _SessionId value, $Res Function(_SessionId) _then) =
      __$SessionIdCopyWithImpl;
  @override
  @useResult
  $Res call({int value});
}

/// @nodoc
class __$SessionIdCopyWithImpl<$Res> implements _$SessionIdCopyWith<$Res> {
  __$SessionIdCopyWithImpl(this._self, this._then);

  final _SessionId _self;
  final $Res Function(_SessionId) _then;

  /// Create a copy of SessionId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
  }) {
    return _then(_SessionId(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$SessionModel implements DiagnosticableTreeMixin {
  SessionId get sessionId;
  InstanceId? get instanceId;
  String? get instanceName;
  String? get currentSchema;
  DatabaseType? get dbType;
  ConnId? get connId;

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
      ..add(DiagnosticsProperty('currentSchema', currentSchema))
      ..add(DiagnosticsProperty('dbType', dbType))
      ..add(DiagnosticsProperty('connId', connId));
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
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.dbType, dbType) || other.dbType == dbType) &&
            (identical(other.connId, connId) || other.connId == connId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, instanceId,
      instanceName, currentSchema, dbType, connId);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionModel(sessionId: $sessionId, instanceId: $instanceId, instanceName: $instanceName, currentSchema: $currentSchema, dbType: $dbType, connId: $connId)';
  }
}

/// @nodoc
abstract mixin class $SessionModelCopyWith<$Res> {
  factory $SessionModelCopyWith(
          SessionModel value, $Res Function(SessionModel) _then) =
      _$SessionModelCopyWithImpl;
  @useResult
  $Res call(
      {SessionId sessionId,
      InstanceId? instanceId,
      String? instanceName,
      String? currentSchema,
      DatabaseType? dbType,
      ConnId? connId});

  $SessionIdCopyWith<$Res> get sessionId;
  $InstanceIdCopyWith<$Res>? get instanceId;
  $ConnIdCopyWith<$Res>? get connId;
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
    Object? currentSchema = freezed,
    Object? dbType = freezed,
    Object? connId = freezed,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as SessionId,
      instanceId: freezed == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as InstanceId?,
      instanceName: freezed == instanceName
          ? _self.instanceName
          : instanceName // ignore: cast_nullable_to_non_nullable
              as String?,
      currentSchema: freezed == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String?,
      dbType: freezed == dbType
          ? _self.dbType
          : dbType // ignore: cast_nullable_to_non_nullable
              as DatabaseType?,
      connId: freezed == connId
          ? _self.connId
          : connId // ignore: cast_nullable_to_non_nullable
              as ConnId?,
    ));
  }

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionIdCopyWith<$Res> get sessionId {
    return $SessionIdCopyWith<$Res>(_self.sessionId, (value) {
      return _then(_self.copyWith(sessionId: value));
    });
  }

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<$Res>? get instanceId {
    if (_self.instanceId == null) {
      return null;
    }

    return $InstanceIdCopyWith<$Res>(_self.instanceId!, (value) {
      return _then(_self.copyWith(instanceId: value));
    });
  }

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConnIdCopyWith<$Res>? get connId {
    if (_self.connId == null) {
      return null;
    }

    return $ConnIdCopyWith<$Res>(_self.connId!, (value) {
      return _then(_self.copyWith(connId: value));
    });
  }
}

/// @nodoc

class _SessionModel with DiagnosticableTreeMixin implements SessionModel {
  const _SessionModel(
      {required this.sessionId,
      this.instanceId,
      this.instanceName,
      this.currentSchema,
      this.dbType,
      this.connId});

  @override
  final SessionId sessionId;
  @override
  final InstanceId? instanceId;
  @override
  final String? instanceName;
  @override
  final String? currentSchema;
  @override
  final DatabaseType? dbType;
  @override
  final ConnId? connId;

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
      ..add(DiagnosticsProperty('currentSchema', currentSchema))
      ..add(DiagnosticsProperty('dbType', dbType))
      ..add(DiagnosticsProperty('connId', connId));
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
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.dbType, dbType) || other.dbType == dbType) &&
            (identical(other.connId, connId) || other.connId == connId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, instanceId,
      instanceName, currentSchema, dbType, connId);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionModel(sessionId: $sessionId, instanceId: $instanceId, instanceName: $instanceName, currentSchema: $currentSchema, dbType: $dbType, connId: $connId)';
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
      {SessionId sessionId,
      InstanceId? instanceId,
      String? instanceName,
      String? currentSchema,
      DatabaseType? dbType,
      ConnId? connId});

  @override
  $SessionIdCopyWith<$Res> get sessionId;
  @override
  $InstanceIdCopyWith<$Res>? get instanceId;
  @override
  $ConnIdCopyWith<$Res>? get connId;
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
    Object? currentSchema = freezed,
    Object? dbType = freezed,
    Object? connId = freezed,
  }) {
    return _then(_SessionModel(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as SessionId,
      instanceId: freezed == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as InstanceId?,
      instanceName: freezed == instanceName
          ? _self.instanceName
          : instanceName // ignore: cast_nullable_to_non_nullable
              as String?,
      currentSchema: freezed == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String?,
      dbType: freezed == dbType
          ? _self.dbType
          : dbType // ignore: cast_nullable_to_non_nullable
              as DatabaseType?,
      connId: freezed == connId
          ? _self.connId
          : connId // ignore: cast_nullable_to_non_nullable
              as ConnId?,
    ));
  }

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionIdCopyWith<$Res> get sessionId {
    return $SessionIdCopyWith<$Res>(_self.sessionId, (value) {
      return _then(_self.copyWith(sessionId: value));
    });
  }

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<$Res>? get instanceId {
    if (_self.instanceId == null) {
      return null;
    }

    return $InstanceIdCopyWith<$Res>(_self.instanceId!, (value) {
      return _then(_self.copyWith(instanceId: value));
    });
  }

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConnIdCopyWith<$Res>? get connId {
    if (_self.connId == null) {
      return null;
    }

    return $ConnIdCopyWith<$Res>(_self.connId!, (value) {
      return _then(_self.copyWith(connId: value));
    });
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
  SessionId get sessionId;
  ConnId? get connId;
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
      ..add(DiagnosticsProperty('connId', connId))
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
            (identical(other.connId, connId) || other.connId == connId) &&
            (identical(other.canQuery, canQuery) ||
                other.canQuery == canQuery) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.isRightPageOpen, isRightPageOpen) ||
                other.isRightPageOpen == isRightPageOpen));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, sessionId, connId, canQuery, currentSchema, isRightPageOpen);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionOpBarModel(sessionId: $sessionId, connId: $connId, canQuery: $canQuery, currentSchema: $currentSchema, isRightPageOpen: $isRightPageOpen)';
  }
}

/// @nodoc
abstract mixin class $SessionOpBarModelCopyWith<$Res> {
  factory $SessionOpBarModelCopyWith(
          SessionOpBarModel value, $Res Function(SessionOpBarModel) _then) =
      _$SessionOpBarModelCopyWithImpl;
  @useResult
  $Res call(
      {SessionId sessionId,
      ConnId? connId,
      bool canQuery,
      String currentSchema,
      bool isRightPageOpen});

  $SessionIdCopyWith<$Res> get sessionId;
  $ConnIdCopyWith<$Res>? get connId;
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
    Object? connId = freezed,
    Object? canQuery = null,
    Object? currentSchema = null,
    Object? isRightPageOpen = null,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as SessionId,
      connId: freezed == connId
          ? _self.connId
          : connId // ignore: cast_nullable_to_non_nullable
              as ConnId?,
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

  /// Create a copy of SessionOpBarModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionIdCopyWith<$Res> get sessionId {
    return $SessionIdCopyWith<$Res>(_self.sessionId, (value) {
      return _then(_self.copyWith(sessionId: value));
    });
  }

  /// Create a copy of SessionOpBarModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConnIdCopyWith<$Res>? get connId {
    if (_self.connId == null) {
      return null;
    }

    return $ConnIdCopyWith<$Res>(_self.connId!, (value) {
      return _then(_self.copyWith(connId: value));
    });
  }
}

/// @nodoc

class _SessionOpBarModel
    with DiagnosticableTreeMixin
    implements SessionOpBarModel {
  const _SessionOpBarModel(
      {required this.sessionId,
      required this.connId,
      required this.canQuery,
      required this.currentSchema,
      required this.isRightPageOpen});

  @override
  final SessionId sessionId;
  @override
  final ConnId? connId;
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
      ..add(DiagnosticsProperty('connId', connId))
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
            (identical(other.connId, connId) || other.connId == connId) &&
            (identical(other.canQuery, canQuery) ||
                other.canQuery == canQuery) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.isRightPageOpen, isRightPageOpen) ||
                other.isRightPageOpen == isRightPageOpen));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, sessionId, connId, canQuery, currentSchema, isRightPageOpen);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionOpBarModel(sessionId: $sessionId, connId: $connId, canQuery: $canQuery, currentSchema: $currentSchema, isRightPageOpen: $isRightPageOpen)';
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
      {SessionId sessionId,
      ConnId? connId,
      bool canQuery,
      String currentSchema,
      bool isRightPageOpen});

  @override
  $SessionIdCopyWith<$Res> get sessionId;
  @override
  $ConnIdCopyWith<$Res>? get connId;
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
    Object? connId = freezed,
    Object? canQuery = null,
    Object? currentSchema = null,
    Object? isRightPageOpen = null,
  }) {
    return _then(_SessionOpBarModel(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as SessionId,
      connId: freezed == connId
          ? _self.connId
          : connId // ignore: cast_nullable_to_non_nullable
              as ConnId?,
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

  /// Create a copy of SessionOpBarModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionIdCopyWith<$Res> get sessionId {
    return $SessionIdCopyWith<$Res>(_self.sessionId, (value) {
      return _then(_self.copyWith(sessionId: value));
    });
  }

  /// Create a copy of SessionOpBarModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConnIdCopyWith<$Res>? get connId {
    if (_self.connId == null) {
      return null;
    }

    return $ConnIdCopyWith<$Res>(_self.connId!, (value) {
      return _then(_self.copyWith(connId: value));
    });
  }
}

/// @nodoc
mixin _$SessionEditorModel implements DiagnosticableTreeMixin {
  CodeLineEditingController get code;

  /// Create a copy of SessionEditorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionEditorModelCopyWith<SessionEditorModel> get copyWith =>
      _$SessionEditorModelCopyWithImpl<SessionEditorModel>(
          this as SessionEditorModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionEditorModel'))
      ..add(DiagnosticsProperty('code', code));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionEditorModel &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionEditorModel(code: $code)';
  }
}

/// @nodoc
abstract mixin class $SessionEditorModelCopyWith<$Res> {
  factory $SessionEditorModelCopyWith(
          SessionEditorModel value, $Res Function(SessionEditorModel) _then) =
      _$SessionEditorModelCopyWithImpl;
  @useResult
  $Res call({CodeLineEditingController code});
}

/// @nodoc
class _$SessionEditorModelCopyWithImpl<$Res>
    implements $SessionEditorModelCopyWith<$Res> {
  _$SessionEditorModelCopyWithImpl(this._self, this._then);

  final SessionEditorModel _self;
  final $Res Function(SessionEditorModel) _then;

  /// Create a copy of SessionEditorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
  }) {
    return _then(_self.copyWith(
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as CodeLineEditingController,
    ));
  }
}

/// @nodoc

class _SessionEditorModel
    with DiagnosticableTreeMixin
    implements SessionEditorModel {
  const _SessionEditorModel({required this.code});

  @override
  final CodeLineEditingController code;

  /// Create a copy of SessionEditorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionEditorModelCopyWith<_SessionEditorModel> get copyWith =>
      __$SessionEditorModelCopyWithImpl<_SessionEditorModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionEditorModel'))
      ..add(DiagnosticsProperty('code', code));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionEditorModel &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionEditorModel(code: $code)';
  }
}

/// @nodoc
abstract mixin class _$SessionEditorModelCopyWith<$Res>
    implements $SessionEditorModelCopyWith<$Res> {
  factory _$SessionEditorModelCopyWith(
          _SessionEditorModel value, $Res Function(_SessionEditorModel) _then) =
      __$SessionEditorModelCopyWithImpl;
  @override
  @useResult
  $Res call({CodeLineEditingController code});
}

/// @nodoc
class __$SessionEditorModelCopyWithImpl<$Res>
    implements _$SessionEditorModelCopyWith<$Res> {
  __$SessionEditorModelCopyWithImpl(this._self, this._then);

  final _SessionEditorModel _self;
  final $Res Function(_SessionEditorModel) _then;

  /// Create a copy of SessionEditorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? code = null,
  }) {
    return _then(_SessionEditorModel(
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as CodeLineEditingController,
    ));
  }
}

/// @nodoc
mixin _$SessionDrawerModel implements DiagnosticableTreeMixin {
  DrawerPage get drawerPage;
  BaseQueryValue? get sqlResult;
  BaseQueryColumn? get sqlColumn;
  bool get showRecord;
  bool get isRightPageOpen;

  /// Create a copy of SessionDrawerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionDrawerModelCopyWith<SessionDrawerModel> get copyWith =>
      _$SessionDrawerModelCopyWithImpl<SessionDrawerModel>(
          this as SessionDrawerModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionDrawerModel'))
      ..add(DiagnosticsProperty('drawerPage', drawerPage))
      ..add(DiagnosticsProperty('sqlResult', sqlResult))
      ..add(DiagnosticsProperty('sqlColumn', sqlColumn))
      ..add(DiagnosticsProperty('showRecord', showRecord))
      ..add(DiagnosticsProperty('isRightPageOpen', isRightPageOpen));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionDrawerModel &&
            (identical(other.drawerPage, drawerPage) ||
                other.drawerPage == drawerPage) &&
            (identical(other.sqlResult, sqlResult) ||
                other.sqlResult == sqlResult) &&
            (identical(other.sqlColumn, sqlColumn) ||
                other.sqlColumn == sqlColumn) &&
            (identical(other.showRecord, showRecord) ||
                other.showRecord == showRecord) &&
            (identical(other.isRightPageOpen, isRightPageOpen) ||
                other.isRightPageOpen == isRightPageOpen));
  }

  @override
  int get hashCode => Object.hash(runtimeType, drawerPage, sqlResult, sqlColumn,
      showRecord, isRightPageOpen);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionDrawerModel(drawerPage: $drawerPage, sqlResult: $sqlResult, sqlColumn: $sqlColumn, showRecord: $showRecord, isRightPageOpen: $isRightPageOpen)';
  }
}

/// @nodoc
abstract mixin class $SessionDrawerModelCopyWith<$Res> {
  factory $SessionDrawerModelCopyWith(
          SessionDrawerModel value, $Res Function(SessionDrawerModel) _then) =
      _$SessionDrawerModelCopyWithImpl;
  @useResult
  $Res call(
      {DrawerPage drawerPage,
      BaseQueryValue? sqlResult,
      BaseQueryColumn? sqlColumn,
      bool showRecord,
      bool isRightPageOpen});
}

/// @nodoc
class _$SessionDrawerModelCopyWithImpl<$Res>
    implements $SessionDrawerModelCopyWith<$Res> {
  _$SessionDrawerModelCopyWithImpl(this._self, this._then);

  final SessionDrawerModel _self;
  final $Res Function(SessionDrawerModel) _then;

  /// Create a copy of SessionDrawerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? drawerPage = null,
    Object? sqlResult = freezed,
    Object? sqlColumn = freezed,
    Object? showRecord = null,
    Object? isRightPageOpen = null,
  }) {
    return _then(_self.copyWith(
      drawerPage: null == drawerPage
          ? _self.drawerPage
          : drawerPage // ignore: cast_nullable_to_non_nullable
              as DrawerPage,
      sqlResult: freezed == sqlResult
          ? _self.sqlResult
          : sqlResult // ignore: cast_nullable_to_non_nullable
              as BaseQueryValue?,
      sqlColumn: freezed == sqlColumn
          ? _self.sqlColumn
          : sqlColumn // ignore: cast_nullable_to_non_nullable
              as BaseQueryColumn?,
      showRecord: null == showRecord
          ? _self.showRecord
          : showRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      isRightPageOpen: null == isRightPageOpen
          ? _self.isRightPageOpen
          : isRightPageOpen // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _SessionDrawerModel
    with DiagnosticableTreeMixin
    implements SessionDrawerModel {
  const _SessionDrawerModel(
      {required this.drawerPage,
      required this.sqlResult,
      required this.sqlColumn,
      required this.showRecord,
      required this.isRightPageOpen});

  @override
  final DrawerPage drawerPage;
  @override
  final BaseQueryValue? sqlResult;
  @override
  final BaseQueryColumn? sqlColumn;
  @override
  final bool showRecord;
  @override
  final bool isRightPageOpen;

  /// Create a copy of SessionDrawerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionDrawerModelCopyWith<_SessionDrawerModel> get copyWith =>
      __$SessionDrawerModelCopyWithImpl<_SessionDrawerModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionDrawerModel'))
      ..add(DiagnosticsProperty('drawerPage', drawerPage))
      ..add(DiagnosticsProperty('sqlResult', sqlResult))
      ..add(DiagnosticsProperty('sqlColumn', sqlColumn))
      ..add(DiagnosticsProperty('showRecord', showRecord))
      ..add(DiagnosticsProperty('isRightPageOpen', isRightPageOpen));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionDrawerModel &&
            (identical(other.drawerPage, drawerPage) ||
                other.drawerPage == drawerPage) &&
            (identical(other.sqlResult, sqlResult) ||
                other.sqlResult == sqlResult) &&
            (identical(other.sqlColumn, sqlColumn) ||
                other.sqlColumn == sqlColumn) &&
            (identical(other.showRecord, showRecord) ||
                other.showRecord == showRecord) &&
            (identical(other.isRightPageOpen, isRightPageOpen) ||
                other.isRightPageOpen == isRightPageOpen));
  }

  @override
  int get hashCode => Object.hash(runtimeType, drawerPage, sqlResult, sqlColumn,
      showRecord, isRightPageOpen);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionDrawerModel(drawerPage: $drawerPage, sqlResult: $sqlResult, sqlColumn: $sqlColumn, showRecord: $showRecord, isRightPageOpen: $isRightPageOpen)';
  }
}

/// @nodoc
abstract mixin class _$SessionDrawerModelCopyWith<$Res>
    implements $SessionDrawerModelCopyWith<$Res> {
  factory _$SessionDrawerModelCopyWith(
          _SessionDrawerModel value, $Res Function(_SessionDrawerModel) _then) =
      __$SessionDrawerModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {DrawerPage drawerPage,
      BaseQueryValue? sqlResult,
      BaseQueryColumn? sqlColumn,
      bool showRecord,
      bool isRightPageOpen});
}

/// @nodoc
class __$SessionDrawerModelCopyWithImpl<$Res>
    implements _$SessionDrawerModelCopyWith<$Res> {
  __$SessionDrawerModelCopyWithImpl(this._self, this._then);

  final _SessionDrawerModel _self;
  final $Res Function(_SessionDrawerModel) _then;

  /// Create a copy of SessionDrawerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? drawerPage = null,
    Object? sqlResult = freezed,
    Object? sqlColumn = freezed,
    Object? showRecord = null,
    Object? isRightPageOpen = null,
  }) {
    return _then(_SessionDrawerModel(
      drawerPage: null == drawerPage
          ? _self.drawerPage
          : drawerPage // ignore: cast_nullable_to_non_nullable
              as DrawerPage,
      sqlResult: freezed == sqlResult
          ? _self.sqlResult
          : sqlResult // ignore: cast_nullable_to_non_nullable
              as BaseQueryValue?,
      sqlColumn: freezed == sqlColumn
          ? _self.sqlColumn
          : sqlColumn // ignore: cast_nullable_to_non_nullable
              as BaseQueryColumn?,
      showRecord: null == showRecord
          ? _self.showRecord
          : showRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      isRightPageOpen: null == isRightPageOpen
          ? _self.isRightPageOpen
          : isRightPageOpen // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$SessionSplitViewModel implements DiagnosticableTreeMixin {
  SplitViewController get multiSplitViewCtrl;
  SplitViewController get metaDataSplitViewCtrl;

  /// Create a copy of SessionSplitViewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionSplitViewModelCopyWith<SessionSplitViewModel> get copyWith =>
      _$SessionSplitViewModelCopyWithImpl<SessionSplitViewModel>(
          this as SessionSplitViewModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionSplitViewModel'))
      ..add(DiagnosticsProperty('multiSplitViewCtrl', multiSplitViewCtrl))
      ..add(
          DiagnosticsProperty('metaDataSplitViewCtrl', metaDataSplitViewCtrl));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionSplitViewModel &&
            (identical(other.multiSplitViewCtrl, multiSplitViewCtrl) ||
                other.multiSplitViewCtrl == multiSplitViewCtrl) &&
            (identical(other.metaDataSplitViewCtrl, metaDataSplitViewCtrl) ||
                other.metaDataSplitViewCtrl == metaDataSplitViewCtrl));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, multiSplitViewCtrl, metaDataSplitViewCtrl);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionSplitViewModel(multiSplitViewCtrl: $multiSplitViewCtrl, metaDataSplitViewCtrl: $metaDataSplitViewCtrl)';
  }
}

/// @nodoc
abstract mixin class $SessionSplitViewModelCopyWith<$Res> {
  factory $SessionSplitViewModelCopyWith(SessionSplitViewModel value,
          $Res Function(SessionSplitViewModel) _then) =
      _$SessionSplitViewModelCopyWithImpl;
  @useResult
  $Res call(
      {SplitViewController multiSplitViewCtrl,
      SplitViewController metaDataSplitViewCtrl});
}

/// @nodoc
class _$SessionSplitViewModelCopyWithImpl<$Res>
    implements $SessionSplitViewModelCopyWith<$Res> {
  _$SessionSplitViewModelCopyWithImpl(this._self, this._then);

  final SessionSplitViewModel _self;
  final $Res Function(SessionSplitViewModel) _then;

  /// Create a copy of SessionSplitViewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? multiSplitViewCtrl = null,
    Object? metaDataSplitViewCtrl = null,
  }) {
    return _then(_self.copyWith(
      multiSplitViewCtrl: null == multiSplitViewCtrl
          ? _self.multiSplitViewCtrl
          : multiSplitViewCtrl // ignore: cast_nullable_to_non_nullable
              as SplitViewController,
      metaDataSplitViewCtrl: null == metaDataSplitViewCtrl
          ? _self.metaDataSplitViewCtrl
          : metaDataSplitViewCtrl // ignore: cast_nullable_to_non_nullable
              as SplitViewController,
    ));
  }
}

/// @nodoc

class _SessionSplitViewModel
    with DiagnosticableTreeMixin
    implements SessionSplitViewModel {
  const _SessionSplitViewModel(
      {required this.multiSplitViewCtrl, required this.metaDataSplitViewCtrl});

  @override
  final SplitViewController multiSplitViewCtrl;
  @override
  final SplitViewController metaDataSplitViewCtrl;

  /// Create a copy of SessionSplitViewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionSplitViewModelCopyWith<_SessionSplitViewModel> get copyWith =>
      __$SessionSplitViewModelCopyWithImpl<_SessionSplitViewModel>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionSplitViewModel'))
      ..add(DiagnosticsProperty('multiSplitViewCtrl', multiSplitViewCtrl))
      ..add(
          DiagnosticsProperty('metaDataSplitViewCtrl', metaDataSplitViewCtrl));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionSplitViewModel &&
            (identical(other.multiSplitViewCtrl, multiSplitViewCtrl) ||
                other.multiSplitViewCtrl == multiSplitViewCtrl) &&
            (identical(other.metaDataSplitViewCtrl, metaDataSplitViewCtrl) ||
                other.metaDataSplitViewCtrl == metaDataSplitViewCtrl));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, multiSplitViewCtrl, metaDataSplitViewCtrl);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionSplitViewModel(multiSplitViewCtrl: $multiSplitViewCtrl, metaDataSplitViewCtrl: $metaDataSplitViewCtrl)';
  }
}

/// @nodoc
abstract mixin class _$SessionSplitViewModelCopyWith<$Res>
    implements $SessionSplitViewModelCopyWith<$Res> {
  factory _$SessionSplitViewModelCopyWith(_SessionSplitViewModel value,
          $Res Function(_SessionSplitViewModel) _then) =
      __$SessionSplitViewModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SplitViewController multiSplitViewCtrl,
      SplitViewController metaDataSplitViewCtrl});
}

/// @nodoc
class __$SessionSplitViewModelCopyWithImpl<$Res>
    implements _$SessionSplitViewModelCopyWith<$Res> {
  __$SessionSplitViewModelCopyWithImpl(this._self, this._then);

  final _SessionSplitViewModel _self;
  final $Res Function(_SessionSplitViewModel) _then;

  /// Create a copy of SessionSplitViewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? multiSplitViewCtrl = null,
    Object? metaDataSplitViewCtrl = null,
  }) {
    return _then(_SessionSplitViewModel(
      multiSplitViewCtrl: null == multiSplitViewCtrl
          ? _self.multiSplitViewCtrl
          : multiSplitViewCtrl // ignore: cast_nullable_to_non_nullable
              as SplitViewController,
      metaDataSplitViewCtrl: null == metaDataSplitViewCtrl
          ? _self.metaDataSplitViewCtrl
          : metaDataSplitViewCtrl // ignore: cast_nullable_to_non_nullable
              as SplitViewController,
    ));
  }
}

/// @nodoc
mixin _$SessionStatusModel implements DiagnosticableTreeMixin {
  SessionId get sessionId;
  String get instanceName; // sql result
  ResultId? get resultId;
  SQLExecuteState get state;
  Duration? get executeTime;
  BigInt? get affectedRows;
  String? get query;

  /// Create a copy of SessionStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionStatusModelCopyWith<SessionStatusModel> get copyWith =>
      _$SessionStatusModelCopyWithImpl<SessionStatusModel>(
          this as SessionStatusModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionStatusModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('instanceName', instanceName))
      ..add(DiagnosticsProperty('resultId', resultId))
      ..add(DiagnosticsProperty('state', state))
      ..add(DiagnosticsProperty('executeTime', executeTime))
      ..add(DiagnosticsProperty('affectedRows', affectedRows))
      ..add(DiagnosticsProperty('query', query));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionStatusModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.instanceName, instanceName) ||
                other.instanceName == instanceName) &&
            (identical(other.resultId, resultId) ||
                other.resultId == resultId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.executeTime, executeTime) ||
                other.executeTime == executeTime) &&
            (identical(other.affectedRows, affectedRows) ||
                other.affectedRows == affectedRows) &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, instanceName,
      resultId, state, executeTime, affectedRows, query);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionStatusModel(sessionId: $sessionId, instanceName: $instanceName, resultId: $resultId, state: $state, executeTime: $executeTime, affectedRows: $affectedRows, query: $query)';
  }
}

/// @nodoc
abstract mixin class $SessionStatusModelCopyWith<$Res> {
  factory $SessionStatusModelCopyWith(
          SessionStatusModel value, $Res Function(SessionStatusModel) _then) =
      _$SessionStatusModelCopyWithImpl;
  @useResult
  $Res call(
      {SessionId sessionId,
      String instanceName,
      ResultId? resultId,
      SQLExecuteState state,
      Duration? executeTime,
      BigInt? affectedRows,
      String? query});

  $SessionIdCopyWith<$Res> get sessionId;
  $ResultIdCopyWith<$Res>? get resultId;
}

/// @nodoc
class _$SessionStatusModelCopyWithImpl<$Res>
    implements $SessionStatusModelCopyWith<$Res> {
  _$SessionStatusModelCopyWithImpl(this._self, this._then);

  final SessionStatusModel _self;
  final $Res Function(SessionStatusModel) _then;

  /// Create a copy of SessionStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? instanceName = null,
    Object? resultId = freezed,
    Object? state = null,
    Object? executeTime = freezed,
    Object? affectedRows = freezed,
    Object? query = freezed,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as SessionId,
      instanceName: null == instanceName
          ? _self.instanceName
          : instanceName // ignore: cast_nullable_to_non_nullable
              as String,
      resultId: freezed == resultId
          ? _self.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as ResultId?,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as SQLExecuteState,
      executeTime: freezed == executeTime
          ? _self.executeTime
          : executeTime // ignore: cast_nullable_to_non_nullable
              as Duration?,
      affectedRows: freezed == affectedRows
          ? _self.affectedRows
          : affectedRows // ignore: cast_nullable_to_non_nullable
              as BigInt?,
      query: freezed == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of SessionStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionIdCopyWith<$Res> get sessionId {
    return $SessionIdCopyWith<$Res>(_self.sessionId, (value) {
      return _then(_self.copyWith(sessionId: value));
    });
  }

  /// Create a copy of SessionStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResultIdCopyWith<$Res>? get resultId {
    if (_self.resultId == null) {
      return null;
    }

    return $ResultIdCopyWith<$Res>(_self.resultId!, (value) {
      return _then(_self.copyWith(resultId: value));
    });
  }
}

/// @nodoc

class _SessionStatusModel
    with DiagnosticableTreeMixin
    implements SessionStatusModel {
  const _SessionStatusModel(
      {required this.sessionId,
      required this.instanceName,
      this.resultId,
      required this.state,
      this.executeTime,
      this.affectedRows,
      this.query});

  @override
  final SessionId sessionId;
  @override
  final String instanceName;
// sql result
  @override
  final ResultId? resultId;
  @override
  final SQLExecuteState state;
  @override
  final Duration? executeTime;
  @override
  final BigInt? affectedRows;
  @override
  final String? query;

  /// Create a copy of SessionStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionStatusModelCopyWith<_SessionStatusModel> get copyWith =>
      __$SessionStatusModelCopyWithImpl<_SessionStatusModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionStatusModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('instanceName', instanceName))
      ..add(DiagnosticsProperty('resultId', resultId))
      ..add(DiagnosticsProperty('state', state))
      ..add(DiagnosticsProperty('executeTime', executeTime))
      ..add(DiagnosticsProperty('affectedRows', affectedRows))
      ..add(DiagnosticsProperty('query', query));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionStatusModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.instanceName, instanceName) ||
                other.instanceName == instanceName) &&
            (identical(other.resultId, resultId) ||
                other.resultId == resultId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.executeTime, executeTime) ||
                other.executeTime == executeTime) &&
            (identical(other.affectedRows, affectedRows) ||
                other.affectedRows == affectedRows) &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, instanceName,
      resultId, state, executeTime, affectedRows, query);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionStatusModel(sessionId: $sessionId, instanceName: $instanceName, resultId: $resultId, state: $state, executeTime: $executeTime, affectedRows: $affectedRows, query: $query)';
  }
}

/// @nodoc
abstract mixin class _$SessionStatusModelCopyWith<$Res>
    implements $SessionStatusModelCopyWith<$Res> {
  factory _$SessionStatusModelCopyWith(
          _SessionStatusModel value, $Res Function(_SessionStatusModel) _then) =
      __$SessionStatusModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SessionId sessionId,
      String instanceName,
      ResultId? resultId,
      SQLExecuteState state,
      Duration? executeTime,
      BigInt? affectedRows,
      String? query});

  @override
  $SessionIdCopyWith<$Res> get sessionId;
  @override
  $ResultIdCopyWith<$Res>? get resultId;
}

/// @nodoc
class __$SessionStatusModelCopyWithImpl<$Res>
    implements _$SessionStatusModelCopyWith<$Res> {
  __$SessionStatusModelCopyWithImpl(this._self, this._then);

  final _SessionStatusModel _self;
  final $Res Function(_SessionStatusModel) _then;

  /// Create a copy of SessionStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? instanceName = null,
    Object? resultId = freezed,
    Object? state = null,
    Object? executeTime = freezed,
    Object? affectedRows = freezed,
    Object? query = freezed,
  }) {
    return _then(_SessionStatusModel(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as SessionId,
      instanceName: null == instanceName
          ? _self.instanceName
          : instanceName // ignore: cast_nullable_to_non_nullable
              as String,
      resultId: freezed == resultId
          ? _self.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as ResultId?,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as SQLExecuteState,
      executeTime: freezed == executeTime
          ? _self.executeTime
          : executeTime // ignore: cast_nullable_to_non_nullable
              as Duration?,
      affectedRows: freezed == affectedRows
          ? _self.affectedRows
          : affectedRows // ignore: cast_nullable_to_non_nullable
              as BigInt?,
      query: freezed == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of SessionStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionIdCopyWith<$Res> get sessionId {
    return $SessionIdCopyWith<$Res>(_self.sessionId, (value) {
      return _then(_self.copyWith(sessionId: value));
    });
  }

  /// Create a copy of SessionStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResultIdCopyWith<$Res>? get resultId {
    if (_self.resultId == null) {
      return null;
    }

    return $ResultIdCopyWith<$Res>(_self.resultId!, (value) {
      return _then(_self.copyWith(resultId: value));
    });
  }
}

/// @nodoc
mixin _$SessionSQLEditorModel implements DiagnosticableTreeMixin {
  String? get currentSchema;
  MetaDataNode? get metadata;

  /// Create a copy of SessionSQLEditorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionSQLEditorModelCopyWith<SessionSQLEditorModel> get copyWith =>
      _$SessionSQLEditorModelCopyWithImpl<SessionSQLEditorModel>(
          this as SessionSQLEditorModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionSQLEditorModel'))
      ..add(DiagnosticsProperty('currentSchema', currentSchema))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionSQLEditorModel &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentSchema, metadata);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionSQLEditorModel(currentSchema: $currentSchema, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $SessionSQLEditorModelCopyWith<$Res> {
  factory $SessionSQLEditorModelCopyWith(SessionSQLEditorModel value,
          $Res Function(SessionSQLEditorModel) _then) =
      _$SessionSQLEditorModelCopyWithImpl;
  @useResult
  $Res call({String? currentSchema, MetaDataNode? metadata});
}

/// @nodoc
class _$SessionSQLEditorModelCopyWithImpl<$Res>
    implements $SessionSQLEditorModelCopyWith<$Res> {
  _$SessionSQLEditorModelCopyWithImpl(this._self, this._then);

  final SessionSQLEditorModel _self;
  final $Res Function(SessionSQLEditorModel) _then;

  /// Create a copy of SessionSQLEditorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentSchema = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_self.copyWith(
      currentSchema: freezed == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as MetaDataNode?,
    ));
  }
}

/// @nodoc

class _SessionSQLEditorModel
    with DiagnosticableTreeMixin
    implements SessionSQLEditorModel {
  const _SessionSQLEditorModel({this.currentSchema, this.metadata});

  @override
  final String? currentSchema;
  @override
  final MetaDataNode? metadata;

  /// Create a copy of SessionSQLEditorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionSQLEditorModelCopyWith<_SessionSQLEditorModel> get copyWith =>
      __$SessionSQLEditorModelCopyWithImpl<_SessionSQLEditorModel>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionSQLEditorModel'))
      ..add(DiagnosticsProperty('currentSchema', currentSchema))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionSQLEditorModel &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentSchema, metadata);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionSQLEditorModel(currentSchema: $currentSchema, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$SessionSQLEditorModelCopyWith<$Res>
    implements $SessionSQLEditorModelCopyWith<$Res> {
  factory _$SessionSQLEditorModelCopyWith(_SessionSQLEditorModel value,
          $Res Function(_SessionSQLEditorModel) _then) =
      __$SessionSQLEditorModelCopyWithImpl;
  @override
  @useResult
  $Res call({String? currentSchema, MetaDataNode? metadata});
}

/// @nodoc
class __$SessionSQLEditorModelCopyWithImpl<$Res>
    implements _$SessionSQLEditorModelCopyWith<$Res> {
  __$SessionSQLEditorModelCopyWithImpl(this._self, this._then);

  final _SessionSQLEditorModel _self;
  final $Res Function(_SessionSQLEditorModel) _then;

  /// Create a copy of SessionSQLEditorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? currentSchema = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_SessionSQLEditorModel(
      currentSchema: freezed == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as MetaDataNode?,
    ));
  }
}

/// @nodoc
mixin _$ConnId implements DiagnosticableTreeMixin {
  int get value;

  /// Create a copy of ConnId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ConnIdCopyWith<ConnId> get copyWith =>
      _$ConnIdCopyWithImpl<ConnId>(this as ConnId, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ConnId'))
      ..add(DiagnosticsProperty('value', value));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ConnId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ConnId(value: $value)';
  }
}

/// @nodoc
abstract mixin class $ConnIdCopyWith<$Res> {
  factory $ConnIdCopyWith(ConnId value, $Res Function(ConnId) _then) =
      _$ConnIdCopyWithImpl;
  @useResult
  $Res call({int value});
}

/// @nodoc
class _$ConnIdCopyWithImpl<$Res> implements $ConnIdCopyWith<$Res> {
  _$ConnIdCopyWithImpl(this._self, this._then);

  final ConnId _self;
  final $Res Function(ConnId) _then;

  /// Create a copy of ConnId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_self.copyWith(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _ConnId with DiagnosticableTreeMixin implements ConnId {
  const _ConnId({required this.value});

  @override
  final int value;

  /// Create a copy of ConnId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ConnIdCopyWith<_ConnId> get copyWith =>
      __$ConnIdCopyWithImpl<_ConnId>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ConnId'))
      ..add(DiagnosticsProperty('value', value));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ConnId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ConnId(value: $value)';
  }
}

/// @nodoc
abstract mixin class _$ConnIdCopyWith<$Res> implements $ConnIdCopyWith<$Res> {
  factory _$ConnIdCopyWith(_ConnId value, $Res Function(_ConnId) _then) =
      __$ConnIdCopyWithImpl;
  @override
  @useResult
  $Res call({int value});
}

/// @nodoc
class __$ConnIdCopyWithImpl<$Res> implements _$ConnIdCopyWith<$Res> {
  __$ConnIdCopyWithImpl(this._self, this._then);

  final _ConnId _self;
  final $Res Function(_ConnId) _then;

  /// Create a copy of ConnId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
  }) {
    return _then(_ConnId(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$SessionConnModel implements DiagnosticableTreeMixin {
  ConnId get connId;
  InstanceId get instanceId;
  bool get canQuery;

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionConnModelCopyWith<SessionConnModel> get copyWith =>
      _$SessionConnModelCopyWithImpl<SessionConnModel>(
          this as SessionConnModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionConnModel'))
      ..add(DiagnosticsProperty('connId', connId))
      ..add(DiagnosticsProperty('instanceId', instanceId))
      ..add(DiagnosticsProperty('canQuery', canQuery));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionConnModel &&
            (identical(other.connId, connId) || other.connId == connId) &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.canQuery, canQuery) ||
                other.canQuery == canQuery));
  }

  @override
  int get hashCode => Object.hash(runtimeType, connId, instanceId, canQuery);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionConnModel(connId: $connId, instanceId: $instanceId, canQuery: $canQuery)';
  }
}

/// @nodoc
abstract mixin class $SessionConnModelCopyWith<$Res> {
  factory $SessionConnModelCopyWith(
          SessionConnModel value, $Res Function(SessionConnModel) _then) =
      _$SessionConnModelCopyWithImpl;
  @useResult
  $Res call({ConnId connId, InstanceId instanceId, bool canQuery});

  $ConnIdCopyWith<$Res> get connId;
  $InstanceIdCopyWith<$Res> get instanceId;
}

/// @nodoc
class _$SessionConnModelCopyWithImpl<$Res>
    implements $SessionConnModelCopyWith<$Res> {
  _$SessionConnModelCopyWithImpl(this._self, this._then);

  final SessionConnModel _self;
  final $Res Function(SessionConnModel) _then;

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connId = null,
    Object? instanceId = null,
    Object? canQuery = null,
  }) {
    return _then(_self.copyWith(
      connId: null == connId
          ? _self.connId
          : connId // ignore: cast_nullable_to_non_nullable
              as ConnId,
      instanceId: null == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as InstanceId,
      canQuery: null == canQuery
          ? _self.canQuery
          : canQuery // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConnIdCopyWith<$Res> get connId {
    return $ConnIdCopyWith<$Res>(_self.connId, (value) {
      return _then(_self.copyWith(connId: value));
    });
  }

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<$Res> get instanceId {
    return $InstanceIdCopyWith<$Res>(_self.instanceId, (value) {
      return _then(_self.copyWith(instanceId: value));
    });
  }
}

/// @nodoc

class _SessionConnModel
    with DiagnosticableTreeMixin
    implements SessionConnModel {
  const _SessionConnModel(
      {required this.connId, required this.instanceId, required this.canQuery});

  @override
  final ConnId connId;
  @override
  final InstanceId instanceId;
  @override
  final bool canQuery;

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionConnModelCopyWith<_SessionConnModel> get copyWith =>
      __$SessionConnModelCopyWithImpl<_SessionConnModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionConnModel'))
      ..add(DiagnosticsProperty('connId', connId))
      ..add(DiagnosticsProperty('instanceId', instanceId))
      ..add(DiagnosticsProperty('canQuery', canQuery));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionConnModel &&
            (identical(other.connId, connId) || other.connId == connId) &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.canQuery, canQuery) ||
                other.canQuery == canQuery));
  }

  @override
  int get hashCode => Object.hash(runtimeType, connId, instanceId, canQuery);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionConnModel(connId: $connId, instanceId: $instanceId, canQuery: $canQuery)';
  }
}

/// @nodoc
abstract mixin class _$SessionConnModelCopyWith<$Res>
    implements $SessionConnModelCopyWith<$Res> {
  factory _$SessionConnModelCopyWith(
          _SessionConnModel value, $Res Function(_SessionConnModel) _then) =
      __$SessionConnModelCopyWithImpl;
  @override
  @useResult
  $Res call({ConnId connId, InstanceId instanceId, bool canQuery});

  @override
  $ConnIdCopyWith<$Res> get connId;
  @override
  $InstanceIdCopyWith<$Res> get instanceId;
}

/// @nodoc
class __$SessionConnModelCopyWithImpl<$Res>
    implements _$SessionConnModelCopyWith<$Res> {
  __$SessionConnModelCopyWithImpl(this._self, this._then);

  final _SessionConnModel _self;
  final $Res Function(_SessionConnModel) _then;

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? connId = null,
    Object? instanceId = null,
    Object? canQuery = null,
  }) {
    return _then(_SessionConnModel(
      connId: null == connId
          ? _self.connId
          : connId // ignore: cast_nullable_to_non_nullable
              as ConnId,
      instanceId: null == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as InstanceId,
      canQuery: null == canQuery
          ? _self.canQuery
          : canQuery // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConnIdCopyWith<$Res> get connId {
    return $ConnIdCopyWith<$Res>(_self.connId, (value) {
      return _then(_self.copyWith(connId: value));
    });
  }

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<$Res> get instanceId {
    return $InstanceIdCopyWith<$Res>(_self.instanceId, (value) {
      return _then(_self.copyWith(instanceId: value));
    });
  }
}

/// @nodoc
mixin _$ResultId implements DiagnosticableTreeMixin {
  SessionId get sessionId;
  int get value;

  /// Create a copy of ResultId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ResultIdCopyWith<ResultId> get copyWith =>
      _$ResultIdCopyWithImpl<ResultId>(this as ResultId, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ResultId'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('value', value));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ResultId &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, value);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ResultId(sessionId: $sessionId, value: $value)';
  }
}

/// @nodoc
abstract mixin class $ResultIdCopyWith<$Res> {
  factory $ResultIdCopyWith(ResultId value, $Res Function(ResultId) _then) =
      _$ResultIdCopyWithImpl;
  @useResult
  $Res call({SessionId sessionId, int value});

  $SessionIdCopyWith<$Res> get sessionId;
}

/// @nodoc
class _$ResultIdCopyWithImpl<$Res> implements $ResultIdCopyWith<$Res> {
  _$ResultIdCopyWithImpl(this._self, this._then);

  final ResultId _self;
  final $Res Function(ResultId) _then;

  /// Create a copy of ResultId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? value = null,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as SessionId,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of ResultId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionIdCopyWith<$Res> get sessionId {
    return $SessionIdCopyWith<$Res>(_self.sessionId, (value) {
      return _then(_self.copyWith(sessionId: value));
    });
  }
}

/// @nodoc

class _ResultId with DiagnosticableTreeMixin implements ResultId {
  const _ResultId({required this.sessionId, required this.value});

  @override
  final SessionId sessionId;
  @override
  final int value;

  /// Create a copy of ResultId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ResultIdCopyWith<_ResultId> get copyWith =>
      __$ResultIdCopyWithImpl<_ResultId>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ResultId'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('value', value));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ResultId &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, value);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ResultId(sessionId: $sessionId, value: $value)';
  }
}

/// @nodoc
abstract mixin class _$ResultIdCopyWith<$Res>
    implements $ResultIdCopyWith<$Res> {
  factory _$ResultIdCopyWith(_ResultId value, $Res Function(_ResultId) _then) =
      __$ResultIdCopyWithImpl;
  @override
  @useResult
  $Res call({SessionId sessionId, int value});

  @override
  $SessionIdCopyWith<$Res> get sessionId;
}

/// @nodoc
class __$ResultIdCopyWithImpl<$Res> implements _$ResultIdCopyWith<$Res> {
  __$ResultIdCopyWithImpl(this._self, this._then);

  final _ResultId _self;
  final $Res Function(_ResultId) _then;

  /// Create a copy of ResultId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? value = null,
  }) {
    return _then(_ResultId(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as SessionId,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of ResultId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionIdCopyWith<$Res> get sessionId {
    return $SessionIdCopyWith<$Res>(_self.sessionId, (value) {
      return _then(_self.copyWith(sessionId: value));
    });
  }
}

/// @nodoc
mixin _$SQLResultModel implements DiagnosticableTreeMixin {
  ResultId get resultId;
  SQLExecuteState get state;
  String? get query;
  Duration? get executeTime;
  String? get error;
  BaseQueryResult? get data;

  /// Create a copy of SQLResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SQLResultModelCopyWith<SQLResultModel> get copyWith =>
      _$SQLResultModelCopyWithImpl<SQLResultModel>(
          this as SQLResultModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SQLResultModel'))
      ..add(DiagnosticsProperty('resultId', resultId))
      ..add(DiagnosticsProperty('state', state))
      ..add(DiagnosticsProperty('query', query))
      ..add(DiagnosticsProperty('executeTime', executeTime))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SQLResultModel &&
            (identical(other.resultId, resultId) ||
                other.resultId == resultId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.executeTime, executeTime) ||
                other.executeTime == executeTime) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, resultId, state, query, executeTime, error, data);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SQLResultModel(resultId: $resultId, state: $state, query: $query, executeTime: $executeTime, error: $error, data: $data)';
  }
}

/// @nodoc
abstract mixin class $SQLResultModelCopyWith<$Res> {
  factory $SQLResultModelCopyWith(
          SQLResultModel value, $Res Function(SQLResultModel) _then) =
      _$SQLResultModelCopyWithImpl;
  @useResult
  $Res call(
      {ResultId resultId,
      SQLExecuteState state,
      String? query,
      Duration? executeTime,
      String? error,
      BaseQueryResult? data});

  $ResultIdCopyWith<$Res> get resultId;
}

/// @nodoc
class _$SQLResultModelCopyWithImpl<$Res>
    implements $SQLResultModelCopyWith<$Res> {
  _$SQLResultModelCopyWithImpl(this._self, this._then);

  final SQLResultModel _self;
  final $Res Function(SQLResultModel) _then;

  /// Create a copy of SQLResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resultId = null,
    Object? state = null,
    Object? query = freezed,
    Object? executeTime = freezed,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_self.copyWith(
      resultId: null == resultId
          ? _self.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as ResultId,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as SQLExecuteState,
      query: freezed == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
      executeTime: freezed == executeTime
          ? _self.executeTime
          : executeTime // ignore: cast_nullable_to_non_nullable
              as Duration?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as BaseQueryResult?,
    ));
  }

  /// Create a copy of SQLResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResultIdCopyWith<$Res> get resultId {
    return $ResultIdCopyWith<$Res>(_self.resultId, (value) {
      return _then(_self.copyWith(resultId: value));
    });
  }
}

/// @nodoc

class _SQLResultModel with DiagnosticableTreeMixin implements SQLResultModel {
  const _SQLResultModel(
      {required this.resultId,
      required this.state,
      this.query,
      this.executeTime,
      this.error,
      this.data});

  @override
  final ResultId resultId;
  @override
  final SQLExecuteState state;
  @override
  final String? query;
  @override
  final Duration? executeTime;
  @override
  final String? error;
  @override
  final BaseQueryResult? data;

  /// Create a copy of SQLResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SQLResultModelCopyWith<_SQLResultModel> get copyWith =>
      __$SQLResultModelCopyWithImpl<_SQLResultModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SQLResultModel'))
      ..add(DiagnosticsProperty('resultId', resultId))
      ..add(DiagnosticsProperty('state', state))
      ..add(DiagnosticsProperty('query', query))
      ..add(DiagnosticsProperty('executeTime', executeTime))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SQLResultModel &&
            (identical(other.resultId, resultId) ||
                other.resultId == resultId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.executeTime, executeTime) ||
                other.executeTime == executeTime) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, resultId, state, query, executeTime, error, data);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SQLResultModel(resultId: $resultId, state: $state, query: $query, executeTime: $executeTime, error: $error, data: $data)';
  }
}

/// @nodoc
abstract mixin class _$SQLResultModelCopyWith<$Res>
    implements $SQLResultModelCopyWith<$Res> {
  factory _$SQLResultModelCopyWith(
          _SQLResultModel value, $Res Function(_SQLResultModel) _then) =
      __$SQLResultModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {ResultId resultId,
      SQLExecuteState state,
      String? query,
      Duration? executeTime,
      String? error,
      BaseQueryResult? data});

  @override
  $ResultIdCopyWith<$Res> get resultId;
}

/// @nodoc
class __$SQLResultModelCopyWithImpl<$Res>
    implements _$SQLResultModelCopyWith<$Res> {
  __$SQLResultModelCopyWithImpl(this._self, this._then);

  final _SQLResultModel _self;
  final $Res Function(_SQLResultModel) _then;

  /// Create a copy of SQLResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? resultId = null,
    Object? state = null,
    Object? query = freezed,
    Object? executeTime = freezed,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_SQLResultModel(
      resultId: null == resultId
          ? _self.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as ResultId,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as SQLExecuteState,
      query: freezed == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
      executeTime: freezed == executeTime
          ? _self.executeTime
          : executeTime // ignore: cast_nullable_to_non_nullable
              as Duration?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as BaseQueryResult?,
    ));
  }

  /// Create a copy of SQLResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResultIdCopyWith<$Res> get resultId {
    return $ResultIdCopyWith<$Res>(_self.resultId, (value) {
      return _then(_self.copyWith(resultId: value));
    });
  }
}

/// @nodoc
mixin _$SQLResultListModel implements DiagnosticableTreeMixin {
  SessionId get sessionId;
  List<SQLResultModel> get results;
  SQLResultModel? get selected;

  /// Create a copy of SQLResultListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SQLResultListModelCopyWith<SQLResultListModel> get copyWith =>
      _$SQLResultListModelCopyWithImpl<SQLResultListModel>(
          this as SQLResultListModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SQLResultListModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('results', results))
      ..add(DiagnosticsProperty('selected', selected));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SQLResultListModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality().equals(other.results, results) &&
            (identical(other.selected, selected) ||
                other.selected == selected));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId,
      const DeepCollectionEquality().hash(results), selected);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SQLResultListModel(sessionId: $sessionId, results: $results, selected: $selected)';
  }
}

/// @nodoc
abstract mixin class $SQLResultListModelCopyWith<$Res> {
  factory $SQLResultListModelCopyWith(
          SQLResultListModel value, $Res Function(SQLResultListModel) _then) =
      _$SQLResultListModelCopyWithImpl;
  @useResult
  $Res call(
      {SessionId sessionId,
      List<SQLResultModel> results,
      SQLResultModel? selected});

  $SessionIdCopyWith<$Res> get sessionId;
  $SQLResultModelCopyWith<$Res>? get selected;
}

/// @nodoc
class _$SQLResultListModelCopyWithImpl<$Res>
    implements $SQLResultListModelCopyWith<$Res> {
  _$SQLResultListModelCopyWithImpl(this._self, this._then);

  final SQLResultListModel _self;
  final $Res Function(SQLResultListModel) _then;

  /// Create a copy of SQLResultListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? results = null,
    Object? selected = freezed,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as SessionId,
      results: null == results
          ? _self.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<SQLResultModel>,
      selected: freezed == selected
          ? _self.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as SQLResultModel?,
    ));
  }

  /// Create a copy of SQLResultListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionIdCopyWith<$Res> get sessionId {
    return $SessionIdCopyWith<$Res>(_self.sessionId, (value) {
      return _then(_self.copyWith(sessionId: value));
    });
  }

  /// Create a copy of SQLResultListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SQLResultModelCopyWith<$Res>? get selected {
    if (_self.selected == null) {
      return null;
    }

    return $SQLResultModelCopyWith<$Res>(_self.selected!, (value) {
      return _then(_self.copyWith(selected: value));
    });
  }
}

/// @nodoc

class _SQLResultListModel
    with DiagnosticableTreeMixin
    implements SQLResultListModel {
  const _SQLResultListModel(
      {required this.sessionId,
      required final List<SQLResultModel> results,
      this.selected})
      : _results = results;

  @override
  final SessionId sessionId;
  final List<SQLResultModel> _results;
  @override
  List<SQLResultModel> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  final SQLResultModel? selected;

  /// Create a copy of SQLResultListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SQLResultListModelCopyWith<_SQLResultListModel> get copyWith =>
      __$SQLResultListModelCopyWithImpl<_SQLResultListModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SQLResultListModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('results', results))
      ..add(DiagnosticsProperty('selected', selected));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SQLResultListModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.selected, selected) ||
                other.selected == selected));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId,
      const DeepCollectionEquality().hash(_results), selected);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SQLResultListModel(sessionId: $sessionId, results: $results, selected: $selected)';
  }
}

/// @nodoc
abstract mixin class _$SQLResultListModelCopyWith<$Res>
    implements $SQLResultListModelCopyWith<$Res> {
  factory _$SQLResultListModelCopyWith(
          _SQLResultListModel value, $Res Function(_SQLResultListModel) _then) =
      __$SQLResultListModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SessionId sessionId,
      List<SQLResultModel> results,
      SQLResultModel? selected});

  @override
  $SessionIdCopyWith<$Res> get sessionId;
  @override
  $SQLResultModelCopyWith<$Res>? get selected;
}

/// @nodoc
class __$SQLResultListModelCopyWithImpl<$Res>
    implements _$SQLResultListModelCopyWith<$Res> {
  __$SQLResultListModelCopyWithImpl(this._self, this._then);

  final _SQLResultListModel _self;
  final $Res Function(_SQLResultListModel) _then;

  /// Create a copy of SQLResultListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? results = null,
    Object? selected = freezed,
  }) {
    return _then(_SQLResultListModel(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as SessionId,
      results: null == results
          ? _self._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<SQLResultModel>,
      selected: freezed == selected
          ? _self.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as SQLResultModel?,
    ));
  }

  /// Create a copy of SQLResultListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionIdCopyWith<$Res> get sessionId {
    return $SessionIdCopyWith<$Res>(_self.sessionId, (value) {
      return _then(_self.copyWith(sessionId: value));
    });
  }

  /// Create a copy of SQLResultListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SQLResultModelCopyWith<$Res>? get selected {
    if (_self.selected == null) {
      return null;
    }

    return $SQLResultModelCopyWith<$Res>(_self.selected!, (value) {
      return _then(_self.copyWith(selected: value));
    });
  }
}

// dart format on
