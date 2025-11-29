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

  double progress;
  String? currentStep;
  String? progressMessage;

  @Property(type: PropertyType.dateNano)
  DateTime createdAt;

  @Property(type: PropertyType.dateNano)
  DateTime updatedAt;

  String? errorMessage;
  String? errorDetails;
  String? parameters;
  String? result;
  String? desc;

  TaskStorage({
    this.id = 0,
    required int stTaskType,
    required int stStatus,
    required this.progress,
    this.currentStep,
    this.progressMessage,
    required this.createdAt,
    required this.updatedAt,
    this.errorMessage,
    this.errorDetails,
    this.parameters,
    this.result,
    this.desc,
  })  : taskType = TaskType.values[stTaskType],
        status = TaskStatus.values[stStatus];

  TaskStorage.fromModel(TaskModel model)
      : id = model.id.value,
        taskType = model.type,
        status = model.status,
        progress = model.progress,
        currentStep = model.currentStep,
        progressMessage = model.progressMessage,
        createdAt = model.createdAt,
        updatedAt = model.updatedAt,
        errorMessage = model.errorMessage,
        errorDetails = model.errorDetails,
        parameters = model.parameters,
        result = model.result,
        desc = model.desc;

  TaskModel toModel() => TaskModel(
        id: TaskId(value: id),
        type: taskType,
        status: status,
        progress: progress,
        currentStep: currentStep,
        progressMessage: progressMessage,
        createdAt: createdAt,
        updatedAt: updatedAt,
        errorMessage: errorMessage,
        errorDetails: errorDetails,
        parameters: parameters,
        result: result,
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
      progress: task.progress,
      currentStep: task.currentStep,
      progressMessage: task.progressMessage,
      createdAt: now,
      updatedAt: now,
      errorMessage: task.errorMessage,
      errorDetails: task.errorDetails,
      parameters: task.parameters,
      result: task.result,
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
    final storage = TaskStorage.fromModel(
      task.copyWith(updatedAt: DateTime.now()),
    );
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
  }) {
    // 构建查询条件
    final sanitizedKey = key?.trim();
    Condition<TaskStorage>? condition;

    if (type != null) {
      condition = TaskStorage_.stTaskType.equals(type.index);
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
}

@Riverpod(keepAlive: true)
TaskRepo taskRepo(Ref ref) {
  ObjectBox ob = ref.watch(objectboxProvider);
  return TaskRepoImpl(ob);
}
