import 'dart:io';
import 'dart:convert';

import 'package:client/models/tasks.dart';
import 'package:client/repositories/tasks/task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/models/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path/path.dart' as p;

part 'task.g.dart';

abstract class Task {
  start();
  stop();
  onStatusChanged(TaskStatus status);
}

@Riverpod()
class TasksServices extends _$TasksServices {
  TaskRepo get _repo => ref.read(taskRepoProvider);

  @override
  int build() {
    return 1;
  }

  TaskModel createTask({
    required TaskType type,
    String? parameters,
    String? desc,
  }) {
    return _repo.createTask(type: type, parameters: parameters, desc: desc);
  }

  PaginationTaskListModel tasks(
    String key, {
    int? pageNumber,
    int? pageSize,
    TaskStatus? status,
    TaskType? type,
  }) {
    final sanitizedKey = key.trim();
    final currentPage = (pageNumber != null && pageNumber > 0) ? pageNumber : 1;
    final size = (pageSize != null && pageSize > 0) ? pageSize : 10;

    final result = _repo.getTasks(
      key: sanitizedKey.isEmpty ? null : sanitizedKey,
      pageNumber: currentPage,
      pageSize: size,
      status: status,
      type: type,
    );

    // 获取总数量（无筛选条件）
    final totalResult = _repo.getTasks();

    return PaginationTaskListModel(
      tasks: result.tasks,
      currentPage: currentPage,
      pageSize: size,
      count: result.count,
      key: sanitizedKey,
      totalCount: totalResult.count,
      status: status,
      type: type,
    );
  }

  TaskModel? getTaskById(TaskId id) {
    return _repo.getTaskById(id);
  }

  void updateTask(TaskModel task) {
    _repo.updateTask(task);
    ref.invalidate(tasksNotifierProvider);
  }

  void deleteTask(TaskId id) {
    _repo.deleteTask(id);
    ref.invalidate(tasksNotifierProvider);
  }

  Future<void> exportData(ExportDataParameters parameters,
      {String? desc}) async {
    TaskModel task = createTask(
      type: TaskType.exportData,
      parameters: jsonEncode(parameters.toJson()),
      desc: desc,
    );

    final connServices = ref.read(sessionConnsServicesProvider.notifier);
    SessionConnModel? connModel;
    try {
      print("start create conn, parameters: $parameters");
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
      print("start file save");
      File file = File(p.join(parameters.fileDir, parameters.fileName));
      await file.writeAsBytes(data.save()!);
      print("file save success");
      updateTask(task.copyWith(status: TaskStatus.completed));
    } catch (e) {
      updateTask(
          task.copyWith(status: TaskStatus.failed, errorMessage: e.toString()));
      print("export data error: $e");
    } finally {
      if (connModel != null) {
        print("start close conn");
        await connServices.close(connModel.connId);
        print("close conn success");
        await connServices.removeConn(connModel.connId);
        print("remove conn success");
      }
    }
    return;
  }
}

@Riverpod(keepAlive: true)
class TasksNotifier extends _$TasksNotifier {
  @override
  PaginationTaskListModel build() {
    return ref
        .read(tasksServicesProvider.notifier)
        .tasks("", pageNumber: 1, pageSize: 10);
  }

  void changePage({
    String? key,
    int? pageNumber,
    int? pageSize,
    TaskStatus? status,
    TaskType? type,
  }) {
    state = ref.read(tasksServicesProvider.notifier).tasks(
          key ?? state.key,
          pageNumber: pageNumber ?? state.currentPage,
          pageSize: pageSize ?? state.pageSize,
          status: status ?? state.status,
          type: type ?? state.type,
        );
  }
}
