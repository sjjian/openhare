// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tasks.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskId {
  int get value;

  /// Create a copy of TaskId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TaskIdCopyWith<TaskId> get copyWith =>
      _$TaskIdCopyWithImpl<TaskId>(this as TaskId, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TaskId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() {
    return 'TaskId(value: $value)';
  }
}

/// @nodoc
abstract mixin class $TaskIdCopyWith<$Res> {
  factory $TaskIdCopyWith(TaskId value, $Res Function(TaskId) _then) =
      _$TaskIdCopyWithImpl;
  @useResult
  $Res call({int value});
}

/// @nodoc
class _$TaskIdCopyWithImpl<$Res> implements $TaskIdCopyWith<$Res> {
  _$TaskIdCopyWithImpl(this._self, this._then);

  final TaskId _self;
  final $Res Function(TaskId) _then;

  /// Create a copy of TaskId
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

/// Adds pattern-matching-related methods to [TaskId].
extension TaskIdPatterns on TaskId {
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
    TResult Function(_TaskId value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskId() when $default != null:
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
    TResult Function(_TaskId value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskId():
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
    TResult? Function(_TaskId value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskId() when $default != null:
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
      case _TaskId() when $default != null:
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
      case _TaskId():
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
      case _TaskId() when $default != null:
        return $default(_that.value);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _TaskId implements TaskId {
  const _TaskId({required this.value});

  @override
  final int value;

  /// Create a copy of TaskId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TaskIdCopyWith<_TaskId> get copyWith =>
      __$TaskIdCopyWithImpl<_TaskId>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TaskId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() {
    return 'TaskId(value: $value)';
  }
}

/// @nodoc
abstract mixin class _$TaskIdCopyWith<$Res> implements $TaskIdCopyWith<$Res> {
  factory _$TaskIdCopyWith(_TaskId value, $Res Function(_TaskId) _then) =
      __$TaskIdCopyWithImpl;
  @override
  @useResult
  $Res call({int value});
}

/// @nodoc
class __$TaskIdCopyWithImpl<$Res> implements _$TaskIdCopyWith<$Res> {
  __$TaskIdCopyWithImpl(this._self, this._then);

  final _TaskId _self;
  final $Res Function(_TaskId) _then;

  /// Create a copy of TaskId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
  }) {
    return _then(_TaskId(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$ExportDataParameters {
  InstanceId get instanceId; // 数据源实例ID
  String get schema; // 数据库schema
  String get query; // SQL查询语句
  String get fileDir; // 导出文件路径
  String get fileName;

  /// Create a copy of ExportDataParameters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExportDataParametersCopyWith<ExportDataParameters> get copyWith =>
      _$ExportDataParametersCopyWithImpl<ExportDataParameters>(
          this as ExportDataParameters, _$identity);

  /// Serializes this ExportDataParameters to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExportDataParameters &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.schema, schema) || other.schema == schema) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.fileDir, fileDir) || other.fileDir == fileDir) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, instanceId, schema, query, fileDir, fileName);

  @override
  String toString() {
    return 'ExportDataParameters(instanceId: $instanceId, schema: $schema, query: $query, fileDir: $fileDir, fileName: $fileName)';
  }
}

/// @nodoc
abstract mixin class $ExportDataParametersCopyWith<$Res> {
  factory $ExportDataParametersCopyWith(ExportDataParameters value,
          $Res Function(ExportDataParameters) _then) =
      _$ExportDataParametersCopyWithImpl;
  @useResult
  $Res call(
      {InstanceId instanceId,
      String schema,
      String query,
      String fileDir,
      String fileName});

  $InstanceIdCopyWith<$Res> get instanceId;
}

/// @nodoc
class _$ExportDataParametersCopyWithImpl<$Res>
    implements $ExportDataParametersCopyWith<$Res> {
  _$ExportDataParametersCopyWithImpl(this._self, this._then);

  final ExportDataParameters _self;
  final $Res Function(ExportDataParameters) _then;

  /// Create a copy of ExportDataParameters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instanceId = null,
    Object? schema = null,
    Object? query = null,
    Object? fileDir = null,
    Object? fileName = null,
  }) {
    return _then(_self.copyWith(
      instanceId: null == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as InstanceId,
      schema: null == schema
          ? _self.schema
          : schema // ignore: cast_nullable_to_non_nullable
              as String,
      query: null == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      fileDir: null == fileDir
          ? _self.fileDir
          : fileDir // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  /// Create a copy of ExportDataParameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<$Res> get instanceId {
    return $InstanceIdCopyWith<$Res>(_self.instanceId, (value) {
      return _then(_self.copyWith(instanceId: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ExportDataParameters].
extension ExportDataParametersPatterns on ExportDataParameters {
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
    TResult Function(_ExportDataParameters value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExportDataParameters() when $default != null:
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
    TResult Function(_ExportDataParameters value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExportDataParameters():
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
    TResult? Function(_ExportDataParameters value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExportDataParameters() when $default != null:
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
    TResult Function(InstanceId instanceId, String schema, String query,
            String fileDir, String fileName)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExportDataParameters() when $default != null:
        return $default(_that.instanceId, _that.schema, _that.query,
            _that.fileDir, _that.fileName);
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
    TResult Function(InstanceId instanceId, String schema, String query,
            String fileDir, String fileName)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExportDataParameters():
        return $default(_that.instanceId, _that.schema, _that.query,
            _that.fileDir, _that.fileName);
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
    TResult? Function(InstanceId instanceId, String schema, String query,
            String fileDir, String fileName)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExportDataParameters() when $default != null:
        return $default(_that.instanceId, _that.schema, _that.query,
            _that.fileDir, _that.fileName);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ExportDataParameters implements ExportDataParameters {
  const _ExportDataParameters(
      {required this.instanceId,
      required this.schema,
      required this.query,
      required this.fileDir,
      required this.fileName});
  factory _ExportDataParameters.fromJson(Map<String, dynamic> json) =>
      _$ExportDataParametersFromJson(json);

  @override
  final InstanceId instanceId;
// 数据源实例ID
  @override
  final String schema;
// 数据库schema
  @override
  final String query;
// SQL查询语句
  @override
  final String fileDir;
// 导出文件路径
  @override
  final String fileName;

  /// Create a copy of ExportDataParameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExportDataParametersCopyWith<_ExportDataParameters> get copyWith =>
      __$ExportDataParametersCopyWithImpl<_ExportDataParameters>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExportDataParametersToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExportDataParameters &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.schema, schema) || other.schema == schema) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.fileDir, fileDir) || other.fileDir == fileDir) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, instanceId, schema, query, fileDir, fileName);

  @override
  String toString() {
    return 'ExportDataParameters(instanceId: $instanceId, schema: $schema, query: $query, fileDir: $fileDir, fileName: $fileName)';
  }
}

/// @nodoc
abstract mixin class _$ExportDataParametersCopyWith<$Res>
    implements $ExportDataParametersCopyWith<$Res> {
  factory _$ExportDataParametersCopyWith(_ExportDataParameters value,
          $Res Function(_ExportDataParameters) _then) =
      __$ExportDataParametersCopyWithImpl;
  @override
  @useResult
  $Res call(
      {InstanceId instanceId,
      String schema,
      String query,
      String fileDir,
      String fileName});

  @override
  $InstanceIdCopyWith<$Res> get instanceId;
}

/// @nodoc
class __$ExportDataParametersCopyWithImpl<$Res>
    implements _$ExportDataParametersCopyWith<$Res> {
  __$ExportDataParametersCopyWithImpl(this._self, this._then);

  final _ExportDataParameters _self;
  final $Res Function(_ExportDataParameters) _then;

  /// Create a copy of ExportDataParameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? instanceId = null,
    Object? schema = null,
    Object? query = null,
    Object? fileDir = null,
    Object? fileName = null,
  }) {
    return _then(_ExportDataParameters(
      instanceId: null == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as InstanceId,
      schema: null == schema
          ? _self.schema
          : schema // ignore: cast_nullable_to_non_nullable
              as String,
      query: null == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      fileDir: null == fileDir
          ? _self.fileDir
          : fileDir // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  /// Create a copy of ExportDataParameters
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
mixin _$TaskModel {
  TaskId get id;
  TaskType get type;
  TaskStatus get status;
  double get progress;
  String? get currentStep;
  String? get progressMessage;
  DateTime get createdAt;
  DateTime get updatedAt;
  String? get errorMessage;
  String? get errorDetails;
  String? get parameters;
  String? get result;
  String? get desc;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TaskModelCopyWith<TaskModel> get copyWith =>
      _$TaskModelCopyWithImpl<TaskModel>(this as TaskModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TaskModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.progressMessage, progressMessage) ||
                other.progressMessage == progressMessage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.errorDetails, errorDetails) ||
                other.errorDetails == errorDetails) &&
            (identical(other.parameters, parameters) ||
                other.parameters == parameters) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.desc, desc) || other.desc == desc));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      status,
      progress,
      currentStep,
      progressMessage,
      createdAt,
      updatedAt,
      errorMessage,
      errorDetails,
      parameters,
      result,
      desc);

  @override
  String toString() {
    return 'TaskModel(id: $id, type: $type, status: $status, progress: $progress, currentStep: $currentStep, progressMessage: $progressMessage, createdAt: $createdAt, updatedAt: $updatedAt, errorMessage: $errorMessage, errorDetails: $errorDetails, parameters: $parameters, result: $result, desc: $desc)';
  }
}

/// @nodoc
abstract mixin class $TaskModelCopyWith<$Res> {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) _then) =
      _$TaskModelCopyWithImpl;
  @useResult
  $Res call(
      {TaskId id,
      TaskType type,
      TaskStatus status,
      double progress,
      String? currentStep,
      String? progressMessage,
      DateTime createdAt,
      DateTime updatedAt,
      String? errorMessage,
      String? errorDetails,
      String? parameters,
      String? result,
      String? desc});

  $TaskIdCopyWith<$Res> get id;
}

/// @nodoc
class _$TaskModelCopyWithImpl<$Res> implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._self, this._then);

  final TaskModel _self;
  final $Res Function(TaskModel) _then;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? status = null,
    Object? progress = null,
    Object? currentStep = freezed,
    Object? progressMessage = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? errorMessage = freezed,
    Object? errorDetails = freezed,
    Object? parameters = freezed,
    Object? result = freezed,
    Object? desc = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as TaskId,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as TaskType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      currentStep: freezed == currentStep
          ? _self.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as String?,
      progressMessage: freezed == progressMessage
          ? _self.progressMessage
          : progressMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorDetails: freezed == errorDetails
          ? _self.errorDetails
          : errorDetails // ignore: cast_nullable_to_non_nullable
              as String?,
      parameters: freezed == parameters
          ? _self.parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as String?,
      result: freezed == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as String?,
      desc: freezed == desc
          ? _self.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TaskIdCopyWith<$Res> get id {
    return $TaskIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// Adds pattern-matching-related methods to [TaskModel].
extension TaskModelPatterns on TaskModel {
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
    TResult Function(_TaskModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskModel() when $default != null:
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
    TResult Function(_TaskModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskModel():
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
    TResult? Function(_TaskModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskModel() when $default != null:
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
            TaskId id,
            TaskType type,
            TaskStatus status,
            double progress,
            String? currentStep,
            String? progressMessage,
            DateTime createdAt,
            DateTime updatedAt,
            String? errorMessage,
            String? errorDetails,
            String? parameters,
            String? result,
            String? desc)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskModel() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.status,
            _that.progress,
            _that.currentStep,
            _that.progressMessage,
            _that.createdAt,
            _that.updatedAt,
            _that.errorMessage,
            _that.errorDetails,
            _that.parameters,
            _that.result,
            _that.desc);
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
            TaskId id,
            TaskType type,
            TaskStatus status,
            double progress,
            String? currentStep,
            String? progressMessage,
            DateTime createdAt,
            DateTime updatedAt,
            String? errorMessage,
            String? errorDetails,
            String? parameters,
            String? result,
            String? desc)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskModel():
        return $default(
            _that.id,
            _that.type,
            _that.status,
            _that.progress,
            _that.currentStep,
            _that.progressMessage,
            _that.createdAt,
            _that.updatedAt,
            _that.errorMessage,
            _that.errorDetails,
            _that.parameters,
            _that.result,
            _that.desc);
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
            TaskId id,
            TaskType type,
            TaskStatus status,
            double progress,
            String? currentStep,
            String? progressMessage,
            DateTime createdAt,
            DateTime updatedAt,
            String? errorMessage,
            String? errorDetails,
            String? parameters,
            String? result,
            String? desc)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskModel() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.status,
            _that.progress,
            _that.currentStep,
            _that.progressMessage,
            _that.createdAt,
            _that.updatedAt,
            _that.errorMessage,
            _that.errorDetails,
            _that.parameters,
            _that.result,
            _that.desc);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _TaskModel extends TaskModel {
  const _TaskModel(
      {required this.id,
      required this.type,
      required this.status,
      required this.progress,
      this.currentStep,
      this.progressMessage,
      required this.createdAt,
      required this.updatedAt,
      this.errorMessage,
      this.errorDetails,
      this.parameters,
      this.result,
      this.desc})
      : super._();

  @override
  final TaskId id;
  @override
  final TaskType type;
  @override
  final TaskStatus status;
  @override
  final double progress;
  @override
  final String? currentStep;
  @override
  final String? progressMessage;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? errorMessage;
  @override
  final String? errorDetails;
  @override
  final String? parameters;
  @override
  final String? result;
  @override
  final String? desc;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TaskModelCopyWith<_TaskModel> get copyWith =>
      __$TaskModelCopyWithImpl<_TaskModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TaskModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.progressMessage, progressMessage) ||
                other.progressMessage == progressMessage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.errorDetails, errorDetails) ||
                other.errorDetails == errorDetails) &&
            (identical(other.parameters, parameters) ||
                other.parameters == parameters) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.desc, desc) || other.desc == desc));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      status,
      progress,
      currentStep,
      progressMessage,
      createdAt,
      updatedAt,
      errorMessage,
      errorDetails,
      parameters,
      result,
      desc);

  @override
  String toString() {
    return 'TaskModel(id: $id, type: $type, status: $status, progress: $progress, currentStep: $currentStep, progressMessage: $progressMessage, createdAt: $createdAt, updatedAt: $updatedAt, errorMessage: $errorMessage, errorDetails: $errorDetails, parameters: $parameters, result: $result, desc: $desc)';
  }
}

/// @nodoc
abstract mixin class _$TaskModelCopyWith<$Res>
    implements $TaskModelCopyWith<$Res> {
  factory _$TaskModelCopyWith(
          _TaskModel value, $Res Function(_TaskModel) _then) =
      __$TaskModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {TaskId id,
      TaskType type,
      TaskStatus status,
      double progress,
      String? currentStep,
      String? progressMessage,
      DateTime createdAt,
      DateTime updatedAt,
      String? errorMessage,
      String? errorDetails,
      String? parameters,
      String? result,
      String? desc});

  @override
  $TaskIdCopyWith<$Res> get id;
}

/// @nodoc
class __$TaskModelCopyWithImpl<$Res> implements _$TaskModelCopyWith<$Res> {
  __$TaskModelCopyWithImpl(this._self, this._then);

  final _TaskModel _self;
  final $Res Function(_TaskModel) _then;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? status = null,
    Object? progress = null,
    Object? currentStep = freezed,
    Object? progressMessage = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? errorMessage = freezed,
    Object? errorDetails = freezed,
    Object? parameters = freezed,
    Object? result = freezed,
    Object? desc = freezed,
  }) {
    return _then(_TaskModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as TaskId,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as TaskType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      currentStep: freezed == currentStep
          ? _self.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as String?,
      progressMessage: freezed == progressMessage
          ? _self.progressMessage
          : progressMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorDetails: freezed == errorDetails
          ? _self.errorDetails
          : errorDetails // ignore: cast_nullable_to_non_nullable
              as String?,
      parameters: freezed == parameters
          ? _self.parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as String?,
      result: freezed == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as String?,
      desc: freezed == desc
          ? _self.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TaskIdCopyWith<$Res> get id {
    return $TaskIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// @nodoc
mixin _$PaginationTaskListModel {
  List<TaskModel> get tasks;
  int get currentPage;
  int get pageSize;
  int get count;
  String get key;
  int get totalCount;
  TaskStatus? get status;
  TaskType? get type;

  /// Create a copy of PaginationTaskListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PaginationTaskListModelCopyWith<PaginationTaskListModel> get copyWith =>
      _$PaginationTaskListModelCopyWithImpl<PaginationTaskListModel>(
          this as PaginationTaskListModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PaginationTaskListModel &&
            const DeepCollectionEquality().equals(other.tasks, tasks) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(tasks),
      currentPage,
      pageSize,
      count,
      key,
      totalCount,
      status,
      type);

  @override
  String toString() {
    return 'PaginationTaskListModel(tasks: $tasks, currentPage: $currentPage, pageSize: $pageSize, count: $count, key: $key, totalCount: $totalCount, status: $status, type: $type)';
  }
}

/// @nodoc
abstract mixin class $PaginationTaskListModelCopyWith<$Res> {
  factory $PaginationTaskListModelCopyWith(PaginationTaskListModel value,
          $Res Function(PaginationTaskListModel) _then) =
      _$PaginationTaskListModelCopyWithImpl;
  @useResult
  $Res call(
      {List<TaskModel> tasks,
      int currentPage,
      int pageSize,
      int count,
      String key,
      int totalCount,
      TaskStatus? status,
      TaskType? type});
}

/// @nodoc
class _$PaginationTaskListModelCopyWithImpl<$Res>
    implements $PaginationTaskListModelCopyWith<$Res> {
  _$PaginationTaskListModelCopyWithImpl(this._self, this._then);

  final PaginationTaskListModel _self;
  final $Res Function(PaginationTaskListModel) _then;

  /// Create a copy of PaginationTaskListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tasks = null,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? count = null,
    Object? key = null,
    Object? totalCount = null,
    Object? status = freezed,
    Object? type = freezed,
  }) {
    return _then(_self.copyWith(
      tasks: null == tasks
          ? _self.tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<TaskModel>,
      currentPage: null == currentPage
          ? _self.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _self.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      count: null == count
          ? _self.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      totalCount: null == totalCount
          ? _self.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus?,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as TaskType?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PaginationTaskListModel].
extension PaginationTaskListModelPatterns on PaginationTaskListModel {
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
    TResult Function(_PaginationTaskListModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaginationTaskListModel() when $default != null:
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
    TResult Function(_PaginationTaskListModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaginationTaskListModel():
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
    TResult? Function(_PaginationTaskListModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaginationTaskListModel() when $default != null:
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
            List<TaskModel> tasks,
            int currentPage,
            int pageSize,
            int count,
            String key,
            int totalCount,
            TaskStatus? status,
            TaskType? type)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaginationTaskListModel() when $default != null:
        return $default(_that.tasks, _that.currentPage, _that.pageSize,
            _that.count, _that.key, _that.totalCount, _that.status, _that.type);
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
            List<TaskModel> tasks,
            int currentPage,
            int pageSize,
            int count,
            String key,
            int totalCount,
            TaskStatus? status,
            TaskType? type)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaginationTaskListModel():
        return $default(_that.tasks, _that.currentPage, _that.pageSize,
            _that.count, _that.key, _that.totalCount, _that.status, _that.type);
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
            List<TaskModel> tasks,
            int currentPage,
            int pageSize,
            int count,
            String key,
            int totalCount,
            TaskStatus? status,
            TaskType? type)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaginationTaskListModel() when $default != null:
        return $default(_that.tasks, _that.currentPage, _that.pageSize,
            _that.count, _that.key, _that.totalCount, _that.status, _that.type);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PaginationTaskListModel implements PaginationTaskListModel {
  const _PaginationTaskListModel(
      {required final List<TaskModel> tasks,
      required this.currentPage,
      required this.pageSize,
      required this.count,
      required this.key,
      required this.totalCount,
      this.status,
      this.type})
      : _tasks = tasks;

  final List<TaskModel> _tasks;
  @override
  List<TaskModel> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tasks);
  }

  @override
  final int currentPage;
  @override
  final int pageSize;
  @override
  final int count;
  @override
  final String key;
  @override
  final int totalCount;
  @override
  final TaskStatus? status;
  @override
  final TaskType? type;

  /// Create a copy of PaginationTaskListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PaginationTaskListModelCopyWith<_PaginationTaskListModel> get copyWith =>
      __$PaginationTaskListModelCopyWithImpl<_PaginationTaskListModel>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PaginationTaskListModel &&
            const DeepCollectionEquality().equals(other._tasks, _tasks) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_tasks),
      currentPage,
      pageSize,
      count,
      key,
      totalCount,
      status,
      type);

  @override
  String toString() {
    return 'PaginationTaskListModel(tasks: $tasks, currentPage: $currentPage, pageSize: $pageSize, count: $count, key: $key, totalCount: $totalCount, status: $status, type: $type)';
  }
}

/// @nodoc
abstract mixin class _$PaginationTaskListModelCopyWith<$Res>
    implements $PaginationTaskListModelCopyWith<$Res> {
  factory _$PaginationTaskListModelCopyWith(_PaginationTaskListModel value,
          $Res Function(_PaginationTaskListModel) _then) =
      __$PaginationTaskListModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<TaskModel> tasks,
      int currentPage,
      int pageSize,
      int count,
      String key,
      int totalCount,
      TaskStatus? status,
      TaskType? type});
}

/// @nodoc
class __$PaginationTaskListModelCopyWithImpl<$Res>
    implements _$PaginationTaskListModelCopyWith<$Res> {
  __$PaginationTaskListModelCopyWithImpl(this._self, this._then);

  final _PaginationTaskListModel _self;
  final $Res Function(_PaginationTaskListModel) _then;

  /// Create a copy of PaginationTaskListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? tasks = null,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? count = null,
    Object? key = null,
    Object? totalCount = null,
    Object? status = freezed,
    Object? type = freezed,
  }) {
    return _then(_PaginationTaskListModel(
      tasks: null == tasks
          ? _self._tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<TaskModel>,
      currentPage: null == currentPage
          ? _self.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _self.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      count: null == count
          ? _self.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      totalCount: null == totalCount
          ? _self.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus?,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as TaskType?,
    ));
  }
}

// dart format on
