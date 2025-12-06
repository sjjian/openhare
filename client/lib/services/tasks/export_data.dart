import 'dart:io';
import 'dart:convert';

import 'package:client/models/tasks.dart';
import 'package:client/repositories/tasks/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/services/tasks/overview.dart';
import 'package:client/models/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:csv/csv.dart';
import 'package:client/utils/file_utils.dart';
import 'package:client/services/settings/settings.dart';
import 'package:client/l10n/app_localizations_en.dart';
import 'package:client/l10n/app_localizations_zh.dart';
import 'package:client/l10n/app_localizations.dart';

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
    ref.invalidate(taskOverviewServiceProvider);
  }

  // todo: 统一处理
  AppLocalizations _getLocalizations() {
    final settings = ref.read(systemSettingServiceProvider);
    if (settings.language == 'zh') {
      return AppLocalizationsZh();
    } else {
      return AppLocalizationsEn();
    }
  }

  ExportDataModel _createTask(ExportDataModel task) {
    final taskId = _repo.createTask(task.toModel());
    invalidate();
    final taskModel = _repo.getTaskById(taskId);
    if (taskModel == null) {
      throw Exception('Failed to create task');
    }
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
    final task = _repo
        .getTasks(
          type: TaskType.exportData,
          pageNumber: 1,
          pageSize: 1,
        )
        .tasks
        .firstOrNull;
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

  // todo: 导出超大数据时可能会引起UI卡顿，需要优化。
  Future<void> exportData(ExportDataParameters parameters,
      {String? desc}) async {
    final l10n = _getLocalizations();

    // 1. 正在创建任务
    final uniqueFileName =
        getUniqueFileName(parameters.fileDir, parameters.fileName);
    final finalParameters = parameters.copyWith(fileName: uniqueFileName);

    final now = DateTime.now();
    ExportDataModel task = _createTask(ExportDataModel(
      id: TaskId.empty(),
      parameters: finalParameters,
      desc: desc,
      status: TaskStatus.running,
      progressMessage: l10n.export_progress_creating_task,
      createdAt: now,
      completedAt: null,
    ));

    final connServices = ref.read(sessionConnsServicesProvider.notifier);
    SessionConnModel? connModel;
    try {
      // 2. 正在连接数据
      task = task.copyWith(progressMessage: l10n.export_progress_connecting);
      _updateTask(task);

      connModel = await connServices.createConn(parameters.instanceId,
          currentSchema: parameters.schema);
      await connServices.connect(connModel.connId);

      // 3. 正在执行语句
      task =
          task.copyWith(progressMessage: l10n.export_progress_executing_query);
      _updateTask(task);

      // 4. 正在打开文件
      task = task.copyWith(progressMessage: l10n.export_progress_opening_file);
      _updateTask(task);

      File file = File(finalParameters.exportFilePath);
      final sink = file.openWrite(encoding: utf8);

      int rowCount = 0;
      int bufferedSize = 0;
      const int flushThreshold = 1024 * 1024;
      const csvConverter = ListToCsvConverter();
      List<String>? columnNames;

      try {
        await for (final item
            in connServices.queryStream(connModel.connId, parameters.query)) {
          switch (item) {
            case QueryStreamItemHeader(:final columns, affectedRows: _):
              columnNames = columns.map((e) => e.name).toList();
              final headerCsv = csvConverter.convert([columnNames]);
              sink.writeln(headerCsv);
              await sink.flush();

              // 5. 开始导出数据
              task = task.copyWith(
                progressMessage: l10n.export_progress_exporting(0)
              );
              _updateTask(task);

            case QueryStreamItemRow(:final row):
              final rowData =
                  row.values.map((e) => e.getString() ?? '').toList();
              final rowCsv = csvConverter.convert([rowData]);
              sink.writeln(rowCsv);
              rowCount++;

              bufferedSize += rowCsv.length + 1; // 1 是换行符的长度
              // 如果缓冲区大小超过阈值，则存一下文件并更新进度
              if (bufferedSize >= flushThreshold) {
                await sink.flush();
                bufferedSize = 0;
                task = task.copyWith(
                  progressMessage: l10n.export_progress_exporting(rowCount),
                );
                _updateTask(task);
              }
          }
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      // 6. 完成
      task = task.copyWith(
        status: TaskStatus.completed,
        progressMessage: l10n.export_progress_completed,
        completedAt: DateTime.now(),
      );
      _updateTask(task);
    } catch (e) {
      _updateTask(task.copyWith(
        status: TaskStatus.failed,
        errorMessage: e.toString(),
        completedAt: DateTime.now(),
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
          desc: exportDataModel.desc,
          progressMessage: exportDataModel.progressMessage,
          createdAt: exportDataModel.createdAt,
          completedAt: exportDataModel.completedAt,
          fileName: exportDataModel.parameters?.fileName,
          exportFilePath: exportDataModel.parameters?.exportFilePath,
          instanceName: instanceName,
          schema: exportDataModel.parameters?.schema,
          errorMessage: exportDataModel.errorMessage,
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
