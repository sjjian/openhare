import 'dart:io';

import 'package:client/models/tasks.dart';
import 'package:client/repositories/tasks/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/models/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:excel/excel.dart' as excel;
import 'package:client/utils/file_utils.dart';

part 'export_data.g.dart';

@Riverpod()
class ExportDataTasksServices extends _$ExportDataTasksServices {
  TaskRepo get _repo => ref.read(taskRepoProvider);

  @override
  int build() {
    return 1;
  }

  ExportDataModel _createTask(ExportDataModel task) {
    final taskModel = _repo.createTask(task.toModel());
    ref.invalidate(tasksNotifierProvider);
    return ExportDataModel.fromModel(taskModel);
  }

  void _updateTask(ExportDataModel task) {
    _repo.updateTask(task.toModel());
    ref.invalidate(tasksNotifierProvider);
  }

  void deleteTask(TaskId id) {
    _repo.deleteTask(id);
    ref.invalidate(tasksNotifierProvider);
  }

  ExportDataModel? getLatestTask() {
    final task = _repo.getLatestTask(type: TaskType.exportData);
    return task != null ? ExportDataModel.fromModel(task) : null;
  }

  PaginationExportDataTaskListModel tasks(
    String key, {
    int? pageNumber,
    int? pageSize,
    TaskStatus? status,
  }) {
    final sanitizedKey = key.trim();
    final currentPage = (pageNumber != null && pageNumber > 0) ? pageNumber : 1;
    final size = (pageSize != null && pageSize > 0) ? pageSize : 10;

    final result = _repo.getTasks(
      key: sanitizedKey.isEmpty ? null : sanitizedKey,
      pageNumber: currentPage,
      pageSize: size,
      status: status,
      type: TaskType.exportData,
    );

    // 获取总数量（无筛选条件）
    final totalResult = _repo.getTasks();

    return PaginationExportDataTaskListModel(
      tasks:
          result.tasks.map((task) => ExportDataModel.fromModel(task)).toList(),
      currentPage: currentPage,
      pageSize: size,
      count: result.count,
      key: sanitizedKey,
      totalCount: totalResult.count,
      status: status,
    );
  }

  Future<void> exportData(ExportDataParameters parameters,
      {String? desc}) async {
    // 获取唯一的文件名，如果文件已存在则自动添加序号
    final uniqueFileName =
        getUniqueFileName(parameters.fileDir, parameters.fileName);
    // 更新参数，使用实际保存的文件名
    final finalParameters = parameters.copyWith(fileName: uniqueFileName);

    final now = DateTime.now();
    ExportDataModel task = _createTask(ExportDataModel(
      id: TaskId.empty(),
      parameters: finalParameters,
      desc: desc,
      status: TaskStatus.running,
      progress: 0.0,
      createdAt: now,
      updatedAt: now,
    ));

    final connServices = ref.read(sessionConnsServicesProvider.notifier);
    SessionConnModel? connModel;
    try {
      connModel = await connServices.createConn(parameters.instanceId,
          currentSchema: parameters.schema);
      await connServices.connect(connModel.connId);
      // todo: 使用exportData方法，底层使用流失导出，防止内存占用过多。
      BaseQueryResult? res =
          await connServices.query(connModel.connId, parameters.query);

      final data = excel.Excel.createExcel();
      final sheet = data["Sheet1"];
      sheet.appendRow(res!.columns
          .map<excel.TextCellValue>((e) => excel.TextCellValue(e.name))
          .toList());
      for (final row in res.rows) {
        sheet.appendRow(row.values
            .map<excel.TextCellValue>(
                (e) => excel.TextCellValue(e.getString() ?? ''))
            .toList());
      }

      File file = File(finalParameters.exportFilePath);
      await file.writeAsBytes(data.save()!);

      _updateTask(task.copyWith(
        status: TaskStatus.completed,
      ));
    } catch (e) {
      _updateTask(task.copyWith(
        status: TaskStatus.failed,
        errorMessage: e.toString(),
      ));
    } finally {
      if (connModel != null) {
        await connServices.close(connModel.connId);
        await connServices.removeConn(connModel.connId);
      }
    }
  }
}

@Riverpod(keepAlive: true)
class TasksNotifier extends _$TasksNotifier {
  @override
  PaginationExportDataTaskListModel build() {
    return ref
        .read(exportDataTasksServicesProvider.notifier)
        .tasks("", pageNumber: 1, pageSize: 10);
  }

  void changePage({
    String? key,
    int? pageNumber,
    int? pageSize,
    TaskStatus? status,
  }) {
    state = ref.read(exportDataTasksServicesProvider.notifier).tasks(
          key ?? state.key,
          pageNumber: pageNumber ?? state.currentPage,
          pageSize: pageSize ?? state.pageSize,
          status: status ?? state.status,
        );
  }
}

@Riverpod(keepAlive: true)
ExportDataModel? latestExportTask(Ref ref) {
  // 监听任务列表变化，当任务更新时自动重新计算
  ref.watch(tasksNotifierProvider);

  final task =
      ref.read(exportDataTasksServicesProvider.notifier).getLatestTask();
  return task;
}
