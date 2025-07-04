// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_sql_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

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
