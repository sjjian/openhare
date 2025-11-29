import 'dart:io';

import 'package:client/models/tasks.dart';
import 'package:client/repositories/tasks/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:excel/excel.dart' as excel;
import 'package:client/utils/file_utils.dart';

part 'export_data.g.dart';

@Riverpod(keepAlive: true)
class ExportDataTasksServices extends _$ExportDataTasksServices {
  TaskRepo get _repo => ref.read(taskRepoProvider);

  @override
  int build() {
    return 1;
  }

  invalidate() {
    ref.invalidate(exportDataTaskPaginationListNotifierProvider);
    ref.invalidate(latestExportTaskProvider);
  }

  ExportDataModel _createTask(ExportDataModel task) {
    final taskModel = _repo.createTask(task.toModel());
    invalidate();
    return ExportDataModel.fromModel(taskModel);
  }

  void _updateTask(ExportDataModel task) {
    _repo.updateTask(task.toModel());
    invalidate();
  }

  void deleteTask(TaskId id) {
    _repo.deleteTask(id);
    invalidate();
  }

  ExportDataModel? getLatestTask() {
    final task = _repo.getLatestTask(type: TaskType.exportData);
    return task != null ? ExportDataModel.fromModel(task) : null;
  }

  TaskListResult getTasks({
    String? key,
    int? pageNumber,
    int? pageSize,
  }) {
    return _repo.getTasks(
      key: key,
      pageNumber: pageNumber,
      pageSize: pageSize,
      type: TaskType.exportData,
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
class ExportDataTaskPaginationListNotifier
    extends _$ExportDataTaskPaginationListNotifier {
  @override
  ExportDataTaskPaginationListModel build() {
    return _tasks();
  }

  ExportDataTaskPaginationListModel _tasks({
    String? key,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    final result = ref.read(exportDataTasksServicesProvider.notifier).getTasks(
          key: key,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );

    return ExportDataTaskPaginationListModel(
      tasks: result.tasks.map((task) {
        final exportDataModel = ExportDataModel.fromModel(task);
        final instanceId = exportDataModel.parameters?.instanceId;
        final instanceName = instanceId != null
            ? ref
                .read(instancesServicesProvider.notifier)
                .getInstanceById(instanceId)
                ?.name
            : null;
        return ExportDataTaskListItemModel(
          id: exportDataModel.id,
          status: exportDataModel.status,
          progress: exportDataModel.progress,
          desc: exportDataModel.desc,
          createdAt: exportDataModel.createdAt,
          updatedAt: exportDataModel.updatedAt,
          fileName: exportDataModel.parameters?.fileName,
          exportFilePath: exportDataModel.parameters?.exportFilePath,
          instanceName: instanceName,
          schema: exportDataModel.parameters?.schema,
        );
      }).toList(),
      count: result.count,
      pageNumber: pageNumber,
      pageSize: pageSize,
      key: key,
    );
  }

  void changePage({
    String? key,
    int? pageNumber,
    int? pageSize,
  }) {
    state = _tasks(
      key: key ?? state.key,
      pageNumber: pageNumber ?? state.pageNumber,
      pageSize: pageSize ?? state.pageSize,
    );
  }
}

@Riverpod(keepAlive: true)
ExportDataModel? latestExportTask(Ref ref) {
  return ref.read(exportDataTasksServicesProvider.notifier).getLatestTask();
}
