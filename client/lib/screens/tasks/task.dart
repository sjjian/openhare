import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/tasks.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/services/tasks/task.dart';
import 'package:client/utils/duration_extend.dart';
import 'package:client/utils/open_file.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/empty.dart';
import 'package:client/widgets/paginated_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageSkeleton(
      key: Key("tasks"),
      child: TaskTable(),
    );
  }
}

class TaskTable extends ConsumerStatefulWidget {
  const TaskTable({super.key});

  @override
  ConsumerState<TaskTable> createState() => _TaskTableState();
}

class _TaskTableState extends ConsumerState<TaskTable> {
  final Map<int, String> _fileErrors = {};
  final _verticalScrollController = ScrollController();

  static const _statusLabels = {
    TaskStatus.pending: '待执行',
    TaskStatus.running: '执行中',
    TaskStatus.completed: '已完成',
    TaskStatus.failed: '失败',
    TaskStatus.cancelled: '已取消',
  };

  String _statusLabel(TaskStatus status) => _statusLabels[status] ?? '';

  Color _statusColor(BuildContext context, TaskStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case TaskStatus.pending:
        return colorScheme.outline;
      case TaskStatus.running:
        return colorScheme.primary;
      case TaskStatus.completed:
        return colorScheme.secondary;
      case TaskStatus.failed:
        return colorScheme.error;
      case TaskStatus.cancelled:
        return colorScheme.outlineVariant;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now().toLocal();
    final timeStr = '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';

    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return '今天 $timeStr';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day) {
      return '昨天 $timeStr';
    }

    final difference = now.difference(local);
    if (difference.inDays < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return '${weekdays[local.weekday - 1]} $timeStr';
    }

    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} $timeStr';
  }

  String _formatFullDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _openFile(String path, int taskId) async {
    setState(() => _fileErrors.remove(taskId));

    try {
      final success = await openFile(path);
      if (!success) {
        setState(() => _fileErrors[taskId] = '文件不存在: $path');
      }
    } catch (e) {
      setState(() => _fileErrors[taskId] = '打开文件失败: $e');
    }
  }

  Widget _buildStatusChip(BuildContext context, TaskModel task) {
    final status = task.status;
    final color = _statusColor(context, status);
    final isRunning = status == TaskStatus.running;
    final statusText = isRunning
        ? '${_statusLabel(status)} ${task.progressPercent}'
        : _statusLabel(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 8,
            height: 8,
            child: isRunning
                ? CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              statusText,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildText(String? text, {bool isPlaceholder = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = isPlaceholder
        ? Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            )
        : Theme.of(context).textTheme.bodyMedium;
    final displayText = text ?? '-';
    return Tooltip(
      message: displayText,
      child: Text(
        displayText,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }

  Widget _buildFileName(
    BuildContext context, {
    required String? fileName,
    String? exportPath,
    String? errorMessage,
    VoidCallback? onFileTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (fileName == null) {
      return _buildText(null, isPlaceholder: true);
    }

    if (exportPath != null && onFileTap != null) {
      final hasError = errorMessage != null;
      final fileColor = hasError ? colorScheme.error : colorScheme.primary;
      final tooltipMessage = errorMessage ?? exportPath;

      return Row(
        children: [
          Expanded(
            child: Tooltip(
              message: tooltipMessage,
              child: GestureDetector(
                onTap: onFileTap,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.file_present_rounded,
                          size: 16, color: fileColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          fileName,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: fileColor,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildText(fileName);
  }

  DataRow _buildDataRow(TaskModel task) {
    final tasksService = ref.read(tasksServicesProvider.notifier);
    final instancesService = ref.read(instancesServicesProvider.notifier);
    final params = task.exportDataParameters;
    final fileName = params?.fileName;
    final exportPath =
        params != null ? p.join(params.fileDir, params.fileName) : null;
    final instanceId = params?.instanceId;
    final instance = instanceId != null
        ? instancesService.getInstanceById(instanceId)
        : null;
    final colorScheme = Theme.of(context).colorScheme;

    return DataRow(
      cells: [
        DataCell(
          _buildFileName(
            context,
            fileName: fileName,
            exportPath: exportPath,
            errorMessage: _fileErrors[task.id.value],
            onFileTap: exportPath != null
                ? () => _openFile(exportPath, task.id.value)
                : null,
          ),
        ),
        DataCell(_buildText(task.desc)),
        DataCell(_buildText(instance?.name, isPlaceholder: instance == null)),
        DataCell(
            _buildText(params?.schema, isPlaceholder: params?.schema == null)),
        DataCell(Tooltip(
          message: _formatFullDateTime(task.createdAt),
          child: Text(
            _formatDateTime(task.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        )),
        DataCell(Text(
          task.duration.format(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        )),
        DataCell(_buildStatusChip(context, task)),
        DataCell(
          RectangleIconButton.small(
            tooltip: '删除任务',
            icon: Icons.delete,
            onPressed: () => tasksService.deleteTask(task.id),
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(
        label: Text('文件名'),
        columnWidth: FlexColumnWidth(2),
      ),
      const DataColumn(
        label: Text('详情'),
        columnWidth: FlexColumnWidth(1.5),
      ),
      const DataColumn(
        label: Text('实例'),
        columnWidth: FlexColumnWidth(),
      ),
      const DataColumn(
        label: Text('Schema'),
        columnWidth: FlexColumnWidth(),
      ),
      const DataColumn(
        label: Text('创建时间'),
        columnWidth: FlexColumnWidth(),
      ),
      const DataColumn(
        label: Text('耗时'),
        columnWidth: FlexColumnWidth(),
      ),
      const DataColumn(
        label: Text('状态'),
        columnWidth: FlexColumnWidth(),
      ),
      const DataColumn(
        label: Text('操作'),
        columnWidth: FlexColumnWidth(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(tasksNotifierProvider);
    final notifier = ref.read(tasksNotifierProvider.notifier);
    final searchTextController = TextEditingController(text: model.key);

    return BodyPageSkeleton(
      bottomSpaceSize: kSpacingSmall,
      header: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.scheduled_task,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SearchBarTheme(
                  data: const SearchBarThemeData(
                    elevation: WidgetStatePropertyAll(0),
                    constraints: BoxConstraints(
                      minHeight: kIconSizeLarge,
                      maxWidth: 240,
                    ),
                  ),
                  child: SearchBar(
                    controller: searchTextController,
                    onChanged: (value) {
                      notifier.changePage(key: value);
                    },
                    onSubmitted: (value) {
                      notifier.changePage(key: value, pageNumber: 1);
                    },
                    trailing: const [Icon(Icons.search)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: model.tasks.isEmpty
                ? EmptyPage(
                    child: Text(
                      '暂无任务',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  )
                : Scrollbar(
                    controller: _verticalScrollController,
                    child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        checkboxHorizontalMargin: 0,
                        horizontalMargin: 0,
                        columnSpacing: kSpacingSmall,
                        dividerThickness: kDividerThickness,
                        showBottomBorder: true,
                        columns: _buildColumns(),
                        rows: model.tasks.map(_buildDataRow).toList(),
                        sortAscending: false,
                        showCheckboxColumn: true,
                      ),
                    ),
                  ),
          ),
          TablePaginatedBar(
            count: model.count,
            pageSize: model.pageSize,
            pageNumber: model.currentPage,
            onChange: (pageNumber) {
              notifier.changePage(
                key: searchTextController.text,
                pageNumber: pageNumber,
              );
            },
          ),
        ],
      ),
    );
  }
}
