import 'package:client/models/tasks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task.g.dart';

class TaskRepoImpl implements TaskRepo {
  // 内存存储：使用 Map 存储任务，key 为任务 ID
  final Map<int, TaskModel> _tasks = {};

  // ID 生成器
  int _nextId = 1;

  TaskRepoImpl();

  @override
  TaskModel createTask({
    required TaskType type,
    String? parameters,
    String? desc,
  }) {
    final now = DateTime.now();
    final task = TaskModel(
      id: TaskId(value: _nextId++),
      type: type,
      status: TaskStatus.pending,
      progress: 0.0,
      createdAt: now,
      updatedAt: now,
      parameters: parameters,
      desc: desc,
    );
    _tasks[task.id.value] = task;
    return task;
  }

  @override
  void deleteTask(TaskId id) {
    _tasks.remove(id.value);
  }

  @override
  void updateTask(TaskModel task) {
    _tasks[task.id.value] = task.copyWith(updatedAt: DateTime.now());
  }

  @override
  TaskModel? getTaskById(TaskId id) {
    return _tasks[id.value];
  }

  @override
  TaskListResult getTasks({
    String? key,
    int? pageNumber,
    int? pageSize,
    TaskStatus? status,
    TaskType? type,
  }) {
    // 过滤任务
    var filteredTasks = _tasks.values.toList();

    // 按详情搜索
    final sanitizedKey = key?.trim();
    if (sanitizedKey != null && sanitizedKey.isNotEmpty) {
      filteredTasks = filteredTasks
          .where((task) =>
              task.desc?.toLowerCase().contains(sanitizedKey.toLowerCase()) ??
              false)
          .toList();
    }

    // 按状态过滤
    if (status != null) {
      filteredTasks =
          filteredTasks.where((task) => task.status == status).toList();
    }

    // 按类型过滤
    if (type != null) {
      filteredTasks = filteredTasks.where((task) => task.type == type).toList();
    }

    // 按创建时间降序排序
    filteredTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 计算总数
    final totalCount = filteredTasks.length;

    // 分页处理
    final currentPage = (pageNumber != null && pageNumber > 0) ? pageNumber : 1;
    final size = (pageSize != null && pageSize > 0) ? pageSize : 10;
    final offset = (currentPage - 1) * size;

    // 获取分页数据
    final paginatedTasks = filteredTasks.skip(offset).take(size).toList();

    return TaskListResult(tasks: paginatedTasks, count: totalCount);
  }
}

@Riverpod(keepAlive: true)
TaskRepo taskRepo(Ref ref) {
  return TaskRepoImpl();
}
