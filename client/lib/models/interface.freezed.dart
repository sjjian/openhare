// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interface.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionTabs implements DiagnosticableTreeMixin {
  String get firstName;
  String get lastName;
  int get age;

  /// Create a copy of SessionTabs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionTabsCopyWith<SessionTabs> get copyWith =>
      _$SessionTabsCopyWithImpl<SessionTabs>(this as SessionTabs, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionTabs'))
      ..add(DiagnosticsProperty('firstName', firstName))
      ..add(DiagnosticsProperty('lastName', lastName))
      ..add(DiagnosticsProperty('age', age));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionTabs &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.age, age) || other.age == age));
  }

  @override
  int get hashCode => Object.hash(runtimeType, firstName, lastName, age);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionTabs(firstName: $firstName, lastName: $lastName, age: $age)';
  }
}

/// @nodoc
abstract mixin class $SessionTabsCopyWith<$Res> {
  factory $SessionTabsCopyWith(
          SessionTabs value, $Res Function(SessionTabs) _then) =
      _$SessionTabsCopyWithImpl;
  @useResult
  $Res call({String firstName, String lastName, int age});
}

/// @nodoc
class _$SessionTabsCopyWithImpl<$Res> implements $SessionTabsCopyWith<$Res> {
  _$SessionTabsCopyWithImpl(this._self, this._then);

  final SessionTabs _self;
  final $Res Function(SessionTabs) _then;

  /// Create a copy of SessionTabs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? age = null,
  }) {
    return _then(_self.copyWith(
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _self.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _SessionTabs with DiagnosticableTreeMixin implements SessionTabs {
  const _SessionTabs(
      {required this.firstName, required this.lastName, required this.age});

  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final int age;

  /// Create a copy of SessionTabs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionTabsCopyWith<_SessionTabs> get copyWith =>
      __$SessionTabsCopyWithImpl<_SessionTabs>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionTabs'))
      ..add(DiagnosticsProperty('firstName', firstName))
      ..add(DiagnosticsProperty('lastName', lastName))
      ..add(DiagnosticsProperty('age', age));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionTabs &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.age, age) || other.age == age));
  }

  @override
  int get hashCode => Object.hash(runtimeType, firstName, lastName, age);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionTabs(firstName: $firstName, lastName: $lastName, age: $age)';
  }
}

/// @nodoc
abstract mixin class _$SessionTabsCopyWith<$Res>
    implements $SessionTabsCopyWith<$Res> {
  factory _$SessionTabsCopyWith(
          _SessionTabs value, $Res Function(_SessionTabs) _then) =
      __$SessionTabsCopyWithImpl;
  @override
  @useResult
  $Res call({String firstName, String lastName, int age});
}

/// @nodoc
class __$SessionTabsCopyWithImpl<$Res> implements _$SessionTabsCopyWith<$Res> {
  __$SessionTabsCopyWithImpl(this._self, this._then);

  final _SessionTabs _self;
  final $Res Function(_SessionTabs) _then;

  /// Create a copy of SessionTabs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? age = null,
  }) {
    return _then(_SessionTabs(
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _self.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$SessionStatus implements DiagnosticableTreeMixin {
  MetaDataNode? get metadata;
  TreeController<DataNode>? get metadataController;

  /// Create a copy of SessionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionStatusCopyWith<SessionStatus> get copyWith =>
      _$SessionStatusCopyWithImpl<SessionStatus>(
          this as SessionStatus, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionStatus'))
      ..add(DiagnosticsProperty('metadata', metadata))
      ..add(DiagnosticsProperty('metadataController', metadataController));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionStatus &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.metadataController, metadataController) ||
                other.metadataController == metadataController));
  }

  @override
  int get hashCode => Object.hash(runtimeType, metadata, metadataController);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionStatus(metadata: $metadata, metadataController: $metadataController)';
  }
}

/// @nodoc
abstract mixin class $SessionStatusCopyWith<$Res> {
  factory $SessionStatusCopyWith(
          SessionStatus value, $Res Function(SessionStatus) _then) =
      _$SessionStatusCopyWithImpl;
  @useResult
  $Res call(
      {MetaDataNode? metadata, TreeController<DataNode>? metadataController});
}

/// @nodoc
class _$SessionStatusCopyWithImpl<$Res>
    implements $SessionStatusCopyWith<$Res> {
  _$SessionStatusCopyWithImpl(this._self, this._then);

  final SessionStatus _self;
  final $Res Function(SessionStatus) _then;

  /// Create a copy of SessionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metadata = freezed,
    Object? metadataController = freezed,
  }) {
    return _then(_self.copyWith(
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as MetaDataNode?,
      metadataController: freezed == metadataController
          ? _self.metadataController
          : metadataController // ignore: cast_nullable_to_non_nullable
              as TreeController<DataNode>?,
    ));
  }
}

/// @nodoc

class _SessionStatus with DiagnosticableTreeMixin implements SessionStatus {
  const _SessionStatus({this.metadata, this.metadataController});

  @override
  final MetaDataNode? metadata;
  @override
  final TreeController<DataNode>? metadataController;

  /// Create a copy of SessionStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionStatusCopyWith<_SessionStatus> get copyWith =>
      __$SessionStatusCopyWithImpl<_SessionStatus>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionStatus'))
      ..add(DiagnosticsProperty('metadata', metadata))
      ..add(DiagnosticsProperty('metadataController', metadataController));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionStatus &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.metadataController, metadataController) ||
                other.metadataController == metadataController));
  }

  @override
  int get hashCode => Object.hash(runtimeType, metadata, metadataController);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionStatus(metadata: $metadata, metadataController: $metadataController)';
  }
}

/// @nodoc
abstract mixin class _$SessionStatusCopyWith<$Res>
    implements $SessionStatusCopyWith<$Res> {
  factory _$SessionStatusCopyWith(
          _SessionStatus value, $Res Function(_SessionStatus) _then) =
      __$SessionStatusCopyWithImpl;
  @override
  @useResult
  $Res call(
      {MetaDataNode? metadata, TreeController<DataNode>? metadataController});
}

/// @nodoc
class __$SessionStatusCopyWithImpl<$Res>
    implements _$SessionStatusCopyWith<$Res> {
  __$SessionStatusCopyWithImpl(this._self, this._then);

  final _SessionStatus _self;
  final $Res Function(_SessionStatus) _then;

  /// Create a copy of SessionStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? metadata = freezed,
    Object? metadataController = freezed,
  }) {
    return _then(_SessionStatus(
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as MetaDataNode?,
      metadataController: freezed == metadataController
          ? _self.metadataController
          : metadataController // ignore: cast_nullable_to_non_nullable
              as TreeController<DataNode>?,
    ));
  }
}

/// @nodoc
mixin _$CurrentSession implements DiagnosticableTreeMixin {
  SessionStorage get model;
  BaseConnection? get conn2;
  SQLConnectState get state;
  String? get text;
  String? get currentSchema;

  /// Create a copy of CurrentSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CurrentSessionCopyWith<CurrentSession> get copyWith =>
      _$CurrentSessionCopyWithImpl<CurrentSession>(
          this as CurrentSession, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSession'))
      ..add(DiagnosticsProperty('model', model))
      ..add(DiagnosticsProperty('conn2', conn2))
      ..add(DiagnosticsProperty('state', state))
      ..add(DiagnosticsProperty('text', text))
      ..add(DiagnosticsProperty('currentSchema', currentSchema));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CurrentSession &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.conn2, conn2) || other.conn2 == conn2) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, model, conn2, state, text, currentSchema);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSession(model: $model, conn2: $conn2, state: $state, text: $text, currentSchema: $currentSchema)';
  }
}

/// @nodoc
abstract mixin class $CurrentSessionCopyWith<$Res> {
  factory $CurrentSessionCopyWith(
          CurrentSession value, $Res Function(CurrentSession) _then) =
      _$CurrentSessionCopyWithImpl;
  @useResult
  $Res call(
      {SessionStorage model,
      BaseConnection? conn2,
      SQLConnectState state,
      String? text,
      String? currentSchema});
}

/// @nodoc
class _$CurrentSessionCopyWithImpl<$Res>
    implements $CurrentSessionCopyWith<$Res> {
  _$CurrentSessionCopyWithImpl(this._self, this._then);

  final CurrentSession _self;
  final $Res Function(CurrentSession) _then;

  /// Create a copy of CurrentSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = null,
    Object? conn2 = freezed,
    Object? state = null,
    Object? text = freezed,
    Object? currentSchema = freezed,
  }) {
    return _then(_self.copyWith(
      model: null == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as SessionStorage,
      conn2: freezed == conn2
          ? _self.conn2
          : conn2 // ignore: cast_nullable_to_non_nullable
              as BaseConnection?,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as SQLConnectState,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      currentSchema: freezed == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _CurrentSession with DiagnosticableTreeMixin implements CurrentSession {
  const _CurrentSession(
      {required this.model,
      this.conn2,
      required this.state,
      this.text,
      this.currentSchema});

  @override
  final SessionStorage model;
  @override
  final BaseConnection? conn2;
  @override
  final SQLConnectState state;
  @override
  final String? text;
  @override
  final String? currentSchema;

  /// Create a copy of CurrentSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CurrentSessionCopyWith<_CurrentSession> get copyWith =>
      __$CurrentSessionCopyWithImpl<_CurrentSession>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSession'))
      ..add(DiagnosticsProperty('model', model))
      ..add(DiagnosticsProperty('conn2', conn2))
      ..add(DiagnosticsProperty('state', state))
      ..add(DiagnosticsProperty('text', text))
      ..add(DiagnosticsProperty('currentSchema', currentSchema));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CurrentSession &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.conn2, conn2) || other.conn2 == conn2) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, model, conn2, state, text, currentSchema);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSession(model: $model, conn2: $conn2, state: $state, text: $text, currentSchema: $currentSchema)';
  }
}

/// @nodoc
abstract mixin class _$CurrentSessionCopyWith<$Res>
    implements $CurrentSessionCopyWith<$Res> {
  factory _$CurrentSessionCopyWith(
          _CurrentSession value, $Res Function(_CurrentSession) _then) =
      __$CurrentSessionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SessionStorage model,
      BaseConnection? conn2,
      SQLConnectState state,
      String? text,
      String? currentSchema});
}

/// @nodoc
class __$CurrentSessionCopyWithImpl<$Res>
    implements _$CurrentSessionCopyWith<$Res> {
  __$CurrentSessionCopyWithImpl(this._self, this._then);

  final _CurrentSession _self;
  final $Res Function(_CurrentSession) _then;

  /// Create a copy of CurrentSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? model = null,
    Object? conn2 = freezed,
    Object? state = null,
    Object? text = freezed,
    Object? currentSchema = freezed,
  }) {
    return _then(_CurrentSession(
      model: null == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as SessionStorage,
      conn2: freezed == conn2
          ? _self.conn2
          : conn2 // ignore: cast_nullable_to_non_nullable
              as BaseConnection?,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as SQLConnectState,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      currentSchema: freezed == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$SessionConn implements DiagnosticableTreeMixin {
  SessionStorage get model;
  BaseConnection? get conn2;
  SQLConnectState get state;
  String? get currentSchema;

  /// Create a copy of SessionConn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionConnCopyWith<SessionConn> get copyWith =>
      _$SessionConnCopyWithImpl<SessionConn>(this as SessionConn, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionConn'))
      ..add(DiagnosticsProperty('model', model))
      ..add(DiagnosticsProperty('conn2', conn2))
      ..add(DiagnosticsProperty('state', state))
      ..add(DiagnosticsProperty('currentSchema', currentSchema));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionConn &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.conn2, conn2) || other.conn2 == conn2) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, model, conn2, state, currentSchema);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionConn(model: $model, conn2: $conn2, state: $state, currentSchema: $currentSchema)';
  }
}

/// @nodoc
abstract mixin class $SessionConnCopyWith<$Res> {
  factory $SessionConnCopyWith(
          SessionConn value, $Res Function(SessionConn) _then) =
      _$SessionConnCopyWithImpl;
  @useResult
  $Res call(
      {SessionStorage model,
      BaseConnection? conn2,
      SQLConnectState state,
      String? currentSchema});
}

/// @nodoc
class _$SessionConnCopyWithImpl<$Res> implements $SessionConnCopyWith<$Res> {
  _$SessionConnCopyWithImpl(this._self, this._then);

  final SessionConn _self;
  final $Res Function(SessionConn) _then;

  /// Create a copy of SessionConn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = null,
    Object? conn2 = freezed,
    Object? state = null,
    Object? currentSchema = freezed,
  }) {
    return _then(_self.copyWith(
      model: null == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as SessionStorage,
      conn2: freezed == conn2
          ? _self.conn2
          : conn2 // ignore: cast_nullable_to_non_nullable
              as BaseConnection?,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as SQLConnectState,
      currentSchema: freezed == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _SessionConn with DiagnosticableTreeMixin implements SessionConn {
  const _SessionConn(
      {required this.model,
      this.conn2,
      required this.state,
      this.currentSchema});

  @override
  final SessionStorage model;
  @override
  final BaseConnection? conn2;
  @override
  final SQLConnectState state;
  @override
  final String? currentSchema;

  /// Create a copy of SessionConn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionConnCopyWith<_SessionConn> get copyWith =>
      __$SessionConnCopyWithImpl<_SessionConn>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionConn'))
      ..add(DiagnosticsProperty('model', model))
      ..add(DiagnosticsProperty('conn2', conn2))
      ..add(DiagnosticsProperty('state', state))
      ..add(DiagnosticsProperty('currentSchema', currentSchema));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionConn &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.conn2, conn2) || other.conn2 == conn2) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, model, conn2, state, currentSchema);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionConn(model: $model, conn2: $conn2, state: $state, currentSchema: $currentSchema)';
  }
}

/// @nodoc
abstract mixin class _$SessionConnCopyWith<$Res>
    implements $SessionConnCopyWith<$Res> {
  factory _$SessionConnCopyWith(
          _SessionConn value, $Res Function(_SessionConn) _then) =
      __$SessionConnCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SessionStorage model,
      BaseConnection? conn2,
      SQLConnectState state,
      String? currentSchema});
}

/// @nodoc
class __$SessionConnCopyWithImpl<$Res> implements _$SessionConnCopyWith<$Res> {
  __$SessionConnCopyWithImpl(this._self, this._then);

  final _SessionConn _self;
  final $Res Function(_SessionConn) _then;

  /// Create a copy of SessionConn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? model = null,
    Object? conn2 = freezed,
    Object? state = null,
    Object? currentSchema = freezed,
  }) {
    return _then(_SessionConn(
      model: null == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as SessionStorage,
      conn2: freezed == conn2
          ? _self.conn2
          : conn2 // ignore: cast_nullable_to_non_nullable
              as BaseConnection?,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as SQLConnectState,
      currentSchema: freezed == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$CurrentSessionDrawer implements DiagnosticableTreeMixin {
  DrawerPage get drawerPage;
  BaseQueryValue? get sqlResult;
  BaseQueryColumn? get sqlColumn;
  bool get showRecord;
  bool get isRightPageOpen;

  /// Create a copy of CurrentSessionDrawer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CurrentSessionDrawerCopyWith<CurrentSessionDrawer> get copyWith =>
      _$CurrentSessionDrawerCopyWithImpl<CurrentSessionDrawer>(
          this as CurrentSessionDrawer, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionDrawer'))
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
            other is CurrentSessionDrawer &&
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
    return 'CurrentSessionDrawer(drawerPage: $drawerPage, sqlResult: $sqlResult, sqlColumn: $sqlColumn, showRecord: $showRecord, isRightPageOpen: $isRightPageOpen)';
  }
}

/// @nodoc
abstract mixin class $CurrentSessionDrawerCopyWith<$Res> {
  factory $CurrentSessionDrawerCopyWith(CurrentSessionDrawer value,
          $Res Function(CurrentSessionDrawer) _then) =
      _$CurrentSessionDrawerCopyWithImpl;
  @useResult
  $Res call(
      {DrawerPage drawerPage,
      BaseQueryValue? sqlResult,
      BaseQueryColumn? sqlColumn,
      bool showRecord,
      bool isRightPageOpen});
}

/// @nodoc
class _$CurrentSessionDrawerCopyWithImpl<$Res>
    implements $CurrentSessionDrawerCopyWith<$Res> {
  _$CurrentSessionDrawerCopyWithImpl(this._self, this._then);

  final CurrentSessionDrawer _self;
  final $Res Function(CurrentSessionDrawer) _then;

  /// Create a copy of CurrentSessionDrawer
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

class _CurrentSessionDrawer
    with DiagnosticableTreeMixin
    implements CurrentSessionDrawer {
  const _CurrentSessionDrawer(
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

  /// Create a copy of CurrentSessionDrawer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CurrentSessionDrawerCopyWith<_CurrentSessionDrawer> get copyWith =>
      __$CurrentSessionDrawerCopyWithImpl<_CurrentSessionDrawer>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionDrawer'))
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
            other is _CurrentSessionDrawer &&
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
    return 'CurrentSessionDrawer(drawerPage: $drawerPage, sqlResult: $sqlResult, sqlColumn: $sqlColumn, showRecord: $showRecord, isRightPageOpen: $isRightPageOpen)';
  }
}

/// @nodoc
abstract mixin class _$CurrentSessionDrawerCopyWith<$Res>
    implements $CurrentSessionDrawerCopyWith<$Res> {
  factory _$CurrentSessionDrawerCopyWith(_CurrentSessionDrawer value,
          $Res Function(_CurrentSessionDrawer) _then) =
      __$CurrentSessionDrawerCopyWithImpl;
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
class __$CurrentSessionDrawerCopyWithImpl<$Res>
    implements _$CurrentSessionDrawerCopyWith<$Res> {
  __$CurrentSessionDrawerCopyWithImpl(this._self, this._then);

  final _CurrentSessionDrawer _self;
  final $Res Function(_CurrentSessionDrawer) _then;

  /// Create a copy of CurrentSessionDrawer
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
    return _then(_CurrentSessionDrawer(
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
mixin _$CurrentSessionSplitView implements DiagnosticableTreeMixin {
  SplitViewController get multiSplitViewCtrl;
  SplitViewController get metaDataSplitViewCtrl;
  CodeLineEditingController get code;
  bool get isRightPageOpen;

  /// Create a copy of CurrentSessionSplitView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CurrentSessionSplitViewCopyWith<CurrentSessionSplitView> get copyWith =>
      _$CurrentSessionSplitViewCopyWithImpl<CurrentSessionSplitView>(
          this as CurrentSessionSplitView, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionSplitView'))
      ..add(DiagnosticsProperty('multiSplitViewCtrl', multiSplitViewCtrl))
      ..add(DiagnosticsProperty('metaDataSplitViewCtrl', metaDataSplitViewCtrl))
      ..add(DiagnosticsProperty('code', code))
      ..add(DiagnosticsProperty('isRightPageOpen', isRightPageOpen));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CurrentSessionSplitView &&
            (identical(other.multiSplitViewCtrl, multiSplitViewCtrl) ||
                other.multiSplitViewCtrl == multiSplitViewCtrl) &&
            (identical(other.metaDataSplitViewCtrl, metaDataSplitViewCtrl) ||
                other.metaDataSplitViewCtrl == metaDataSplitViewCtrl) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.isRightPageOpen, isRightPageOpen) ||
                other.isRightPageOpen == isRightPageOpen));
  }

  @override
  int get hashCode => Object.hash(runtimeType, multiSplitViewCtrl,
      metaDataSplitViewCtrl, code, isRightPageOpen);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionSplitView(multiSplitViewCtrl: $multiSplitViewCtrl, metaDataSplitViewCtrl: $metaDataSplitViewCtrl, code: $code, isRightPageOpen: $isRightPageOpen)';
  }
}

/// @nodoc
abstract mixin class $CurrentSessionSplitViewCopyWith<$Res> {
  factory $CurrentSessionSplitViewCopyWith(CurrentSessionSplitView value,
          $Res Function(CurrentSessionSplitView) _then) =
      _$CurrentSessionSplitViewCopyWithImpl;
  @useResult
  $Res call(
      {SplitViewController multiSplitViewCtrl,
      SplitViewController metaDataSplitViewCtrl,
      CodeLineEditingController code,
      bool isRightPageOpen});
}

/// @nodoc
class _$CurrentSessionSplitViewCopyWithImpl<$Res>
    implements $CurrentSessionSplitViewCopyWith<$Res> {
  _$CurrentSessionSplitViewCopyWithImpl(this._self, this._then);

  final CurrentSessionSplitView _self;
  final $Res Function(CurrentSessionSplitView) _then;

  /// Create a copy of CurrentSessionSplitView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? multiSplitViewCtrl = null,
    Object? metaDataSplitViewCtrl = null,
    Object? code = null,
    Object? isRightPageOpen = null,
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
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as CodeLineEditingController,
      isRightPageOpen: null == isRightPageOpen
          ? _self.isRightPageOpen
          : isRightPageOpen // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _CurrentSessionSplitView
    with DiagnosticableTreeMixin
    implements CurrentSessionSplitView {
  const _CurrentSessionSplitView(
      {required this.multiSplitViewCtrl,
      required this.metaDataSplitViewCtrl,
      required this.code,
      required this.isRightPageOpen});

  @override
  final SplitViewController multiSplitViewCtrl;
  @override
  final SplitViewController metaDataSplitViewCtrl;
  @override
  final CodeLineEditingController code;
  @override
  final bool isRightPageOpen;

  /// Create a copy of CurrentSessionSplitView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CurrentSessionSplitViewCopyWith<_CurrentSessionSplitView> get copyWith =>
      __$CurrentSessionSplitViewCopyWithImpl<_CurrentSessionSplitView>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionSplitView'))
      ..add(DiagnosticsProperty('multiSplitViewCtrl', multiSplitViewCtrl))
      ..add(DiagnosticsProperty('metaDataSplitViewCtrl', metaDataSplitViewCtrl))
      ..add(DiagnosticsProperty('code', code))
      ..add(DiagnosticsProperty('isRightPageOpen', isRightPageOpen));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CurrentSessionSplitView &&
            (identical(other.multiSplitViewCtrl, multiSplitViewCtrl) ||
                other.multiSplitViewCtrl == multiSplitViewCtrl) &&
            (identical(other.metaDataSplitViewCtrl, metaDataSplitViewCtrl) ||
                other.metaDataSplitViewCtrl == metaDataSplitViewCtrl) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.isRightPageOpen, isRightPageOpen) ||
                other.isRightPageOpen == isRightPageOpen));
  }

  @override
  int get hashCode => Object.hash(runtimeType, multiSplitViewCtrl,
      metaDataSplitViewCtrl, code, isRightPageOpen);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionSplitView(multiSplitViewCtrl: $multiSplitViewCtrl, metaDataSplitViewCtrl: $metaDataSplitViewCtrl, code: $code, isRightPageOpen: $isRightPageOpen)';
  }
}

/// @nodoc
abstract mixin class _$CurrentSessionSplitViewCopyWith<$Res>
    implements $CurrentSessionSplitViewCopyWith<$Res> {
  factory _$CurrentSessionSplitViewCopyWith(_CurrentSessionSplitView value,
          $Res Function(_CurrentSessionSplitView) _then) =
      __$CurrentSessionSplitViewCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SplitViewController multiSplitViewCtrl,
      SplitViewController metaDataSplitViewCtrl,
      CodeLineEditingController code,
      bool isRightPageOpen});
}

/// @nodoc
class __$CurrentSessionSplitViewCopyWithImpl<$Res>
    implements _$CurrentSessionSplitViewCopyWith<$Res> {
  __$CurrentSessionSplitViewCopyWithImpl(this._self, this._then);

  final _CurrentSessionSplitView _self;
  final $Res Function(_CurrentSessionSplitView) _then;

  /// Create a copy of CurrentSessionSplitView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? multiSplitViewCtrl = null,
    Object? metaDataSplitViewCtrl = null,
    Object? code = null,
    Object? isRightPageOpen = null,
  }) {
    return _then(_CurrentSessionSplitView(
      multiSplitViewCtrl: null == multiSplitViewCtrl
          ? _self.multiSplitViewCtrl
          : multiSplitViewCtrl // ignore: cast_nullable_to_non_nullable
              as SplitViewController,
      metaDataSplitViewCtrl: null == metaDataSplitViewCtrl
          ? _self.metaDataSplitViewCtrl
          : metaDataSplitViewCtrl // ignore: cast_nullable_to_non_nullable
              as SplitViewController,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as CodeLineEditingController,
      isRightPageOpen: null == isRightPageOpen
          ? _self.isRightPageOpen
          : isRightPageOpen // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$CurrentSessionSQLResult implements DiagnosticableTreeMixin {
  ReorderSelectedList<SQLResultModel> get sqlResults;
  SQLExecuteState? get queryState;

  /// Create a copy of CurrentSessionSQLResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CurrentSessionSQLResultCopyWith<CurrentSessionSQLResult> get copyWith =>
      _$CurrentSessionSQLResultCopyWithImpl<CurrentSessionSQLResult>(
          this as CurrentSessionSQLResult, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionSQLResult'))
      ..add(DiagnosticsProperty('sqlResults', sqlResults))
      ..add(DiagnosticsProperty('queryState', queryState));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CurrentSessionSQLResult &&
            const DeepCollectionEquality()
                .equals(other.sqlResults, sqlResults) &&
            (identical(other.queryState, queryState) ||
                other.queryState == queryState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(sqlResults), queryState);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionSQLResult(sqlResults: $sqlResults, queryState: $queryState)';
  }
}

/// @nodoc
abstract mixin class $CurrentSessionSQLResultCopyWith<$Res> {
  factory $CurrentSessionSQLResultCopyWith(CurrentSessionSQLResult value,
          $Res Function(CurrentSessionSQLResult) _then) =
      _$CurrentSessionSQLResultCopyWithImpl;
  @useResult
  $Res call(
      {ReorderSelectedList<SQLResultModel> sqlResults,
      SQLExecuteState? queryState});
}

/// @nodoc
class _$CurrentSessionSQLResultCopyWithImpl<$Res>
    implements $CurrentSessionSQLResultCopyWith<$Res> {
  _$CurrentSessionSQLResultCopyWithImpl(this._self, this._then);

  final CurrentSessionSQLResult _self;
  final $Res Function(CurrentSessionSQLResult) _then;

  /// Create a copy of CurrentSessionSQLResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sqlResults = null,
    Object? queryState = freezed,
  }) {
    return _then(_self.copyWith(
      sqlResults: null == sqlResults
          ? _self.sqlResults
          : sqlResults // ignore: cast_nullable_to_non_nullable
              as ReorderSelectedList<SQLResultModel>,
      queryState: freezed == queryState
          ? _self.queryState
          : queryState // ignore: cast_nullable_to_non_nullable
              as SQLExecuteState?,
    ));
  }
}

/// @nodoc

class _CurrentSessionSQLResult
    with DiagnosticableTreeMixin
    implements CurrentSessionSQLResult {
  const _CurrentSessionSQLResult(
      {required this.sqlResults, required this.queryState});

  @override
  final ReorderSelectedList<SQLResultModel> sqlResults;
  @override
  final SQLExecuteState? queryState;

  /// Create a copy of CurrentSessionSQLResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CurrentSessionSQLResultCopyWith<_CurrentSessionSQLResult> get copyWith =>
      __$CurrentSessionSQLResultCopyWithImpl<_CurrentSessionSQLResult>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionSQLResult'))
      ..add(DiagnosticsProperty('sqlResults', sqlResults))
      ..add(DiagnosticsProperty('queryState', queryState));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CurrentSessionSQLResult &&
            const DeepCollectionEquality()
                .equals(other.sqlResults, sqlResults) &&
            (identical(other.queryState, queryState) ||
                other.queryState == queryState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(sqlResults), queryState);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionSQLResult(sqlResults: $sqlResults, queryState: $queryState)';
  }
}

/// @nodoc
abstract mixin class _$CurrentSessionSQLResultCopyWith<$Res>
    implements $CurrentSessionSQLResultCopyWith<$Res> {
  factory _$CurrentSessionSQLResultCopyWith(_CurrentSessionSQLResult value,
          $Res Function(_CurrentSessionSQLResult) _then) =
      __$CurrentSessionSQLResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {ReorderSelectedList<SQLResultModel> sqlResults,
      SQLExecuteState? queryState});
}

/// @nodoc
class __$CurrentSessionSQLResultCopyWithImpl<$Res>
    implements _$CurrentSessionSQLResultCopyWith<$Res> {
  __$CurrentSessionSQLResultCopyWithImpl(this._self, this._then);

  final _CurrentSessionSQLResult _self;
  final $Res Function(_CurrentSessionSQLResult) _then;

  /// Create a copy of CurrentSessionSQLResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sqlResults = null,
    Object? queryState = freezed,
  }) {
    return _then(_CurrentSessionSQLResult(
      sqlResults: null == sqlResults
          ? _self.sqlResults
          : sqlResults // ignore: cast_nullable_to_non_nullable
              as ReorderSelectedList<SQLResultModel>,
      queryState: freezed == queryState
          ? _self.queryState
          : queryState // ignore: cast_nullable_to_non_nullable
              as SQLExecuteState?,
    ));
  }
}

// dart format on
