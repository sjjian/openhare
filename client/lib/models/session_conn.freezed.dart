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
mixin _$SessionConnModel implements DiagnosticableTreeMixin {
  int get sessionId;
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
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('currentSchema', currentSchema))
      ..add(DiagnosticsProperty('canQuery', canQuery));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionConnModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.canQuery, canQuery) ||
                other.canQuery == canQuery));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, sessionId, currentSchema, canQuery);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionConnModel(sessionId: $sessionId, currentSchema: $currentSchema, canQuery: $canQuery)';
  }
}

/// @nodoc
abstract mixin class $SessionConnModelCopyWith<$Res> {
  factory $SessionConnModelCopyWith(
          SessionConnModel value, $Res Function(SessionConnModel) _then) =
      _$SessionConnModelCopyWithImpl;
  @useResult
  $Res call({int sessionId, String currentSchema, bool canQuery});
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
    Object? sessionId = null,
    Object? currentSchema = null,
    Object? canQuery = null,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
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
}

/// @nodoc

class _SessionConnModel
    with DiagnosticableTreeMixin
    implements SessionConnModel {
  const _SessionConnModel(
      {required this.sessionId,
      required this.currentSchema,
      required this.canQuery});

  @override
  final int sessionId;
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
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('currentSchema', currentSchema))
      ..add(DiagnosticsProperty('canQuery', canQuery));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionConnModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.currentSchema, currentSchema) ||
                other.currentSchema == currentSchema) &&
            (identical(other.canQuery, canQuery) ||
                other.canQuery == canQuery));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, sessionId, currentSchema, canQuery);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionConnModel(sessionId: $sessionId, currentSchema: $currentSchema, canQuery: $canQuery)';
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
  $Res call({int sessionId, String currentSchema, bool canQuery});
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
    Object? sessionId = null,
    Object? currentSchema = null,
    Object? canQuery = null,
  }) {
    return _then(_SessionConnModel(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
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
}

// dart format on
