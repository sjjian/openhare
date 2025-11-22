// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LLMAgentId {
  int get value;

  /// Create a copy of LLMAgentId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LLMAgentIdCopyWith<LLMAgentId> get copyWith =>
      _$LLMAgentIdCopyWithImpl<LLMAgentId>(this as LLMAgentId, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LLMAgentId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() {
    return 'LLMAgentId(value: $value)';
  }
}

/// @nodoc
abstract mixin class $LLMAgentIdCopyWith<$Res> {
  factory $LLMAgentIdCopyWith(
          LLMAgentId value, $Res Function(LLMAgentId) _then) =
      _$LLMAgentIdCopyWithImpl;
  @useResult
  $Res call({int value});
}

/// @nodoc
class _$LLMAgentIdCopyWithImpl<$Res> implements $LLMAgentIdCopyWith<$Res> {
  _$LLMAgentIdCopyWithImpl(this._self, this._then);

  final LLMAgentId _self;
  final $Res Function(LLMAgentId) _then;

  /// Create a copy of LLMAgentId
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

/// Adds pattern-matching-related methods to [LLMAgentId].
extension LLMAgentIdPatterns on LLMAgentId {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_LLMAgentId value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LLMAgentId() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_LLMAgentId value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentId():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_LLMAgentId value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentId() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LLMAgentId() when $default != null:
        return $default(_that.value);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentId():
        return $default(_that.value);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentId() when $default != null:
        return $default(_that.value);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LLMAgentId implements LLMAgentId {
  const _LLMAgentId({required this.value});

  @override
  final int value;

  /// Create a copy of LLMAgentId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LLMAgentIdCopyWith<_LLMAgentId> get copyWith =>
      __$LLMAgentIdCopyWithImpl<_LLMAgentId>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LLMAgentId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() {
    return 'LLMAgentId(value: $value)';
  }
}

/// @nodoc
abstract mixin class _$LLMAgentIdCopyWith<$Res>
    implements $LLMAgentIdCopyWith<$Res> {
  factory _$LLMAgentIdCopyWith(
          _LLMAgentId value, $Res Function(_LLMAgentId) _then) =
      __$LLMAgentIdCopyWithImpl;
  @override
  @useResult
  $Res call({int value});
}

/// @nodoc
class __$LLMAgentIdCopyWithImpl<$Res> implements _$LLMAgentIdCopyWith<$Res> {
  __$LLMAgentIdCopyWithImpl(this._self, this._then);

  final _LLMAgentId _self;
  final $Res Function(_LLMAgentId) _then;

  /// Create a copy of LLMAgentId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
  }) {
    return _then(_LLMAgentId(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$LLMAgentSettingModel {
  String get name;
  String get baseUrl;
  String get apiKey;
  String get modelName;

  /// Create a copy of LLMAgentSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LLMAgentSettingModelCopyWith<LLMAgentSettingModel> get copyWith =>
      _$LLMAgentSettingModelCopyWithImpl<LLMAgentSettingModel>(
          this as LLMAgentSettingModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LLMAgentSettingModel &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl) &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, baseUrl, apiKey, modelName);

  @override
  String toString() {
    return 'LLMAgentSettingModel(name: $name, baseUrl: $baseUrl, apiKey: $apiKey, modelName: $modelName)';
  }
}

/// @nodoc
abstract mixin class $LLMAgentSettingModelCopyWith<$Res> {
  factory $LLMAgentSettingModelCopyWith(LLMAgentSettingModel value,
          $Res Function(LLMAgentSettingModel) _then) =
      _$LLMAgentSettingModelCopyWithImpl;
  @useResult
  $Res call({String name, String baseUrl, String apiKey, String modelName});
}

/// @nodoc
class _$LLMAgentSettingModelCopyWithImpl<$Res>
    implements $LLMAgentSettingModelCopyWith<$Res> {
  _$LLMAgentSettingModelCopyWithImpl(this._self, this._then);

  final LLMAgentSettingModel _self;
  final $Res Function(LLMAgentSettingModel) _then;

  /// Create a copy of LLMAgentSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? baseUrl = null,
    Object? apiKey = null,
    Object? modelName = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      baseUrl: null == baseUrl
          ? _self.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      apiKey: null == apiKey
          ? _self.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      modelName: null == modelName
          ? _self.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [LLMAgentSettingModel].
extension LLMAgentSettingModelPatterns on LLMAgentSettingModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_LLMAgentSettingModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LLMAgentSettingModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_LLMAgentSettingModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentSettingModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_LLMAgentSettingModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentSettingModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String name, String baseUrl, String apiKey, String modelName)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LLMAgentSettingModel() when $default != null:
        return $default(
            _that.name, _that.baseUrl, _that.apiKey, _that.modelName);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String name, String baseUrl, String apiKey, String modelName)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentSettingModel():
        return $default(
            _that.name, _that.baseUrl, _that.apiKey, _that.modelName);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String name, String baseUrl, String apiKey, String modelName)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentSettingModel() when $default != null:
        return $default(
            _that.name, _that.baseUrl, _that.apiKey, _that.modelName);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LLMAgentSettingModel implements LLMAgentSettingModel {
  const _LLMAgentSettingModel(
      {required this.name,
      required this.baseUrl,
      required this.apiKey,
      required this.modelName});

  @override
  final String name;
  @override
  final String baseUrl;
  @override
  final String apiKey;
  @override
  final String modelName;

  /// Create a copy of LLMAgentSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LLMAgentSettingModelCopyWith<_LLMAgentSettingModel> get copyWith =>
      __$LLMAgentSettingModelCopyWithImpl<_LLMAgentSettingModel>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LLMAgentSettingModel &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl) &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, baseUrl, apiKey, modelName);

  @override
  String toString() {
    return 'LLMAgentSettingModel(name: $name, baseUrl: $baseUrl, apiKey: $apiKey, modelName: $modelName)';
  }
}

/// @nodoc
abstract mixin class _$LLMAgentSettingModelCopyWith<$Res>
    implements $LLMAgentSettingModelCopyWith<$Res> {
  factory _$LLMAgentSettingModelCopyWith(_LLMAgentSettingModel value,
          $Res Function(_LLMAgentSettingModel) _then) =
      __$LLMAgentSettingModelCopyWithImpl;
  @override
  @useResult
  $Res call({String name, String baseUrl, String apiKey, String modelName});
}

/// @nodoc
class __$LLMAgentSettingModelCopyWithImpl<$Res>
    implements _$LLMAgentSettingModelCopyWith<$Res> {
  __$LLMAgentSettingModelCopyWithImpl(this._self, this._then);

  final _LLMAgentSettingModel _self;
  final $Res Function(_LLMAgentSettingModel) _then;

  /// Create a copy of LLMAgentSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? baseUrl = null,
    Object? apiKey = null,
    Object? modelName = null,
  }) {
    return _then(_LLMAgentSettingModel(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      baseUrl: null == baseUrl
          ? _self.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      apiKey: null == apiKey
          ? _self.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      modelName: null == modelName
          ? _self.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$LLMAgentStatusModel {
  LLMAgentState get state;
  String? get error;

  /// Create a copy of LLMAgentStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LLMAgentStatusModelCopyWith<LLMAgentStatusModel> get copyWith =>
      _$LLMAgentStatusModelCopyWithImpl<LLMAgentStatusModel>(
          this as LLMAgentStatusModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LLMAgentStatusModel &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, state, error);

  @override
  String toString() {
    return 'LLMAgentStatusModel(state: $state, error: $error)';
  }
}

/// @nodoc
abstract mixin class $LLMAgentStatusModelCopyWith<$Res> {
  factory $LLMAgentStatusModelCopyWith(
          LLMAgentStatusModel value, $Res Function(LLMAgentStatusModel) _then) =
      _$LLMAgentStatusModelCopyWithImpl;
  @useResult
  $Res call({LLMAgentState state, String? error});
}

/// @nodoc
class _$LLMAgentStatusModelCopyWithImpl<$Res>
    implements $LLMAgentStatusModelCopyWith<$Res> {
  _$LLMAgentStatusModelCopyWithImpl(this._self, this._then);

  final LLMAgentStatusModel _self;
  final $Res Function(LLMAgentStatusModel) _then;

  /// Create a copy of LLMAgentStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as LLMAgentState,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [LLMAgentStatusModel].
extension LLMAgentStatusModelPatterns on LLMAgentStatusModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_LLMAgentStatusModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LLMAgentStatusModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_LLMAgentStatusModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentStatusModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_LLMAgentStatusModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentStatusModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(LLMAgentState state, String? error)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LLMAgentStatusModel() when $default != null:
        return $default(_that.state, _that.error);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(LLMAgentState state, String? error) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentStatusModel():
        return $default(_that.state, _that.error);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(LLMAgentState state, String? error)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentStatusModel() when $default != null:
        return $default(_that.state, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LLMAgentStatusModel implements LLMAgentStatusModel {
  const _LLMAgentStatusModel({required this.state, this.error});

  @override
  final LLMAgentState state;
  @override
  final String? error;

  /// Create a copy of LLMAgentStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LLMAgentStatusModelCopyWith<_LLMAgentStatusModel> get copyWith =>
      __$LLMAgentStatusModelCopyWithImpl<_LLMAgentStatusModel>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LLMAgentStatusModel &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, state, error);

  @override
  String toString() {
    return 'LLMAgentStatusModel(state: $state, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$LLMAgentStatusModelCopyWith<$Res>
    implements $LLMAgentStatusModelCopyWith<$Res> {
  factory _$LLMAgentStatusModelCopyWith(_LLMAgentStatusModel value,
          $Res Function(_LLMAgentStatusModel) _then) =
      __$LLMAgentStatusModelCopyWithImpl;
  @override
  @useResult
  $Res call({LLMAgentState state, String? error});
}

/// @nodoc
class __$LLMAgentStatusModelCopyWithImpl<$Res>
    implements _$LLMAgentStatusModelCopyWith<$Res> {
  __$LLMAgentStatusModelCopyWithImpl(this._self, this._then);

  final _LLMAgentStatusModel _self;
  final $Res Function(_LLMAgentStatusModel) _then;

  /// Create a copy of LLMAgentStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? state = null,
    Object? error = freezed,
  }) {
    return _then(_LLMAgentStatusModel(
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as LLMAgentState,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$LLMAgentModel {
  LLMAgentId get id;
  LLMAgentSettingModel get setting;
  LLMAgentStatusModel get status;

  /// Create a copy of LLMAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LLMAgentModelCopyWith<LLMAgentModel> get copyWith =>
      _$LLMAgentModelCopyWithImpl<LLMAgentModel>(
          this as LLMAgentModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LLMAgentModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.setting, setting) || other.setting == setting) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, setting, status);

  @override
  String toString() {
    return 'LLMAgentModel(id: $id, setting: $setting, status: $status)';
  }
}

/// @nodoc
abstract mixin class $LLMAgentModelCopyWith<$Res> {
  factory $LLMAgentModelCopyWith(
          LLMAgentModel value, $Res Function(LLMAgentModel) _then) =
      _$LLMAgentModelCopyWithImpl;
  @useResult
  $Res call(
      {LLMAgentId id,
      LLMAgentSettingModel setting,
      LLMAgentStatusModel status});

  $LLMAgentIdCopyWith<$Res> get id;
  $LLMAgentSettingModelCopyWith<$Res> get setting;
  $LLMAgentStatusModelCopyWith<$Res> get status;
}

/// @nodoc
class _$LLMAgentModelCopyWithImpl<$Res>
    implements $LLMAgentModelCopyWith<$Res> {
  _$LLMAgentModelCopyWithImpl(this._self, this._then);

  final LLMAgentModel _self;
  final $Res Function(LLMAgentModel) _then;

  /// Create a copy of LLMAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? setting = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as LLMAgentId,
      setting: null == setting
          ? _self.setting
          : setting // ignore: cast_nullable_to_non_nullable
              as LLMAgentSettingModel,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as LLMAgentStatusModel,
    ));
  }

  /// Create a copy of LLMAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LLMAgentIdCopyWith<$Res> get id {
    return $LLMAgentIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }

  /// Create a copy of LLMAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LLMAgentSettingModelCopyWith<$Res> get setting {
    return $LLMAgentSettingModelCopyWith<$Res>(_self.setting, (value) {
      return _then(_self.copyWith(setting: value));
    });
  }

  /// Create a copy of LLMAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LLMAgentStatusModelCopyWith<$Res> get status {
    return $LLMAgentStatusModelCopyWith<$Res>(_self.status, (value) {
      return _then(_self.copyWith(status: value));
    });
  }
}

/// Adds pattern-matching-related methods to [LLMAgentModel].
extension LLMAgentModelPatterns on LLMAgentModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_LLMAgentModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LLMAgentModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_LLMAgentModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_LLMAgentModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(LLMAgentId id, LLMAgentSettingModel setting,
            LLMAgentStatusModel status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LLMAgentModel() when $default != null:
        return $default(_that.id, _that.setting, _that.status);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(LLMAgentId id, LLMAgentSettingModel setting,
            LLMAgentStatusModel status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentModel():
        return $default(_that.id, _that.setting, _that.status);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(LLMAgentId id, LLMAgentSettingModel setting,
            LLMAgentStatusModel status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentModel() when $default != null:
        return $default(_that.id, _that.setting, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LLMAgentModel implements LLMAgentModel {
  const _LLMAgentModel(
      {required this.id, required this.setting, required this.status});

  @override
  final LLMAgentId id;
  @override
  final LLMAgentSettingModel setting;
  @override
  final LLMAgentStatusModel status;

  /// Create a copy of LLMAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LLMAgentModelCopyWith<_LLMAgentModel> get copyWith =>
      __$LLMAgentModelCopyWithImpl<_LLMAgentModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LLMAgentModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.setting, setting) || other.setting == setting) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, setting, status);

  @override
  String toString() {
    return 'LLMAgentModel(id: $id, setting: $setting, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$LLMAgentModelCopyWith<$Res>
    implements $LLMAgentModelCopyWith<$Res> {
  factory _$LLMAgentModelCopyWith(
          _LLMAgentModel value, $Res Function(_LLMAgentModel) _then) =
      __$LLMAgentModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {LLMAgentId id,
      LLMAgentSettingModel setting,
      LLMAgentStatusModel status});

  @override
  $LLMAgentIdCopyWith<$Res> get id;
  @override
  $LLMAgentSettingModelCopyWith<$Res> get setting;
  @override
  $LLMAgentStatusModelCopyWith<$Res> get status;
}

/// @nodoc
class __$LLMAgentModelCopyWithImpl<$Res>
    implements _$LLMAgentModelCopyWith<$Res> {
  __$LLMAgentModelCopyWithImpl(this._self, this._then);

  final _LLMAgentModel _self;
  final $Res Function(_LLMAgentModel) _then;

  /// Create a copy of LLMAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? setting = null,
    Object? status = null,
  }) {
    return _then(_LLMAgentModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as LLMAgentId,
      setting: null == setting
          ? _self.setting
          : setting // ignore: cast_nullable_to_non_nullable
              as LLMAgentSettingModel,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as LLMAgentStatusModel,
    ));
  }

  /// Create a copy of LLMAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LLMAgentIdCopyWith<$Res> get id {
    return $LLMAgentIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }

  /// Create a copy of LLMAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LLMAgentSettingModelCopyWith<$Res> get setting {
    return $LLMAgentSettingModelCopyWith<$Res>(_self.setting, (value) {
      return _then(_self.copyWith(setting: value));
    });
  }

  /// Create a copy of LLMAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LLMAgentStatusModelCopyWith<$Res> get status {
    return $LLMAgentStatusModelCopyWith<$Res>(_self.status, (value) {
      return _then(_self.copyWith(status: value));
    });
  }
}

/// @nodoc
mixin _$LLMAgentsModel {
  Map<LLMAgentId, LLMAgentModel> get agents;
  LLMAgentModel? get lastUsedLLMAgent;

  /// Create a copy of LLMAgentsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LLMAgentsModelCopyWith<LLMAgentsModel> get copyWith =>
      _$LLMAgentsModelCopyWithImpl<LLMAgentsModel>(
          this as LLMAgentsModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LLMAgentsModel &&
            const DeepCollectionEquality().equals(other.agents, agents) &&
            (identical(other.lastUsedLLMAgent, lastUsedLLMAgent) ||
                other.lastUsedLLMAgent == lastUsedLLMAgent));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(agents), lastUsedLLMAgent);

  @override
  String toString() {
    return 'LLMAgentsModel(agents: $agents, lastUsedLLMAgent: $lastUsedLLMAgent)';
  }
}

/// @nodoc
abstract mixin class $LLMAgentsModelCopyWith<$Res> {
  factory $LLMAgentsModelCopyWith(
          LLMAgentsModel value, $Res Function(LLMAgentsModel) _then) =
      _$LLMAgentsModelCopyWithImpl;
  @useResult
  $Res call(
      {Map<LLMAgentId, LLMAgentModel> agents, LLMAgentModel? lastUsedLLMAgent});

  $LLMAgentModelCopyWith<$Res>? get lastUsedLLMAgent;
}

/// @nodoc
class _$LLMAgentsModelCopyWithImpl<$Res>
    implements $LLMAgentsModelCopyWith<$Res> {
  _$LLMAgentsModelCopyWithImpl(this._self, this._then);

  final LLMAgentsModel _self;
  final $Res Function(LLMAgentsModel) _then;

  /// Create a copy of LLMAgentsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agents = null,
    Object? lastUsedLLMAgent = freezed,
  }) {
    return _then(_self.copyWith(
      agents: null == agents
          ? _self.agents
          : agents // ignore: cast_nullable_to_non_nullable
              as Map<LLMAgentId, LLMAgentModel>,
      lastUsedLLMAgent: freezed == lastUsedLLMAgent
          ? _self.lastUsedLLMAgent
          : lastUsedLLMAgent // ignore: cast_nullable_to_non_nullable
              as LLMAgentModel?,
    ));
  }

  /// Create a copy of LLMAgentsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LLMAgentModelCopyWith<$Res>? get lastUsedLLMAgent {
    if (_self.lastUsedLLMAgent == null) {
      return null;
    }

    return $LLMAgentModelCopyWith<$Res>(_self.lastUsedLLMAgent!, (value) {
      return _then(_self.copyWith(lastUsedLLMAgent: value));
    });
  }
}

/// Adds pattern-matching-related methods to [LLMAgentsModel].
extension LLMAgentsModelPatterns on LLMAgentsModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_LLMAgentsModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LLMAgentsModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_LLMAgentsModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentsModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_LLMAgentsModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentsModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(Map<LLMAgentId, LLMAgentModel> agents,
            LLMAgentModel? lastUsedLLMAgent)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LLMAgentsModel() when $default != null:
        return $default(_that.agents, _that.lastUsedLLMAgent);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(Map<LLMAgentId, LLMAgentModel> agents,
            LLMAgentModel? lastUsedLLMAgent)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentsModel():
        return $default(_that.agents, _that.lastUsedLLMAgent);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(Map<LLMAgentId, LLMAgentModel> agents,
            LLMAgentModel? lastUsedLLMAgent)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LLMAgentsModel() when $default != null:
        return $default(_that.agents, _that.lastUsedLLMAgent);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LLMAgentsModel implements LLMAgentsModel {
  const _LLMAgentsModel(
      {required final Map<LLMAgentId, LLMAgentModel> agents,
      required this.lastUsedLLMAgent})
      : _agents = agents;

  final Map<LLMAgentId, LLMAgentModel> _agents;
  @override
  Map<LLMAgentId, LLMAgentModel> get agents {
    if (_agents is EqualUnmodifiableMapView) return _agents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_agents);
  }

  @override
  final LLMAgentModel? lastUsedLLMAgent;

  /// Create a copy of LLMAgentsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LLMAgentsModelCopyWith<_LLMAgentsModel> get copyWith =>
      __$LLMAgentsModelCopyWithImpl<_LLMAgentsModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LLMAgentsModel &&
            const DeepCollectionEquality().equals(other._agents, _agents) &&
            (identical(other.lastUsedLLMAgent, lastUsedLLMAgent) ||
                other.lastUsedLLMAgent == lastUsedLLMAgent));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_agents), lastUsedLLMAgent);

  @override
  String toString() {
    return 'LLMAgentsModel(agents: $agents, lastUsedLLMAgent: $lastUsedLLMAgent)';
  }
}

/// @nodoc
abstract mixin class _$LLMAgentsModelCopyWith<$Res>
    implements $LLMAgentsModelCopyWith<$Res> {
  factory _$LLMAgentsModelCopyWith(
          _LLMAgentsModel value, $Res Function(_LLMAgentsModel) _then) =
      __$LLMAgentsModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Map<LLMAgentId, LLMAgentModel> agents, LLMAgentModel? lastUsedLLMAgent});

  @override
  $LLMAgentModelCopyWith<$Res>? get lastUsedLLMAgent;
}

/// @nodoc
class __$LLMAgentsModelCopyWithImpl<$Res>
    implements _$LLMAgentsModelCopyWith<$Res> {
  __$LLMAgentsModelCopyWithImpl(this._self, this._then);

  final _LLMAgentsModel _self;
  final $Res Function(_LLMAgentsModel) _then;

  /// Create a copy of LLMAgentsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? agents = null,
    Object? lastUsedLLMAgent = freezed,
  }) {
    return _then(_LLMAgentsModel(
      agents: null == agents
          ? _self._agents
          : agents // ignore: cast_nullable_to_non_nullable
              as Map<LLMAgentId, LLMAgentModel>,
      lastUsedLLMAgent: freezed == lastUsedLLMAgent
          ? _self.lastUsedLLMAgent
          : lastUsedLLMAgent // ignore: cast_nullable_to_non_nullable
              as LLMAgentModel?,
    ));
  }

  /// Create a copy of LLMAgentsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LLMAgentModelCopyWith<$Res>? get lastUsedLLMAgent {
    if (_self.lastUsedLLMAgent == null) {
      return null;
    }

    return $LLMAgentModelCopyWith<$Res>(_self.lastUsedLLMAgent!, (value) {
      return _then(_self.copyWith(lastUsedLLMAgent: value));
    });
  }
}

/// @nodoc
mixin _$AIChatId {
  int get value;

  /// Create a copy of AIChatId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIChatIdCopyWith<AIChatId> get copyWith =>
      _$AIChatIdCopyWithImpl<AIChatId>(this as AIChatId, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIChatId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() {
    return 'AIChatId(value: $value)';
  }
}

/// @nodoc
abstract mixin class $AIChatIdCopyWith<$Res> {
  factory $AIChatIdCopyWith(AIChatId value, $Res Function(AIChatId) _then) =
      _$AIChatIdCopyWithImpl;
  @useResult
  $Res call({int value});
}

/// @nodoc
class _$AIChatIdCopyWithImpl<$Res> implements $AIChatIdCopyWith<$Res> {
  _$AIChatIdCopyWithImpl(this._self, this._then);

  final AIChatId _self;
  final $Res Function(AIChatId) _then;

  /// Create a copy of AIChatId
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

/// Adds pattern-matching-related methods to [AIChatId].
extension AIChatIdPatterns on AIChatId {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AIChatId value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIChatId() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AIChatId value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatId():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AIChatId value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatId() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIChatId() when $default != null:
        return $default(_that.value);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatId():
        return $default(_that.value);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatId() when $default != null:
        return $default(_that.value);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AIChatId implements AIChatId {
  const _AIChatId({required this.value});

  @override
  final int value;

  /// Create a copy of AIChatId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIChatIdCopyWith<_AIChatId> get copyWith =>
      __$AIChatIdCopyWithImpl<_AIChatId>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIChatId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() {
    return 'AIChatId(value: $value)';
  }
}

/// @nodoc
abstract mixin class _$AIChatIdCopyWith<$Res>
    implements $AIChatIdCopyWith<$Res> {
  factory _$AIChatIdCopyWith(_AIChatId value, $Res Function(_AIChatId) _then) =
      __$AIChatIdCopyWithImpl;
  @override
  @useResult
  $Res call({int value});
}

/// @nodoc
class __$AIChatIdCopyWithImpl<$Res> implements _$AIChatIdCopyWith<$Res> {
  __$AIChatIdCopyWithImpl(this._self, this._then);

  final _AIChatId _self;
  final $Res Function(_AIChatId) _then;

  /// Create a copy of AIChatId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
  }) {
    return _then(_AIChatId(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$AIChatModel {
  AIChatId get id;
  Map<String, Map<String, String>> get tables;
  List<AIChatMessageModel> get messages;
  AIChatState get state;

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIChatModelCopyWith<AIChatModel> get copyWith =>
      _$AIChatModelCopyWithImpl<AIChatModel>(this as AIChatModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIChatModel &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other.tables, tables) &&
            const DeepCollectionEquality().equals(other.messages, messages) &&
            (identical(other.state, state) || other.state == state));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(tables),
      const DeepCollectionEquality().hash(messages),
      state);

  @override
  String toString() {
    return 'AIChatModel(id: $id, tables: $tables, messages: $messages, state: $state)';
  }
}

/// @nodoc
abstract mixin class $AIChatModelCopyWith<$Res> {
  factory $AIChatModelCopyWith(
          AIChatModel value, $Res Function(AIChatModel) _then) =
      _$AIChatModelCopyWithImpl;
  @useResult
  $Res call(
      {AIChatId id,
      Map<String, Map<String, String>> tables,
      List<AIChatMessageModel> messages,
      AIChatState state});

  $AIChatIdCopyWith<$Res> get id;
}

/// @nodoc
class _$AIChatModelCopyWithImpl<$Res> implements $AIChatModelCopyWith<$Res> {
  _$AIChatModelCopyWithImpl(this._self, this._then);

  final AIChatModel _self;
  final $Res Function(AIChatModel) _then;

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tables = null,
    Object? messages = null,
    Object? state = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as AIChatId,
      tables: null == tables
          ? _self.tables
          : tables // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, String>>,
      messages: null == messages
          ? _self.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AIChatMessageModel>,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as AIChatState,
    ));
  }

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AIChatIdCopyWith<$Res> get id {
    return $AIChatIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// Adds pattern-matching-related methods to [AIChatModel].
extension AIChatModelPatterns on AIChatModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AIChatModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIChatModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AIChatModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AIChatModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(AIChatId id, Map<String, Map<String, String>> tables,
            List<AIChatMessageModel> messages, AIChatState state)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIChatModel() when $default != null:
        return $default(_that.id, _that.tables, _that.messages, _that.state);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(AIChatId id, Map<String, Map<String, String>> tables,
            List<AIChatMessageModel> messages, AIChatState state)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatModel():
        return $default(_that.id, _that.tables, _that.messages, _that.state);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(AIChatId id, Map<String, Map<String, String>> tables,
            List<AIChatMessageModel> messages, AIChatState state)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatModel() when $default != null:
        return $default(_that.id, _that.tables, _that.messages, _that.state);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AIChatModel implements AIChatModel {
  const _AIChatModel(
      {required this.id,
      required final Map<String, Map<String, String>> tables,
      required final List<AIChatMessageModel> messages,
      required this.state})
      : _tables = tables,
        _messages = messages;

  @override
  final AIChatId id;
  final Map<String, Map<String, String>> _tables;
  @override
  Map<String, Map<String, String>> get tables {
    if (_tables is EqualUnmodifiableMapView) return _tables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_tables);
  }

  final List<AIChatMessageModel> _messages;
  @override
  List<AIChatMessageModel> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final AIChatState state;

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIChatModelCopyWith<_AIChatModel> get copyWith =>
      __$AIChatModelCopyWithImpl<_AIChatModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIChatModel &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._tables, _tables) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.state, state) || other.state == state));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_tables),
      const DeepCollectionEquality().hash(_messages),
      state);

  @override
  String toString() {
    return 'AIChatModel(id: $id, tables: $tables, messages: $messages, state: $state)';
  }
}

/// @nodoc
abstract mixin class _$AIChatModelCopyWith<$Res>
    implements $AIChatModelCopyWith<$Res> {
  factory _$AIChatModelCopyWith(
          _AIChatModel value, $Res Function(_AIChatModel) _then) =
      __$AIChatModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {AIChatId id,
      Map<String, Map<String, String>> tables,
      List<AIChatMessageModel> messages,
      AIChatState state});

  @override
  $AIChatIdCopyWith<$Res> get id;
}

/// @nodoc
class __$AIChatModelCopyWithImpl<$Res> implements _$AIChatModelCopyWith<$Res> {
  __$AIChatModelCopyWithImpl(this._self, this._then);

  final _AIChatModel _self;
  final $Res Function(_AIChatModel) _then;

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tables = null,
    Object? messages = null,
    Object? state = null,
  }) {
    return _then(_AIChatModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as AIChatId,
      tables: null == tables
          ? _self._tables
          : tables // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, String>>,
      messages: null == messages
          ? _self._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AIChatMessageModel>,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as AIChatState,
    ));
  }

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AIChatIdCopyWith<$Res> get id {
    return $AIChatIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// @nodoc
mixin _$AIChatMessageModel {
  AIRole get role;
  String get content;
  String? get thinking;
  String? get error;

  /// Create a copy of AIChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIChatMessageModelCopyWith<AIChatMessageModel> get copyWith =>
      _$AIChatMessageModelCopyWithImpl<AIChatMessageModel>(
          this as AIChatMessageModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIChatMessageModel &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.thinking, thinking) ||
                other.thinking == thinking) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, role, content, thinking, error);

  @override
  String toString() {
    return 'AIChatMessageModel(role: $role, content: $content, thinking: $thinking, error: $error)';
  }
}

/// @nodoc
abstract mixin class $AIChatMessageModelCopyWith<$Res> {
  factory $AIChatMessageModelCopyWith(
          AIChatMessageModel value, $Res Function(AIChatMessageModel) _then) =
      _$AIChatMessageModelCopyWithImpl;
  @useResult
  $Res call({AIRole role, String content, String? thinking, String? error});
}

/// @nodoc
class _$AIChatMessageModelCopyWithImpl<$Res>
    implements $AIChatMessageModelCopyWith<$Res> {
  _$AIChatMessageModelCopyWithImpl(this._self, this._then);

  final AIChatMessageModel _self;
  final $Res Function(AIChatMessageModel) _then;

  /// Create a copy of AIChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? thinking = freezed,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as AIRole,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      thinking: freezed == thinking
          ? _self.thinking
          : thinking // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AIChatMessageModel].
extension AIChatMessageModelPatterns on AIChatMessageModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AIChatMessageModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIChatMessageModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AIChatMessageModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatMessageModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AIChatMessageModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatMessageModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            AIRole role, String content, String? thinking, String? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIChatMessageModel() when $default != null:
        return $default(_that.role, _that.content, _that.thinking, _that.error);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            AIRole role, String content, String? thinking, String? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatMessageModel():
        return $default(_that.role, _that.content, _that.thinking, _that.error);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            AIRole role, String content, String? thinking, String? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatMessageModel() when $default != null:
        return $default(_that.role, _that.content, _that.thinking, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AIChatMessageModel implements AIChatMessageModel {
  const _AIChatMessageModel(
      {required this.role, required this.content, this.thinking, this.error});

  @override
  final AIRole role;
  @override
  final String content;
  @override
  final String? thinking;
  @override
  final String? error;

  /// Create a copy of AIChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIChatMessageModelCopyWith<_AIChatMessageModel> get copyWith =>
      __$AIChatMessageModelCopyWithImpl<_AIChatMessageModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIChatMessageModel &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.thinking, thinking) ||
                other.thinking == thinking) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, role, content, thinking, error);

  @override
  String toString() {
    return 'AIChatMessageModel(role: $role, content: $content, thinking: $thinking, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$AIChatMessageModelCopyWith<$Res>
    implements $AIChatMessageModelCopyWith<$Res> {
  factory _$AIChatMessageModelCopyWith(
          _AIChatMessageModel value, $Res Function(_AIChatMessageModel) _then) =
      __$AIChatMessageModelCopyWithImpl;
  @override
  @useResult
  $Res call({AIRole role, String content, String? thinking, String? error});
}

/// @nodoc
class __$AIChatMessageModelCopyWithImpl<$Res>
    implements _$AIChatMessageModelCopyWith<$Res> {
  __$AIChatMessageModelCopyWithImpl(this._self, this._then);

  final _AIChatMessageModel _self;
  final $Res Function(_AIChatMessageModel) _then;

  /// Create a copy of AIChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? thinking = freezed,
    Object? error = freezed,
  }) {
    return _then(_AIChatMessageModel(
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as AIRole,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      thinking: freezed == thinking
          ? _self.thinking
          : thinking // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$AIChatListModel {
  Map<AIChatId, AIChatModel> get chats;

  /// Create a copy of AIChatListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIChatListModelCopyWith<AIChatListModel> get copyWith =>
      _$AIChatListModelCopyWithImpl<AIChatListModel>(
          this as AIChatListModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIChatListModel &&
            const DeepCollectionEquality().equals(other.chats, chats));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(chats));

  @override
  String toString() {
    return 'AIChatListModel(chats: $chats)';
  }
}

/// @nodoc
abstract mixin class $AIChatListModelCopyWith<$Res> {
  factory $AIChatListModelCopyWith(
          AIChatListModel value, $Res Function(AIChatListModel) _then) =
      _$AIChatListModelCopyWithImpl;
  @useResult
  $Res call({Map<AIChatId, AIChatModel> chats});
}

/// @nodoc
class _$AIChatListModelCopyWithImpl<$Res>
    implements $AIChatListModelCopyWith<$Res> {
  _$AIChatListModelCopyWithImpl(this._self, this._then);

  final AIChatListModel _self;
  final $Res Function(AIChatListModel) _then;

  /// Create a copy of AIChatListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chats = null,
  }) {
    return _then(_self.copyWith(
      chats: null == chats
          ? _self.chats
          : chats // ignore: cast_nullable_to_non_nullable
              as Map<AIChatId, AIChatModel>,
    ));
  }
}

/// Adds pattern-matching-related methods to [AIChatListModel].
extension AIChatListModelPatterns on AIChatListModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AIChatListModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIChatListModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AIChatListModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatListModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AIChatListModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatListModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(Map<AIChatId, AIChatModel> chats)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIChatListModel() when $default != null:
        return $default(_that.chats);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(Map<AIChatId, AIChatModel> chats) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatListModel():
        return $default(_that.chats);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(Map<AIChatId, AIChatModel> chats)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIChatListModel() when $default != null:
        return $default(_that.chats);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AIChatListModel implements AIChatListModel {
  const _AIChatListModel({required final Map<AIChatId, AIChatModel> chats})
      : _chats = chats;

  final Map<AIChatId, AIChatModel> _chats;
  @override
  Map<AIChatId, AIChatModel> get chats {
    if (_chats is EqualUnmodifiableMapView) return _chats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_chats);
  }

  /// Create a copy of AIChatListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIChatListModelCopyWith<_AIChatListModel> get copyWith =>
      __$AIChatListModelCopyWithImpl<_AIChatListModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIChatListModel &&
            const DeepCollectionEquality().equals(other._chats, _chats));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_chats));

  @override
  String toString() {
    return 'AIChatListModel(chats: $chats)';
  }
}

/// @nodoc
abstract mixin class _$AIChatListModelCopyWith<$Res>
    implements $AIChatListModelCopyWith<$Res> {
  factory _$AIChatListModelCopyWith(
          _AIChatListModel value, $Res Function(_AIChatListModel) _then) =
      __$AIChatListModelCopyWithImpl;
  @override
  @useResult
  $Res call({Map<AIChatId, AIChatModel> chats});
}

/// @nodoc
class __$AIChatListModelCopyWithImpl<$Res>
    implements _$AIChatListModelCopyWith<$Res> {
  __$AIChatListModelCopyWithImpl(this._self, this._then);

  final _AIChatListModel _self;
  final $Res Function(_AIChatListModel) _then;

  /// Create a copy of AIChatListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? chats = null,
  }) {
    return _then(_AIChatListModel(
      chats: null == chats
          ? _self._chats
          : chats // ignore: cast_nullable_to_non_nullable
              as Map<AIChatId, AIChatModel>,
    ));
  }
}

/// @nodoc
mixin _$ExportFileNameResult {
  String get fileName;
  String? get desc;

  /// Create a copy of ExportFileNameResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExportFileNameResultCopyWith<ExportFileNameResult> get copyWith =>
      _$ExportFileNameResultCopyWithImpl<ExportFileNameResult>(
          this as ExportFileNameResult, _$identity);

  /// Serializes this ExportFileNameResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExportFileNameResult &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.desc, desc) || other.desc == desc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fileName, desc);

  @override
  String toString() {
    return 'ExportFileNameResult(fileName: $fileName, desc: $desc)';
  }
}

/// @nodoc
abstract mixin class $ExportFileNameResultCopyWith<$Res> {
  factory $ExportFileNameResultCopyWith(ExportFileNameResult value,
          $Res Function(ExportFileNameResult) _then) =
      _$ExportFileNameResultCopyWithImpl;
  @useResult
  $Res call({String fileName, String? desc});
}

/// @nodoc
class _$ExportFileNameResultCopyWithImpl<$Res>
    implements $ExportFileNameResultCopyWith<$Res> {
  _$ExportFileNameResultCopyWithImpl(this._self, this._then);

  final ExportFileNameResult _self;
  final $Res Function(ExportFileNameResult) _then;

  /// Create a copy of ExportFileNameResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? desc = freezed,
  }) {
    return _then(_self.copyWith(
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      desc: freezed == desc
          ? _self.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ExportFileNameResult].
extension ExportFileNameResultPatterns on ExportFileNameResult {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ExportFileNameResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExportFileNameResult() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ExportFileNameResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExportFileNameResult():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ExportFileNameResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExportFileNameResult() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String fileName, String? desc)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExportFileNameResult() when $default != null:
        return $default(_that.fileName, _that.desc);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String fileName, String? desc) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExportFileNameResult():
        return $default(_that.fileName, _that.desc);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String fileName, String? desc)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExportFileNameResult() when $default != null:
        return $default(_that.fileName, _that.desc);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ExportFileNameResult implements ExportFileNameResult {
  const _ExportFileNameResult({required this.fileName, this.desc});
  factory _ExportFileNameResult.fromJson(Map<String, dynamic> json) =>
      _$ExportFileNameResultFromJson(json);

  @override
  final String fileName;
  @override
  final String? desc;

  /// Create a copy of ExportFileNameResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExportFileNameResultCopyWith<_ExportFileNameResult> get copyWith =>
      __$ExportFileNameResultCopyWithImpl<_ExportFileNameResult>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExportFileNameResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExportFileNameResult &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.desc, desc) || other.desc == desc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fileName, desc);

  @override
  String toString() {
    return 'ExportFileNameResult(fileName: $fileName, desc: $desc)';
  }
}

/// @nodoc
abstract mixin class _$ExportFileNameResultCopyWith<$Res>
    implements $ExportFileNameResultCopyWith<$Res> {
  factory _$ExportFileNameResultCopyWith(_ExportFileNameResult value,
          $Res Function(_ExportFileNameResult) _then) =
      __$ExportFileNameResultCopyWithImpl;
  @override
  @useResult
  $Res call({String fileName, String? desc});
}

/// @nodoc
class __$ExportFileNameResultCopyWithImpl<$Res>
    implements _$ExportFileNameResultCopyWith<$Res> {
  __$ExportFileNameResultCopyWithImpl(this._self, this._then);

  final _ExportFileNameResult _self;
  final $Res Function(_ExportFileNameResult) _then;

  /// Create a copy of ExportFileNameResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? fileName = null,
    Object? desc = freezed,
  }) {
    return _then(_ExportFileNameResult(
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      desc: freezed == desc
          ? _self.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
