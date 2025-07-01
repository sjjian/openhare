import 'package:client/models/instances.dart';
import 'package:client/repositories/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';
import 'package:client/repositories/repo.dart';
import 'package:client/utils/active_set.dart';
import 'package:db_driver/db_driver.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'instances.g.dart';

@Entity()
class InstanceStorage {
  @Id()
  int id;

  @Transient()
  DatabaseType dbType;

  int get stDbType => dbType.index;

  set stDbType(int value) {
    dbType = DatabaseType.values[value];
  }

  String name;
  String host;
  int? port;
  String user;
  String password;
  String desc;

  @Transient()
  Map<String, String> custom = {};

  String get stCustom => jsonEncode(custom);

  set stCustom(String value) {
    custom =
        jsonDecode(value).map((key, value) => MapEntry(key, value.toString()));
  }

  List<String> initQuerys;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime? latestOpenAt;

  @Transient()
  ConnectValue get connectValue => ConnectValue(
      name: name,
      host: host,
      port: port,
      user: user,
      password: password,
      desc: desc,
      custom: custom,
      initQuerys: initQuerys);

  @Transient()
  ActiveSet<String> activeSchemas;
  List<String> get stActiveSchemas => activeSchemas.toList();

  set stActiveSchemas(List<String> value) {
    activeSchemas = ActiveSet<String>(value);
  }

  InstanceStorage({
    this.id = 0,
    required int stDbType,
    required this.name,
    required this.host,
    this.port,
    required this.user,
    required this.password,
    required this.desc,
    required String stCustom,
    required this.initQuerys,
    ActiveSet<String>? activeSchemas,
    DateTime? createdAt,
    DateTime? latestOpenAt,
  })  : activeSchemas = activeSchemas ?? ActiveSet<String>(List.empty()),
        dbType = DatabaseType.values[stDbType],
        createdAt = createdAt ?? DateTime.now();

  InstanceStorage.one({
    this.id = 0,
    required this.dbType,
    required ConnectValue connectValue,
    ActiveSet<String>? activeSchemas,
  })  : name = connectValue.name,
        host = connectValue.host,
        port = connectValue.port,
        user = connectValue.user,
        password = connectValue.password,
        desc = connectValue.desc,
        custom = connectValue.custom,
        initQuerys = connectValue.initQuerys,
        activeSchemas = activeSchemas ?? ActiveSet<String>(List.empty()),
        createdAt = DateTime.now();

  InstanceStorage.fromModel(InstanceModel model)
      : id = model.id.value,
        dbType = model.dbType,
        name = model.name,
        host = model.host,
        port = model.port,
        user = model.user,
        password = model.password,
        desc = model.desc,
        custom = model.custom,
        initQuerys = model.initQuerys,
        activeSchemas = ActiveSet<String>(model.activeSchemas),
        createdAt = model.createdAt,
        latestOpenAt = model.latestOpenAt;

  InstanceModel toModel() => InstanceModel(
        id: InstanceId(value: id),
        dbType: dbType,
        name: name,
        host: host,
        port: port,
        user: user,
        password: password,
        desc: desc,
        custom: custom,
        initQuerys: initQuerys,
        activeSchemas: activeSchemas.toList(),
        createdAt: createdAt,
        latestOpenAt: latestOpenAt,
      );
}

class InstanceRepoImpl extends InstanceRepo {
  final ObjectBox ob;
  final Box<InstanceStorage> _instanceBox;

  InstanceRepoImpl(this.ob) : _instanceBox = ob.store.box();

  @override
  Future<void> add(InstanceModel instance) async {
    await _instanceBox.putAsync(InstanceStorage.fromModel(instance));
  }

  @override
  Future<void> update(InstanceModel instance) async {
    _instanceBox.putAsync(InstanceStorage.fromModel(instance));
  }

  @override
  Future<void> delete(InstanceId id) => _instanceBox.removeAsync(id.value);

  @override
// todo: aync
  bool isInstanceExist(String name) {
    final instance = getInstanceByName(name);
    return instance != null;
  }

  @override
// todo: aync
  InstanceModel? getInstanceByName(String name) {
    final build =
        _instanceBox.query(InstanceStorage_.name.equals(name)).build();
    return build.findFirst()?.toModel();
  }

  @override
// todo: 替换 getInstance
  InstanceModel? getInstanceById(InstanceId id) {
    return _instanceBox.get(id.value)?.toModel();
  }

  @override
// todo: aync
  PaginationInstanceListModel search(String key, {int? pageNumber, int? pageSize}) {
    final build =
        _instanceBox.query(InstanceStorage_.name.contains(key)).build();
    build.limit = (pageSize ?? 10);
    build.offset = ((pageNumber ?? 1) - 1) * (pageSize ?? 10);
    final instances = build.find();
    
    return PaginationInstanceListModel(
      count: count(key),
      pageSize: pageSize ?? 10,
      currentPage: pageNumber ?? 1,
      instances: instances.map((e) => e.toModel()).toList(),
    );
  }

  @override
// todo: aync
  int count(String key) {
    final build =
        _instanceBox.query(InstanceStorage_.name.contains(key)).build();
    return build.count();
  }

  @override
  List<InstanceModel> getActiveInstances(int top) {
    final build = _instanceBox
        .query(InstanceStorage_.latestOpenAt.notNull())
        .order(InstanceStorage_.latestOpenAt, flags: Order.descending)
        .build();
    build.limit = top;
    return build.find().map((e) => e.toModel()).toList();
  }

  @override
  Future<void> addActiveInstance(InstanceId id) async {
    final instance = _instanceBox.get(id.value);
    instance?.latestOpenAt = DateTime.now();
    await _instanceBox.putAsync(instance!);
    return;
  }

  @override
  Future<void> addInstanceActiveSchema(InstanceId id, String schema) async {
    final instance = _instanceBox.get(id.value);
    instance?.activeSchemas.add(schema);
    await _instanceBox.putAsync(instance!);
    return;
  }
}

@Riverpod(keepAlive: true)
InstanceRepo instanceRepo(Ref ref) {
  ObjectBox ob = ref.watch(objectboxProvider);
  return InstanceRepoImpl(ob);
}
