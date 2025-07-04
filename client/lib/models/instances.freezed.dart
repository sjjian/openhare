// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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

/// @nodoc

class _InstanceId with DiagnosticableTreeMixin implements InstanceId {
  const _InstanceId({required this.value});

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
  DateTime? get latestOpenAt;

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
      DateTime? latestOpenAt});

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
    Object? latestOpenAt = freezed,
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
      latestOpenAt: freezed == latestOpenAt
          ? _self.latestOpenAt
          : latestOpenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      this.latestOpenAt})
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
  final DateTime? latestOpenAt;

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
      DateTime? latestOpenAt});

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
    Object? latestOpenAt = freezed,
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
      latestOpenAt: freezed == latestOpenAt
          ? _self.latestOpenAt
          : latestOpenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      ..add(DiagnosticsProperty('key', key));
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
            (identical(other.key, key) || other.key == key));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(instances),
      currentPage,
      pageSize,
      count,
      key);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PaginationInstanceListModel(instances: $instances, currentPage: $currentPage, pageSize: $pageSize, count: $count, key: $key)';
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
      String key});
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
    ));
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
      required this.key})
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
      ..add(DiagnosticsProperty('key', key));
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
            (identical(other.key, key) || other.key == key));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_instances),
      currentPage,
      pageSize,
      count,
      key);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PaginationInstanceListModel(instances: $instances, currentPage: $currentPage, pageSize: $pageSize, count: $count, key: $key)';
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
      String key});
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
    ));
  }
}

// dart format on
