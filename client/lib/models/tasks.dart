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

  factory ExportDataParameters.fromJson(Map<String, dynamic> json) => _$ExportDataParametersFromJson(json);
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
  TaskModel createTask({
    required TaskType type,
    String? parameters,
    String? desc,
  });

  // 删除任务
  void deleteTask(TaskId id);

  // 更新任务
  void updateTask(TaskModel task);

  // 根据ID获取任务
  TaskModel? getTaskById(TaskId id);


  // 分页获取任务（返回list和count）
  TaskListResult getTasks(
      {String? key,
      int? pageNumber,
      int? pageSize,
      TaskStatus? status,
      TaskType? type});
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

  // 便捷方法
  const TaskModel._();

  bool get isCompleted => status == TaskStatus.completed;
  bool get isRunning => status == TaskStatus.running;
  bool get hasError => status == TaskStatus.failed;
  bool get isPending => status == TaskStatus.pending;

  // 格式化的进度百分比
  String get progressPercent => '${(progress * 100).round()}%';

  // 任务持续时间
  Duration get duration => updatedAt.difference(createdAt);

  // 获取导出数据参数
  ExportDataParameters? get exportDataParameters {
    if (type != TaskType.exportData) return null;
    if (parameters == null) return null;
    
    try {
      final params = jsonDecode(parameters!);
      if (params is Map<String, dynamic>) {
        return ExportDataParameters.fromJson(params);
      }
    } catch (e) {
      return null;
    }
    
    return null;
  }
}

@freezed
abstract class PaginationTaskListModel with _$PaginationTaskListModel {
  const factory PaginationTaskListModel({
    required List<TaskModel> tasks,
    required int currentPage,
    required int pageSize,
    required int count,
    required String key,
    required int totalCount,
    TaskStatus? status,
    TaskType? type,
  }) = _PaginationTaskListModel;
}
