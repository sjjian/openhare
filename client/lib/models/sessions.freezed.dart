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
  int get sessionId;
  String get instanceName; // sql result
  int? get resultId;
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
      {int sessionId,
      String instanceName,
      int? resultId,
      SQLExecuteState state,
      Duration? executeTime,
      BigInt? affectedRows,
      String? query});
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
              as int,
      instanceName: null == instanceName
          ? _self.instanceName
          : instanceName // ignore: cast_nullable_to_non_nullable
              as String,
      resultId: freezed == resultId
          ? _self.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as int?,
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
  final int sessionId;
  @override
  final String instanceName;
// sql result
  @override
  final int? resultId;
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
      {int sessionId,
      String instanceName,
      int? resultId,
      SQLExecuteState state,
      Duration? executeTime,
      BigInt? affectedRows,
      String? query});
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
              as int,
      instanceName: null == instanceName
          ? _self.instanceName
          : instanceName // ignore: cast_nullable_to_non_nullable
              as String,
      resultId: freezed == resultId
          ? _self.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as int?,
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
}

// dart format on
