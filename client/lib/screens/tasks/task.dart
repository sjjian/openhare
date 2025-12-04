import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/tasks.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/services/tasks/export_data.dart';
import 'package:client/utils/time_format.dart';
import 'package:client/utils/open_file.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/empty.dart';
import 'package:client/widgets/paginated_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final _searchTextController = TextEditingController();

  String _statusLabel(BuildContext context, TaskStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case TaskStatus.pending:
        return l10n.task_status_pending;
      case TaskStatus.running:
        return l10n.task_status_running;
      case TaskStatus.completed:
        return l10n.task_status_completed;
      case TaskStatus.failed:
        return l10n.task_status_failed;
      case TaskStatus.cancelled:
        return l10n.task_status_cancelled;
    }
  }

  Color _statusColor(BuildContext context, TaskStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case TaskStatus.pending:
        return colorScheme.outline;
      case TaskStatus.running:
        return colorScheme.primary;
      case TaskStatus.completed:
        return Colors.green.shade200; // todo: 颜色统一放
      case TaskStatus.failed:
        return colorScheme.error;
      case TaskStatus.cancelled:
        return colorScheme.outlineVariant;
    }
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  Future<void> _openFile(String path, int taskId) async {
    setState(() => _fileErrors.remove(taskId));

    try {
      final success = await openFile(path);
      if (!success) {
        setState(() => _fileErrors[taskId] =
            AppLocalizations.of(context)!.error_file_not_found(path));
      }
    } catch (e) {
      setState(() => _fileErrors[taskId] =
          AppLocalizations.of(context)!.error_open_file_failed(e.toString()));
    }
  }

  Future<void> _openFileInFolder(String path, int taskId) async {
    setState(() => _fileErrors.remove(taskId));

    try {
      final success = await openFileInFolder(path);
      if (!success) {
        setState(() => _fileErrors[taskId] =
            AppLocalizations.of(context)!.error_file_not_found(path));
      }
    } catch (e) {
      setState(() => _fileErrors[taskId] =
          AppLocalizations.of(context)!.error_open_folder_failed(e.toString()));
    }
  }

  Widget _buildStatusChip(BuildContext context, ExportDataTaskListItemModel task) {
    final status = task.status;
    final color = _statusColor(context, status);
    final isRunning = status == TaskStatus.running;
    final statusText = isRunning
        ? '${_statusLabel(context, status)} ${task.progressPercent}'
        : _statusLabel(context, status);
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

  DataRow _buildDataRow(ExportDataTaskListItemModel task) {
    final tasksService = ref.read(exportDataTasksServicesProvider.notifier);
    final fileName = task.fileName;
    final exportPath = task.exportFilePath;
    final instanceName = task.instanceName;
    final schema = task.schema;
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
        DataCell(_buildText(instanceName, isPlaceholder: instanceName == null)),
        DataCell(_buildText(schema, isPlaceholder: schema == null)),
        DataCell(Tooltip(
          message: task.createdAt.formatFullDateTime(context),
          child: Text(
            task.createdAt.formatDateTime(context),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        )),
        DataCell(Text(
          task.duration?.format() ?? '-',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        )),
        DataCell(_buildStatusChip(context, task)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RectangleIconButton.small(
                tooltip: AppLocalizations.of(context)!.tooltip_open_folder,
                icon: Icons.folder_open,
                onPressed: exportPath != null
                    ? () => _openFileInFolder(exportPath, task.id.value)
                    : null,
              ),
              const SizedBox(width: kSpacingTiny),
              RectangleIconButton.small(
                tooltip: AppLocalizations.of(context)!.tooltip_delete_task,
                icon: Icons.delete,
                onPressed: () => tasksService.deleteTask(task.id),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildColumns(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      DataColumn(
        label: Text(l10n.task_column_file_name),
        columnWidth: const FlexColumnWidth(2),
      ),
      DataColumn(
        label: Text(l10n.db_instance_desc),
        columnWidth: const FlexColumnWidth(1.5),
      ),
      DataColumn(
        label: Text(l10n.metadata_tree_instance),
        columnWidth: const FlexColumnWidth(),
      ),
      DataColumn(
        label: Text(l10n.metadata_tree_schema),
        columnWidth: const FlexColumnWidth(),
      ),
      DataColumn(
        label: Text(l10n.task_column_created_at),
        columnWidth: const FlexColumnWidth(),
      ),
      DataColumn(
        label: Text(l10n.duration),
        columnWidth: const FlexColumnWidth(),
      ),
      DataColumn(
        label: Text(l10n.task_column_status),
        columnWidth: const FlexColumnWidth(),
      ),
      DataColumn(
        label: Text(l10n.db_instance_op),
        columnWidth: const FlexColumnWidth(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(exportDataTaskPaginationListNotifierProvider);
    final notifier = ref.read(exportDataTaskPaginationListNotifierProvider.notifier);

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
                      maxWidth: 200,
                    ),
                  ),
                  child: SearchBar(
                    controller: _searchTextController,
                    backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                    side: WidgetStatePropertyAll(
                      BorderSide(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        width: 0.5,
                      ),
                    ),
                    onChanged: (value) {
                      notifier.changePage(key: value);
                    },
                    onSubmitted: (value) {
                      notifier.changePage(key: value);
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
                      AppLocalizations.of(context)!.task_no_tasks,
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
                        columns: _buildColumns(context),
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
            pageNumber: model.pageNumber,
            onChange: (pageNumber) {
              notifier.changePage(
                key: _searchTextController.text,
                pageNumber: pageNumber,
              );
            },
          ),
        ],
      ),
    );
  }
}
