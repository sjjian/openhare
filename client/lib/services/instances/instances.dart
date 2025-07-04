import 'package:client/models/instances.dart';
import 'package:client/repositories/instances/instances.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'instances.g.dart';

@Riverpod()
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

  PaginationInstanceListModel instances(String key,
      {int? pageNumber, int? pageSize}) {
    final repo = ref.read(instanceRepoProvider);
    final instances =
        repo.search(key, pageNumber: pageNumber, pageSize: pageSize);
    final count = repo.count(key);

    return PaginationInstanceListModel(
      count: count,
      pageSize: pageSize ?? 10,
      currentPage: pageNumber ?? 1,
      instances: instances,
      key: key,
    );
  }

  void addActiveInstance(InstanceId instanceId, {String? schema}) {
    ref.read(instanceRepoProvider).addActiveInstance(instanceId);
    if (schema != null) {
      ref
          .read(instanceRepoProvider)
          .addInstanceActiveSchema(instanceId, schema);
    }
  }

  List<InstanceModel> activeInstances() {
    final repo = ref.read(instanceRepoProvider);
    return repo.getActiveInstances(5);
  }
}
