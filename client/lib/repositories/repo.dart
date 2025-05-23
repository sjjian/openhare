import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'instances.dart';
import 'sessions.dart';

import 'objectbox.g.dart';

part 'repo.g.dart';

late ObjectBox objectbox2;

class ObjectBox {
  /// The Store of this app.
  late final Store store;

  /// A Box of tasks.
  late final Box<InstanceModel> _instanceBox;
  late final Box<SessionStorage> _sessionBox;

  ObjectBox._create(this.store) {
    objectbox2 = this;
    _instanceBox = store.box();
    _sessionBox = store.box();
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    print("load stor from: ${docsDir.path}/objectbox");
    final store = await openStore(
        directory: p.join(docsDir.path, "objectbox"),
        macosApplicationGroup: "objectbox.store");
    return ObjectBox._create(store);
  }

  Future<void> addInstance(InstanceModel instance) =>
      _instanceBox.putAsync(instance);

  Future<void> updateInstance(InstanceModel target) async {
    _instanceBox.putAsync(target);
  }

  Future<void> deleteInstance(InstanceModel instance) =>
      _instanceBox.removeAsync(instance.id);

// todo: aync
  bool isInstanceExist(String name) {
    final instance = getInstance(name);
    return instance != null;
  }

// todo: aync
  InstanceModel? getInstance(String name) {
    final build = _instanceBox.query(InstanceModel_.name.equals(name)).build();
    return build.findFirst();
  }

// todo: aync
  List<InstanceModel> searchInstances(String key,
      {int? pageNumber, int? pageSize}) {
    final build = _instanceBox.query(InstanceModel_.name.contains(key)).build();
    build.limit = (pageSize ?? 10);
    build.offset = ((pageNumber ?? 1) - 1) * (pageSize ?? 10);
    final instances = build.find();
    return instances;
  }

// todo: aync
  int instanceCount(String key) {
    final build = _instanceBox.query(InstanceModel_.name.contains(key)).build();
    return build.count();
  }

  List<InstanceModel> getActiveInstances(int top) {
    final build = _instanceBox
        .query(InstanceModel_.latestOpenAt.notNull())
        .order(InstanceModel_.latestOpenAt)
        .build();
    build.limit = top;
    return build.find();
  }

  Future<void> addActiveInstance(InstanceModel instance) async {
    instance.latestOpenAt = DateTime.now();
    await updateInstance(instance);
    return;
  }

  Future<void> addInstanceActiveSchema(InstanceModel instance, String schema) async{
    instance.activeSchemas.add(schema);
    await updateInstance(instance);
    return;
  }
}

@Riverpod(keepAlive: true)
ObjectBox objectbox(Ref ref) {
  return objectbox2;
}
