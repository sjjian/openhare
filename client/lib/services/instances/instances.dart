import 'package:client/models/instances.dart';
import 'package:client/repositories/instances/instances.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'instances.g.dart';

@Riverpod(keepAlive: true)
class InstancesServices extends _$InstancesServices {
  @override
  int build() {
    return 1;
  }

  Future<void> addInstance(InstanceModel instance) async {
    final repo = ref.read(instanceRepoProvider);
    await repo.add(instance);
  }

  Future<void> updateInstance(InstanceModel instance) async {
    final repo = ref.read(instanceRepoProvider);
    await repo.update(instance);
  }

  Future<void> deleteInstance(InstanceId id) async {
    final repo = ref.read(instanceRepoProvider);
    await repo.delete(id);
  }

  bool isInstanceExist(String name) {
    final repo = ref.read(instanceRepoProvider);
    return repo.isInstanceExist(name);
  }

  PaginationInstanceListModel instances(String key, {int? pageNumber, int? pageSize}) {
    final repo = ref.read(instanceRepoProvider);
    return repo.search(key,
        pageNumber: pageNumber, pageSize: pageSize);
  }

  int instanceCount(String key) {
    final repo = ref.read(instanceRepoProvider);
    return repo.count(key);
  }

  void addActiveInstance(InstanceModel instance, {String? schema}) {
    ref.read(instanceRepoProvider).addActiveInstance(instance.id);
    if (schema != null) {
      ref.read(instanceRepoProvider).addInstanceActiveSchema(instance.id, schema);
    }
  }

  List<InstanceModel> activeInstances() {
    final repo = ref.read(instanceRepoProvider);
    return repo.getActiveInstances(5);
  }
}
