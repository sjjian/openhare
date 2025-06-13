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
mixin _$SQLResultModel implements DiagnosticableTreeMixin {
  int get sessionId;
  int get resultId;
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
      ..add(DiagnosticsProperty('sessionId', sessionId))
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
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
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
      runtimeType, sessionId, resultId, state, query, executeTime, error, data);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SQLResultModel(sessionId: $sessionId, resultId: $resultId, state: $state, query: $query, executeTime: $executeTime, error: $error, data: $data)';
  }
}

/// @nodoc
abstract mixin class $SQLResultModelCopyWith<$Res> {
  factory $SQLResultModelCopyWith(
          SQLResultModel value, $Res Function(SQLResultModel) _then) =
      _$SQLResultModelCopyWithImpl;
  @useResult
  $Res call(
      {int sessionId,
      int resultId,
      SQLExecuteState state,
      String? query,
      Duration? executeTime,
      String? error,
      BaseQueryResult? data});
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
    Object? sessionId = null,
    Object? resultId = null,
    Object? state = null,
    Object? query = freezed,
    Object? executeTime = freezed,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      resultId: null == resultId
          ? _self.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as int,
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
}

/// @nodoc

class _SQLResultModel with DiagnosticableTreeMixin implements SQLResultModel {
  const _SQLResultModel(
      {required this.sessionId,
      required this.resultId,
      required this.state,
      this.query,
      this.executeTime,
      this.error,
      this.data});

  @override
  final int sessionId;
  @override
  final int resultId;
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
      ..add(DiagnosticsProperty('sessionId', sessionId))
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
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
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
      runtimeType, sessionId, resultId, state, query, executeTime, error, data);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SQLResultModel(sessionId: $sessionId, resultId: $resultId, state: $state, query: $query, executeTime: $executeTime, error: $error, data: $data)';
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
      {int sessionId,
      int resultId,
      SQLExecuteState state,
      String? query,
      Duration? executeTime,
      String? error,
      BaseQueryResult? data});
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
    Object? sessionId = null,
    Object? resultId = null,
    Object? state = null,
    Object? query = freezed,
    Object? executeTime = freezed,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_SQLResultModel(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      resultId: null == resultId
          ? _self.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as int,
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
}

/// @nodoc
mixin _$SQLResultListModel implements DiagnosticableTreeMixin {
  int get sessionId;
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
      {int sessionId, List<SQLResultModel> results, SQLResultModel? selected});

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
              as int,
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
  final int sessionId;
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
      {int sessionId, List<SQLResultModel> results, SQLResultModel? selected});

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
              as int,
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
