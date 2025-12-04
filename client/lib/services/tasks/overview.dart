import 'package:client/models/tasks.dart';
import 'package:client/repositories/tasks/task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'overview.g.dart';

@Riverpod(keepAlive: true)
class TaskOverviewService extends _$TaskOverviewService {
  TaskRepo get _repo => ref.read(taskRepoProvider);

  @override
  TaskOverviewModel build() {
    return _repo.getTaskOverview();
  }
}

