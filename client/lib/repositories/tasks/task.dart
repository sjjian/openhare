import 'package:client/models/tasks.dart';
import 'package:client/repositories/objectbox.g.dart';
import 'package:client/repositories/repo.dart';
import 'package:objectbox/objectbox.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task.g.dart';

@Entity()
class TaskStorage {
  @Id()
  int id;

  @Transient()
  TaskType taskType;

  int get stTaskType => taskType.index;

  set stTaskType(int value) {
    taskType = TaskType.values[value];
  }

  @Transient()
  TaskStatus status;

  int get stStatus => status.index;

  set stStatus(int value) {
    status = TaskStatus.values[value];
  }

  String? progressMessage;

  @Property(type: PropertyType.dateNano)
  DateTime createdAt;

  @Property(type: PropertyType.dateNano)
  DateTime? completedAt;

  String? errorMessage;
  String? parameters;
  String? desc;

  TaskStorage({
    this.id = 0,
    required int stTaskType,
    required int stStatus,
    this.progressMessage,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.parameters,
    this.desc,
  })  : taskType = TaskType.values[stTaskType],
        status = TaskStatus.values[stStatus];

  TaskStorage.fromModel(TaskModel model)
      : id = model.id.value,
        taskType = model.type,
        status = model.status,
        progressMessage = model.progressMessage,
        createdAt = model.createdAt,
        completedAt = model.completedAt,
        errorMessage = model.errorMessage,
        parameters = model.parameters,
        desc = model.desc;

  TaskModel toModel() => TaskModel(
        id: TaskId(value: id),
        type: taskType,
        status: status,
        progressMessage: progressMessage,
        createdAt: createdAt,
        completedAt: completedAt,
        errorMessage: errorMessage,
        parameters: parameters,
        desc: desc,
      );
}

class TaskRepoImpl implements TaskRepo {
  final ObjectBox ob;
  final Box<TaskStorage> _taskBox;

  TaskRepoImpl(this.ob) : _taskBox = ob.store.box();

  @override
  TaskId createTask(TaskModel task) {
    final now = DateTime.now();
    final storage = TaskStorage(
      stTaskType: task.type.index,
      stStatus: task.status.index,
      progressMessage: task.progressMessage,
      createdAt: now,
      completedAt: task.completedAt,
      errorMessage: task.errorMessage,
      parameters: task.parameters,
      desc: task.desc,
    );
    final id = _taskBox.put(storage);
    return TaskId(value: id);
  }

  @override
  void deleteTask(TaskId id) {
    _taskBox.remove(id.value);
  }

  @override
  void updateTask(TaskModel task) {
    final storage = TaskStorage.fromModel(task);
    _taskBox.put(storage);
  }

  @override
  TaskModel? getTaskById(TaskId id) {
    return _taskBox.get(id.value)?.toModel();
  }

  @override
  TaskListResult getTasks({
    String? key,
    int? pageNumber,
    int? pageSize,
    TaskType? type,
    TaskStatus? status,
    DateTime? completedAtStart,
    DateTime? completedAtEnd,
  }) {
    // 构建查询条件
    final sanitizedKey = key?.trim();
    Condition<TaskStorage>? condition;

    if (type != null) {
      condition = TaskStorage_.stTaskType.equals(type.index);
    }

    if (status != null) {
      final statusCondition = TaskStorage_.stStatus.equals(status.index);
      condition =
          condition == null ? statusCondition : condition.and(statusCondition);
    }

    if (completedAtStart != null) {
      // 对于可空的 completedAt 字段，需要同时检查不为 null 且大于等于起始时间
      // ObjectBox 使用纳秒时间戳，需要将 DateTime 转换为纳秒
      final startNanos = completedAtStart.microsecondsSinceEpoch * 1000;
      final startCondition = TaskStorage_.completedAt
          .notNull()
          .and(TaskStorage_.completedAt.greaterOrEqual(startNanos));
      condition =
          condition == null ? startCondition : condition.and(startCondition);
    }

    if (completedAtEnd != null) {
      // 对于可空的 completedAt 字段，需要同时检查不为 null 且小于等于结束时间
      // ObjectBox 使用纳秒时间戳，需要将 DateTime 转换为纳秒
      final endNanos = completedAtEnd.microsecondsSinceEpoch * 1000;
      final endCondition = TaskStorage_.completedAt
          .notNull()
          .and(TaskStorage_.completedAt.lessOrEqual(endNanos));
      condition =
          condition == null ? endCondition : condition.and(endCondition);
    }

    if (sanitizedKey != null && sanitizedKey.isNotEmpty) {
      final keyCondition =
          TaskStorage_.parameters.contains(sanitizedKey, caseSensitive: false);
      condition =
          condition == null ? keyCondition : condition.and(keyCondition);
    }

    final countQuery = _taskBox.query(condition).build();
    final totalCount = countQuery.count();
    countQuery.close();

    // 获取分页数据
    final currentPage = (pageNumber != null && pageNumber > 0) ? pageNumber : 1;
    final size = (pageSize != null && pageSize > 0) ? pageSize : 10;
    final offset = (currentPage - 1) * size;

    final dataQuery = _taskBox
        .query(condition)
        .order(TaskStorage_.createdAt, flags: Order.descending)
        .build();
    dataQuery.limit = size;
    dataQuery.offset = offset;

    final paginatedTasks = dataQuery.find().map((e) => e.toModel()).toList();
    dataQuery.close();
    return TaskListResult(tasks: paginatedTasks, count: totalCount);
  }

  @override
  TaskOverviewModel getTaskOverview() {
    // 获取正在运行的任务 top5，按创建时间倒序
    final runningQuery = _taskBox
        .query(TaskStorage_.stStatus.equals(TaskStatus.running.index))
        .order(TaskStorage_.createdAt, flags: Order.descending)
        .build();
    runningQuery.limit = 5;
    final runningTasks =
        runningQuery.find().map((e) => e.toModel()).toList();
    runningQuery.close();

    // 获取最近的任务 top5，按创建时间倒序（排除正在运行的任务）
    final recentStatusCondition = TaskStorage_.stStatus
        .notEquals(TaskStatus.running.index);
    final recentQuery = _taskBox
        .query(recentStatusCondition)
        .order(TaskStorage_.createdAt, flags: Order.descending)
        .build();
    recentQuery.limit = 5;
    final recentTasks = recentQuery.find().map((e) => e.toModel()).toList();
    recentQuery.close();

    return TaskOverviewModel(
      runningTasks: runningTasks,
      recentTasks: recentTasks,
    );
  }
}

@Riverpod(keepAlive: true)
TaskRepo taskRepo(Ref ref) {
  ObjectBox ob = ref.watch(objectboxProvider);
  return TaskRepoImpl(ob);
}
