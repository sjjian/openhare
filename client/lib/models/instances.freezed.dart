// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instances.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InstanceId implements DiagnosticableTreeMixin {
  int get value;

  /// Create a copy of InstanceId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<InstanceId> get copyWith =>
      _$InstanceIdCopyWithImpl<InstanceId>(this as InstanceId, _$identity);

  /// Serializes this InstanceId to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'InstanceId'))
      ..add(DiagnosticsProperty('value', value));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InstanceId &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'InstanceId(value: $value)';
  }
}

/// @nodoc
abstract mixin class $InstanceIdCopyWith<$Res> {
  factory $InstanceIdCopyWith(
          InstanceId value, $Res Function(InstanceId) _then) =
      _$InstanceIdCopyWithImpl;
  @useResult
  $Res call({int value});
}

/// @nodoc
class _$InstanceIdCopyWithImpl<$Res> implements $InstanceIdCopyWith<$Res> {
  _$InstanceIdCopyWithImpl(this._self, this._then);

  final InstanceId _self;
  final $Res Function(InstanceId) _then;

  /// Create a copy of InstanceId
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

/// Adds pattern-matching-related methods to [InstanceId].
extension InstanceIdPatterns on InstanceId {
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
    TResult Function(_InstanceId value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InstanceId() when $default != null:
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
    TResult Function(_InstanceId value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstanceId():
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
    TResult? Function(_InstanceId value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstanceId() when $default != null:
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
      case _InstanceId() when $default != null:
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
      case _InstanceId():
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
      case _InstanceId() when $default != null:
        return $default(_that.value);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _InstanceId with DiagnosticableTreeMixin implements InstanceId {
  const _InstanceId({required this.value});
  factory _InstanceId.fromJson(Map<String, dynamic> json) =>
      _$InstanceIdFromJson(json);

  @override
  final int value;

  /// Create a copy of InstanceId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InstanceIdCopyWith<_InstanceId> get copyWith =>
      __$InstanceIdCopyWithImpl<_InstanceId>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InstanceIdToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'InstanceId'))
      ..add(DiagnosticsProperty('value', value));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InstanceId &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'InstanceId(value: $value)';
  }
}

/// @nodoc
abstract mixin class _$InstanceIdCopyWith<$Res>
    implements $InstanceIdCopyWith<$Res> {
  factory _$InstanceIdCopyWith(
          _InstanceId value, $Res Function(_InstanceId) _then) =
      __$InstanceIdCopyWithImpl;
  @override
  @useResult
  $Res call({int value});
}

/// @nodoc
class __$InstanceIdCopyWithImpl<$Res> implements _$InstanceIdCopyWith<$Res> {
  __$InstanceIdCopyWithImpl(this._self, this._then);

  final _InstanceId _self;
  final $Res Function(_InstanceId) _then;

  /// Create a copy of InstanceId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
  }) {
    return _then(_InstanceId(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$InstanceModel implements DiagnosticableTreeMixin {
  InstanceId get id;
  DatabaseType get dbType;
  String get name;
  String get host;
  int? get port;
  String get user;
  String get password;
  String get desc;
  Map<String, String> get custom;
  List<String> get initQuerys;
  List<String> get activeSchemas;
  DateTime get createdAt;
  DateTime get latestOpenAt;

  /// Create a copy of InstanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InstanceModelCopyWith<InstanceModel> get copyWith =>
      _$InstanceModelCopyWithImpl<InstanceModel>(
          this as InstanceModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'InstanceModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('dbType', dbType))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('host', host))
      ..add(DiagnosticsProperty('port', port))
      ..add(DiagnosticsProperty('user', user))
      ..add(DiagnosticsProperty('password', password))
      ..add(DiagnosticsProperty('desc', desc))
      ..add(DiagnosticsProperty('custom', custom))
      ..add(DiagnosticsProperty('initQuerys', initQuerys))
      ..add(DiagnosticsProperty('activeSchemas', activeSchemas))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('latestOpenAt', latestOpenAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InstanceModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dbType, dbType) || other.dbType == dbType) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.desc, desc) || other.desc == desc) &&
            const DeepCollectionEquality().equals(other.custom, custom) &&
            const DeepCollectionEquality()
                .equals(other.initQuerys, initQuerys) &&
            const DeepCollectionEquality()
                .equals(other.activeSchemas, activeSchemas) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.latestOpenAt, latestOpenAt) ||
                other.latestOpenAt == latestOpenAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      dbType,
      name,
      host,
      port,
      user,
      password,
      desc,
      const DeepCollectionEquality().hash(custom),
      const DeepCollectionEquality().hash(initQuerys),
      const DeepCollectionEquality().hash(activeSchemas),
      createdAt,
      latestOpenAt);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'InstanceModel(id: $id, dbType: $dbType, name: $name, host: $host, port: $port, user: $user, password: $password, desc: $desc, custom: $custom, initQuerys: $initQuerys, activeSchemas: $activeSchemas, createdAt: $createdAt, latestOpenAt: $latestOpenAt)';
  }
}

/// @nodoc
abstract mixin class $InstanceModelCopyWith<$Res> {
  factory $InstanceModelCopyWith(
          InstanceModel value, $Res Function(InstanceModel) _then) =
      _$InstanceModelCopyWithImpl;
  @useResult
  $Res call(
      {InstanceId id,
      DatabaseType dbType,
      String name,
      String host,
      int? port,
      String user,
      String password,
      String desc,
      Map<String, String> custom,
      List<String> initQuerys,
      List<String> activeSchemas,
      DateTime createdAt,
      DateTime latestOpenAt});

  $InstanceIdCopyWith<$Res> get id;
}

/// @nodoc
class _$InstanceModelCopyWithImpl<$Res>
    implements $InstanceModelCopyWith<$Res> {
  _$InstanceModelCopyWithImpl(this._self, this._then);

  final InstanceModel _self;
  final $Res Function(InstanceModel) _then;

  /// Create a copy of InstanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dbType = null,
    Object? name = null,
    Object? host = null,
    Object? port = freezed,
    Object? user = null,
    Object? password = null,
    Object? desc = null,
    Object? custom = null,
    Object? initQuerys = null,
    Object? activeSchemas = null,
    Object? createdAt = null,
    Object? latestOpenAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as InstanceId,
      dbType: null == dbType
          ? _self.dbType
          : dbType // ignore: cast_nullable_to_non_nullable
              as DatabaseType,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      host: null == host
          ? _self.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      port: freezed == port
          ? _self.port
          : port // ignore: cast_nullable_to_non_nullable
              as int?,
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      desc: null == desc
          ? _self.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      custom: null == custom
          ? _self.custom
          : custom // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      initQuerys: null == initQuerys
          ? _self.initQuerys
          : initQuerys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activeSchemas: null == activeSchemas
          ? _self.activeSchemas
          : activeSchemas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      latestOpenAt: null == latestOpenAt
          ? _self.latestOpenAt
          : latestOpenAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }

  /// Create a copy of InstanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<$Res> get id {
    return $InstanceIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// Adds pattern-matching-related methods to [InstanceModel].
extension InstanceModelPatterns on InstanceModel {
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
    TResult Function(_InstanceModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InstanceModel() when $default != null:
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
    TResult Function(_InstanceModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstanceModel():
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
    TResult? Function(_InstanceModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstanceModel() when $default != null:
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
            InstanceId id,
            DatabaseType dbType,
            String name,
            String host,
            int? port,
            String user,
            String password,
            String desc,
            Map<String, String> custom,
            List<String> initQuerys,
            List<String> activeSchemas,
            DateTime createdAt,
            DateTime latestOpenAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InstanceModel() when $default != null:
        return $default(
            _that.id,
            _that.dbType,
            _that.name,
            _that.host,
            _that.port,
            _that.user,
            _that.password,
            _that.desc,
            _that.custom,
            _that.initQuerys,
            _that.activeSchemas,
            _that.createdAt,
            _that.latestOpenAt);
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
            InstanceId id,
            DatabaseType dbType,
            String name,
            String host,
            int? port,
            String user,
            String password,
            String desc,
            Map<String, String> custom,
            List<String> initQuerys,
            List<String> activeSchemas,
            DateTime createdAt,
            DateTime latestOpenAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstanceModel():
        return $default(
            _that.id,
            _that.dbType,
            _that.name,
            _that.host,
            _that.port,
            _that.user,
            _that.password,
            _that.desc,
            _that.custom,
            _that.initQuerys,
            _that.activeSchemas,
            _that.createdAt,
            _that.latestOpenAt);
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
            InstanceId id,
            DatabaseType dbType,
            String name,
            String host,
            int? port,
            String user,
            String password,
            String desc,
            Map<String, String> custom,
            List<String> initQuerys,
            List<String> activeSchemas,
            DateTime createdAt,
            DateTime latestOpenAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstanceModel() when $default != null:
        return $default(
            _that.id,
            _that.dbType,
            _that.name,
            _that.host,
            _that.port,
            _that.user,
            _that.password,
            _that.desc,
            _that.custom,
            _that.initQuerys,
            _that.activeSchemas,
            _that.createdAt,
            _that.latestOpenAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _InstanceModel extends InstanceModel with DiagnosticableTreeMixin {
  const _InstanceModel(
      {required this.id,
      required this.dbType,
      required this.name,
      required this.host,
      this.port,
      required this.user,
      required this.password,
      required this.desc,
      required final Map<String, String> custom,
      required final List<String> initQuerys,
      required final List<String> activeSchemas,
      required this.createdAt,
      required this.latestOpenAt})
      : _custom = custom,
        _initQuerys = initQuerys,
        _activeSchemas = activeSchemas,
        super._();

  @override
  final InstanceId id;
  @override
  final DatabaseType dbType;
  @override
  final String name;
  @override
  final String host;
  @override
  final int? port;
  @override
  final String user;
  @override
  final String password;
  @override
  final String desc;
  final Map<String, String> _custom;
  @override
  Map<String, String> get custom {
    if (_custom is EqualUnmodifiableMapView) return _custom;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_custom);
  }

  final List<String> _initQuerys;
  @override
  List<String> get initQuerys {
    if (_initQuerys is EqualUnmodifiableListView) return _initQuerys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_initQuerys);
  }

  final List<String> _activeSchemas;
  @override
  List<String> get activeSchemas {
    if (_activeSchemas is EqualUnmodifiableListView) return _activeSchemas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeSchemas);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime latestOpenAt;

  /// Create a copy of InstanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InstanceModelCopyWith<_InstanceModel> get copyWith =>
      __$InstanceModelCopyWithImpl<_InstanceModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'InstanceModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('dbType', dbType))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('host', host))
      ..add(DiagnosticsProperty('port', port))
      ..add(DiagnosticsProperty('user', user))
      ..add(DiagnosticsProperty('password', password))
      ..add(DiagnosticsProperty('desc', desc))
      ..add(DiagnosticsProperty('custom', custom))
      ..add(DiagnosticsProperty('initQuerys', initQuerys))
      ..add(DiagnosticsProperty('activeSchemas', activeSchemas))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('latestOpenAt', latestOpenAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InstanceModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dbType, dbType) || other.dbType == dbType) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.desc, desc) || other.desc == desc) &&
            const DeepCollectionEquality().equals(other._custom, _custom) &&
            const DeepCollectionEquality()
                .equals(other._initQuerys, _initQuerys) &&
            const DeepCollectionEquality()
                .equals(other._activeSchemas, _activeSchemas) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.latestOpenAt, latestOpenAt) ||
                other.latestOpenAt == latestOpenAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      dbType,
      name,
      host,
      port,
      user,
      password,
      desc,
      const DeepCollectionEquality().hash(_custom),
      const DeepCollectionEquality().hash(_initQuerys),
      const DeepCollectionEquality().hash(_activeSchemas),
      createdAt,
      latestOpenAt);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'InstanceModel(id: $id, dbType: $dbType, name: $name, host: $host, port: $port, user: $user, password: $password, desc: $desc, custom: $custom, initQuerys: $initQuerys, activeSchemas: $activeSchemas, createdAt: $createdAt, latestOpenAt: $latestOpenAt)';
  }
}

/// @nodoc
abstract mixin class _$InstanceModelCopyWith<$Res>
    implements $InstanceModelCopyWith<$Res> {
  factory _$InstanceModelCopyWith(
          _InstanceModel value, $Res Function(_InstanceModel) _then) =
      __$InstanceModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {InstanceId id,
      DatabaseType dbType,
      String name,
      String host,
      int? port,
      String user,
      String password,
      String desc,
      Map<String, String> custom,
      List<String> initQuerys,
      List<String> activeSchemas,
      DateTime createdAt,
      DateTime latestOpenAt});

  @override
  $InstanceIdCopyWith<$Res> get id;
}

/// @nodoc
class __$InstanceModelCopyWithImpl<$Res>
    implements _$InstanceModelCopyWith<$Res> {
  __$InstanceModelCopyWithImpl(this._self, this._then);

  final _InstanceModel _self;
  final $Res Function(_InstanceModel) _then;

  /// Create a copy of InstanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? dbType = null,
    Object? name = null,
    Object? host = null,
    Object? port = freezed,
    Object? user = null,
    Object? password = null,
    Object? desc = null,
    Object? custom = null,
    Object? initQuerys = null,
    Object? activeSchemas = null,
    Object? createdAt = null,
    Object? latestOpenAt = null,
  }) {
    return _then(_InstanceModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as InstanceId,
      dbType: null == dbType
          ? _self.dbType
          : dbType // ignore: cast_nullable_to_non_nullable
              as DatabaseType,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      host: null == host
          ? _self.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      port: freezed == port
          ? _self.port
          : port // ignore: cast_nullable_to_non_nullable
              as int?,
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      desc: null == desc
          ? _self.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      custom: null == custom
          ? _self._custom
          : custom // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      initQuerys: null == initQuerys
          ? _self._initQuerys
          : initQuerys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activeSchemas: null == activeSchemas
          ? _self._activeSchemas
          : activeSchemas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      latestOpenAt: null == latestOpenAt
          ? _self.latestOpenAt
          : latestOpenAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }

  /// Create a copy of InstanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<$Res> get id {
    return $InstanceIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// @nodoc
mixin _$PaginationInstanceListModel implements DiagnosticableTreeMixin {
  List<InstanceModel> get instances;
  int get currentPage;
  int get pageSize;
  int get count;
  String get key;
  int get totalCount;

  /// Create a copy of PaginationInstanceListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PaginationInstanceListModelCopyWith<PaginationInstanceListModel>
      get copyWith => _$PaginationInstanceListModelCopyWithImpl<
              PaginationInstanceListModel>(
          this as PaginationInstanceListModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PaginationInstanceListModel'))
      ..add(DiagnosticsProperty('instances', instances))
      ..add(DiagnosticsProperty('currentPage', currentPage))
      ..add(DiagnosticsProperty('pageSize', pageSize))
      ..add(DiagnosticsProperty('count', count))
      ..add(DiagnosticsProperty('key', key))
      ..add(DiagnosticsProperty('totalCount', totalCount));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PaginationInstanceListModel &&
            const DeepCollectionEquality().equals(other.instances, instances) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(instances),
      currentPage,
      pageSize,
      count,
      key,
      totalCount);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PaginationInstanceListModel(instances: $instances, currentPage: $currentPage, pageSize: $pageSize, count: $count, key: $key, totalCount: $totalCount)';
  }
}

/// @nodoc
abstract mixin class $PaginationInstanceListModelCopyWith<$Res> {
  factory $PaginationInstanceListModelCopyWith(
          PaginationInstanceListModel value,
          $Res Function(PaginationInstanceListModel) _then) =
      _$PaginationInstanceListModelCopyWithImpl;
  @useResult
  $Res call(
      {List<InstanceModel> instances,
      int currentPage,
      int pageSize,
      int count,
      String key,
      int totalCount});
}

/// @nodoc
class _$PaginationInstanceListModelCopyWithImpl<$Res>
    implements $PaginationInstanceListModelCopyWith<$Res> {
  _$PaginationInstanceListModelCopyWithImpl(this._self, this._then);

  final PaginationInstanceListModel _self;
  final $Res Function(PaginationInstanceListModel) _then;

  /// Create a copy of PaginationInstanceListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instances = null,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? count = null,
    Object? key = null,
    Object? totalCount = null,
  }) {
    return _then(_self.copyWith(
      instances: null == instances
          ? _self.instances
          : instances // ignore: cast_nullable_to_non_nullable
              as List<InstanceModel>,
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
    ));
  }
}

/// Adds pattern-matching-related methods to [PaginationInstanceListModel].
extension PaginationInstanceListModelPatterns on PaginationInstanceListModel {
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
    TResult Function(_PaginationInstanceListModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaginationInstanceListModel() when $default != null:
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
    TResult Function(_PaginationInstanceListModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaginationInstanceListModel():
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
    TResult? Function(_PaginationInstanceListModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaginationInstanceListModel() when $default != null:
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
    TResult Function(List<InstanceModel> instances, int currentPage,
            int pageSize, int count, String key, int totalCount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaginationInstanceListModel() when $default != null:
        return $default(_that.instances, _that.currentPage, _that.pageSize,
            _that.count, _that.key, _that.totalCount);
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
    TResult Function(List<InstanceModel> instances, int currentPage,
            int pageSize, int count, String key, int totalCount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaginationInstanceListModel():
        return $default(_that.instances, _that.currentPage, _that.pageSize,
            _that.count, _that.key, _that.totalCount);
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
    TResult? Function(List<InstanceModel> instances, int currentPage,
            int pageSize, int count, String key, int totalCount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaginationInstanceListModel() when $default != null:
        return $default(_that.instances, _that.currentPage, _that.pageSize,
            _that.count, _that.key, _that.totalCount);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PaginationInstanceListModel
    with DiagnosticableTreeMixin
    implements PaginationInstanceListModel {
  const _PaginationInstanceListModel(
      {required final List<InstanceModel> instances,
      required this.currentPage,
      required this.pageSize,
      required this.count,
      required this.key,
      required this.totalCount})
      : _instances = instances;

  final List<InstanceModel> _instances;
  @override
  List<InstanceModel> get instances {
    if (_instances is EqualUnmodifiableListView) return _instances;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_instances);
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

  /// Create a copy of PaginationInstanceListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PaginationInstanceListModelCopyWith<_PaginationInstanceListModel>
      get copyWith => __$PaginationInstanceListModelCopyWithImpl<
          _PaginationInstanceListModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PaginationInstanceListModel'))
      ..add(DiagnosticsProperty('instances', instances))
      ..add(DiagnosticsProperty('currentPage', currentPage))
      ..add(DiagnosticsProperty('pageSize', pageSize))
      ..add(DiagnosticsProperty('count', count))
      ..add(DiagnosticsProperty('key', key))
      ..add(DiagnosticsProperty('totalCount', totalCount));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PaginationInstanceListModel &&
            const DeepCollectionEquality()
                .equals(other._instances, _instances) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_instances),
      currentPage,
      pageSize,
      count,
      key,
      totalCount);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PaginationInstanceListModel(instances: $instances, currentPage: $currentPage, pageSize: $pageSize, count: $count, key: $key, totalCount: $totalCount)';
  }
}

/// @nodoc
abstract mixin class _$PaginationInstanceListModelCopyWith<$Res>
    implements $PaginationInstanceListModelCopyWith<$Res> {
  factory _$PaginationInstanceListModelCopyWith(
          _PaginationInstanceListModel value,
          $Res Function(_PaginationInstanceListModel) _then) =
      __$PaginationInstanceListModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<InstanceModel> instances,
      int currentPage,
      int pageSize,
      int count,
      String key,
      int totalCount});
}

/// @nodoc
class __$PaginationInstanceListModelCopyWithImpl<$Res>
    implements _$PaginationInstanceListModelCopyWith<$Res> {
  __$PaginationInstanceListModelCopyWithImpl(this._self, this._then);

  final _PaginationInstanceListModel _self;
  final $Res Function(_PaginationInstanceListModel) _then;

  /// Create a copy of PaginationInstanceListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? instances = null,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? count = null,
    Object? key = null,
    Object? totalCount = null,
  }) {
    return _then(_PaginationInstanceListModel(
      instances: null == instances
          ? _self._instances
          : instances // ignore: cast_nullable_to_non_nullable
              as List<InstanceModel>,
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
    ));
  }
}

/// @nodoc
mixin _$InstanceMetadataModel implements DiagnosticableTreeMixin {
  InstanceId get instanceId;
  StateValue<List<MetaDataNode>> get metadata;

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InstanceMetadataModelCopyWith<InstanceMetadataModel> get copyWith =>
      _$InstanceMetadataModelCopyWithImpl<InstanceMetadataModel>(
          this as InstanceMetadataModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'InstanceMetadataModel'))
      ..add(DiagnosticsProperty('instanceId', instanceId))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InstanceMetadataModel &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, instanceId, metadata);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'InstanceMetadataModel(instanceId: $instanceId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $InstanceMetadataModelCopyWith<$Res> {
  factory $InstanceMetadataModelCopyWith(InstanceMetadataModel value,
          $Res Function(InstanceMetadataModel) _then) =
      _$InstanceMetadataModelCopyWithImpl;
  @useResult
  $Res call({InstanceId instanceId, StateValue<List<MetaDataNode>> metadata});

  $InstanceIdCopyWith<$Res> get instanceId;
}

/// @nodoc
class _$InstanceMetadataModelCopyWithImpl<$Res>
    implements $InstanceMetadataModelCopyWith<$Res> {
  _$InstanceMetadataModelCopyWithImpl(this._self, this._then);

  final InstanceMetadataModel _self;
  final $Res Function(InstanceMetadataModel) _then;

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instanceId = null,
    Object? metadata = null,
  }) {
    return _then(_self.copyWith(
      instanceId: null == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as InstanceId,
      metadata: null == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as StateValue<List<MetaDataNode>>,
    ));
  }

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<$Res> get instanceId {
    return $InstanceIdCopyWith<$Res>(_self.instanceId, (value) {
      return _then(_self.copyWith(instanceId: value));
    });
  }
}

/// Adds pattern-matching-related methods to [InstanceMetadataModel].
extension InstanceMetadataModelPatterns on InstanceMetadataModel {
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
    TResult Function(_InstanceMetadataModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InstanceMetadataModel() when $default != null:
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
    TResult Function(_InstanceMetadataModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstanceMetadataModel():
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
    TResult? Function(_InstanceMetadataModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstanceMetadataModel() when $default != null:
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
            InstanceId instanceId, StateValue<List<MetaDataNode>> metadata)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InstanceMetadataModel() when $default != null:
        return $default(_that.instanceId, _that.metadata);
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
            InstanceId instanceId, StateValue<List<MetaDataNode>> metadata)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstanceMetadataModel():
        return $default(_that.instanceId, _that.metadata);
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
            InstanceId instanceId, StateValue<List<MetaDataNode>> metadata)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstanceMetadataModel() when $default != null:
        return $default(_that.instanceId, _that.metadata);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _InstanceMetadataModel
    with DiagnosticableTreeMixin
    implements InstanceMetadataModel {
  const _InstanceMetadataModel(
      {required this.instanceId, required this.metadata});

  @override
  final InstanceId instanceId;
  @override
  final StateValue<List<MetaDataNode>> metadata;

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InstanceMetadataModelCopyWith<_InstanceMetadataModel> get copyWith =>
      __$InstanceMetadataModelCopyWithImpl<_InstanceMetadataModel>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'InstanceMetadataModel'))
      ..add(DiagnosticsProperty('instanceId', instanceId))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InstanceMetadataModel &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, instanceId, metadata);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'InstanceMetadataModel(instanceId: $instanceId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$InstanceMetadataModelCopyWith<$Res>
    implements $InstanceMetadataModelCopyWith<$Res> {
  factory _$InstanceMetadataModelCopyWith(_InstanceMetadataModel value,
          $Res Function(_InstanceMetadataModel) _then) =
      __$InstanceMetadataModelCopyWithImpl;
  @override
  @useResult
  $Res call({InstanceId instanceId, StateValue<List<MetaDataNode>> metadata});

  @override
  $InstanceIdCopyWith<$Res> get instanceId;
}

/// @nodoc
class __$InstanceMetadataModelCopyWithImpl<$Res>
    implements _$InstanceMetadataModelCopyWith<$Res> {
  __$InstanceMetadataModelCopyWithImpl(this._self, this._then);

  final _InstanceMetadataModel _self;
  final $Res Function(_InstanceMetadataModel) _then;

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? instanceId = null,
    Object? metadata = null,
  }) {
    return _then(_InstanceMetadataModel(
      instanceId: null == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as InstanceId,
      metadata: null == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as StateValue<List<MetaDataNode>>,
    ));
  }

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<$Res> get instanceId {
    return $InstanceIdCopyWith<$Res>(_self.instanceId, (value) {
      return _then(_self.copyWith(instanceId: value));
    });
  }
}

// dart format on
