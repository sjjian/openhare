// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_conn.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

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
  String get currentSchema;
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
      ..add(DiagnosticsProperty('currentSchema', currentSchema))
      ..add(DiagnosticsProperty('canQuery', canQuery));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionConnModel &&
            (identical(other.connId, connId) || other.connId == connId) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.canQuery, canQuery) ||
                other.canQuery == canQuery));
  }

  @override
  int get hashCode => Object.hash(runtimeType, connId, currentSchema, canQuery);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionConnModel(connId: $connId, currentSchema: $currentSchema, canQuery: $canQuery)';
  }
}

/// @nodoc
abstract mixin class $SessionConnModelCopyWith<$Res> {
  factory $SessionConnModelCopyWith(
          SessionConnModel value, $Res Function(SessionConnModel) _then) =
      _$SessionConnModelCopyWithImpl;
  @useResult
  $Res call({ConnId connId, String currentSchema, bool canQuery});

  $ConnIdCopyWith<$Res> get connId;
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
    Object? currentSchema = null,
    Object? canQuery = null,
  }) {
    return _then(_self.copyWith(
      connId: null == connId
          ? _self.connId
          : connId // ignore: cast_nullable_to_non_nullable
              as ConnId,
      currentSchema: null == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String,
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
}

/// @nodoc

class _SessionConnModel
    with DiagnosticableTreeMixin
    implements SessionConnModel {
  const _SessionConnModel(
      {required this.connId,
      required this.currentSchema,
      required this.canQuery});

  @override
  final ConnId connId;
  @override
  final String currentSchema;
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
      ..add(DiagnosticsProperty('currentSchema', currentSchema))
      ..add(DiagnosticsProperty('canQuery', canQuery));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionConnModel &&
            (identical(other.connId, connId) || other.connId == connId) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.canQuery, canQuery) ||
                other.canQuery == canQuery));
  }

  @override
  int get hashCode => Object.hash(runtimeType, connId, currentSchema, canQuery);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionConnModel(connId: $connId, currentSchema: $currentSchema, canQuery: $canQuery)';
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
  $Res call({ConnId connId, String currentSchema, bool canQuery});

  @override
  $ConnIdCopyWith<$Res> get connId;
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
    Object? currentSchema = null,
    Object? canQuery = null,
  }) {
    return _then(_SessionConnModel(
      connId: null == connId
          ? _self.connId
          : connId // ignore: cast_nullable_to_non_nullable
              as ConnId,
      currentSchema: null == currentSchema
          ? _self.currentSchema
          : currentSchema // ignore: cast_nullable_to_non_nullable
              as String,
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
}

// dart format on
