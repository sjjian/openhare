import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:client/models/instances.dart';

part 'tasks.freezed.dart';
part 'tasks.g.dart';

// 任务类型枚举
enum TaskType {
  exportData,
}

// 任务状态枚举
enum TaskStatus {
  pending, // 待执行
  running, // 执行中
  completed, // 已完成
  failed, // 失败
  cancelled, // 已取消
}

// 任务ID
@freezed
abstract class TaskId with _$TaskId {
  const factory TaskId({
    required int value,
  }) = _TaskId;

  factory TaskId.empty() => const TaskId(value: 0);

  const TaskId._();

  bool get isEmpty => value == 0;
}

// 分页查询结果
class TaskListResult {
  final List<TaskModel> tasks;
  final int count;

  const TaskListResult({
    required this.tasks,
    required this.count,
  });
}

// 任务仓库接口
abstract class TaskRepo {
  // 创建任务
  TaskId createTask(TaskModel task);

  // 删除任务
  void deleteTask(TaskId id);

  // 更新任务
  void updateTask(TaskModel task);

  // 根据ID获取任务
  TaskModel? getTaskById(TaskId id);

  // 分页获取任务（返回list和count）
  TaskListResult getTasks({
    String? key,
    int? pageNumber,
    int? pageSize,
    TaskType? type,
  });
}

@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    required TaskId id,
    required TaskType type,
    required TaskStatus status,
    required double progress,
    String? currentStep,
    String? progressMessage,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? errorMessage,
    String? errorDetails,
    String? parameters,
    String? result,
    String? desc,
  }) = _TaskModel;
}

// 数据导出任务参数
@freezed
abstract class ExportDataParameters with _$ExportDataParameters {
  const factory ExportDataParameters({
    required InstanceId instanceId, // 数据源实例ID
    required String schema, // 数据库schema
    required String query, // SQL查询语句
    required String fileDir, // 导出文件路径
    required String fileName, // 导出文件名
  }) = _ExportDataParameters;

  const ExportDataParameters._();

  /// 获取导出文件路径
  String get exportFilePath {
    return '$fileDir/$fileName';
  }

  factory ExportDataParameters.fromJson(Map<String, dynamic> json) =>
      _$ExportDataParametersFromJson(json);
}

// todo: TaskModel 与 ExportDataModel 有大量重复字段，后续看有啥好的方式优化
@freezed
abstract class ExportDataModel with _$ExportDataModel {
  const factory ExportDataModel({
    required TaskId id,
    required TaskStatus status,
    required double progress,
    String? currentStep,
    String? progressMessage,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? errorMessage,
    String? errorDetails,
    ExportDataParameters? parameters,
    String? result,
    String? desc,
  }) = _ExportDataModel;

  const ExportDataModel._();

  factory ExportDataModel.fromModel(TaskModel model) {
    if (model.type != TaskType.exportData) {
      throw ArgumentError('TaskModel type must be exportData');
    }
    ExportDataParameters? parsedParameters;
    if (model.parameters != null) {
      try {
        final json = jsonDecode(model.parameters!);
        if (json is Map<String, dynamic>) {
          parsedParameters = ExportDataParameters.fromJson(json);
        }
      } catch (e) {
        // 解析失败时保持为 null
      }
    }
    return ExportDataModel(
      id: model.id,
      status: model.status,
      progress: model.progress,
      currentStep: model.currentStep,
      progressMessage: model.progressMessage,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      errorMessage: model.errorMessage,
      errorDetails: model.errorDetails,
      parameters: parsedParameters,
      result: model.result,
      desc: model.desc,
    );
  }

  TaskModel toModel() {
    return TaskModel(
      id: id,
      type: TaskType.exportData,
      status: status,
      progress: progress,
      currentStep: currentStep,
      progressMessage: progressMessage,
      createdAt: createdAt,
      updatedAt: updatedAt,
      errorMessage: errorMessage,
      errorDetails: errorDetails,
      parameters: parameters != null ? jsonEncode(parameters!.toJson()) : null,
      result: result,
      desc: desc,
    );
  }

  // 格式化的进度百分比
  String get progressPercent => '${(progress * 100).round()}%';

  // 任务持续时间
  Duration get duration => updatedAt.difference(createdAt);
}

// 导出数据任务列表项（仅包含展示所需字段）
@freezed
abstract class ExportDataTaskListItemModel with _$ExportDataTaskListItemModel {
  const factory ExportDataTaskListItemModel({
    required TaskId id,
    required TaskStatus status,
    required double progress,
    String? desc,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? fileName,
    String? exportFilePath,
    String? instanceName,
    String? schema,
  }) = _ExportDataTaskListItemModel;

  const ExportDataTaskListItemModel._();

  // 格式化的进度百分比
  String get progressPercent => '${(progress * 100).round()}%';

  // 任务持续时间
  Duration get duration => updatedAt.difference(createdAt);
}

@freezed
abstract class ExportDataTaskPaginationListModel
    with _$ExportDataTaskPaginationListModel {
  const factory ExportDataTaskPaginationListModel({
    required List<ExportDataTaskListItemModel> tasks,
    required int count,
    // param for 分页.
    required int pageNumber,
    required int pageSize,
    String? key,
  }) = _ExportDataTaskPaginationListModel;
}
