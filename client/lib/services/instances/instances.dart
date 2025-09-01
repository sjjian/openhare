import 'package:client/models/instances.dart';
import 'package:client/repositories/instances/instances.dart';
import 'package:client/services/instances/metadata.dart';
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

  InstanceModel? getInstanceById(InstanceId instanceId) {
    final repo = ref.read(instanceRepoProvider);
    return repo.getInstanceById(instanceId);
  }

  Future<void> updateInstance(InstanceModel instance) async {
    final repo = ref.read(instanceRepoProvider);
    await repo.update(instance);
  }

  Future<void> deleteInstance(InstanceId id) async {
    final repo = ref.read(instanceRepoProvider);
    await repo.delete(id);
    ref.invalidate(
        instanceMetadataServicesProvider(id)); // close metadata provider
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
    final count = repo.count(key: key);
    final totalCount = repo.count();

    return PaginationInstanceListModel(
      count: count,
      pageSize: pageSize ?? 10,
      currentPage: pageNumber ?? 1,
      instances: instances,
      key: key,
      totalCount: totalCount,
    );
  }

  Future<void> addActiveInstance(InstanceId instanceId, {String? schema}) async {
    await ref.read(instanceRepoProvider).addActiveInstance(instanceId);
    if (schema != null) {
      await ref
          .read(instanceRepoProvider)
          .addInstanceActiveSchema(instanceId, schema);
    }
  }

  List<InstanceModel> activeInstances() {
    final repo = ref.read(instanceRepoProvider);
    return repo.getActiveInstances(5);
  }
}

@Riverpod(keepAlive: true)
class InstancesNotifier extends _$InstancesNotifier {
  @override
  PaginationInstanceListModel build() {
    return ref
        .read(instancesServicesProvider.notifier)
        .instances("", pageNumber: 1, pageSize: 10);
  }

  void changePage(String key, {int? pageNumber = 1, int? pageSize = 10}) {
    state = ref
        .read(instancesServicesProvider.notifier)
        .instances(key, pageNumber: pageNumber, pageSize: pageSize);
  }

  void refresh() {
    state = ref.read(instancesServicesProvider.notifier).instances(state.key,
        pageNumber: state.currentPage, pageSize: state.pageSize);
  }
}
