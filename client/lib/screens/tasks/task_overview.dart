import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/tasks.dart';
import 'package:client/services/tasks/overview.dart';
import 'package:client/utils/time_format.dart';
import 'package:client/utils/open_file.dart' show openFile, openFileInFolder;
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/empty.dart';
import 'package:client/widgets/menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 导出数据任务项组件
class ExportDataTaskOverviewItem extends ConsumerWidget {
  final ExportDataModel exportData;

  ExportDataTaskOverviewItem({
    super.key,
    required TaskModel task,
  }) : exportData = ExportDataModel.fromModel(task);

  bool get canOpenFile =>
      exportData.status == TaskStatus.completed &&
      exportData.parameters != null;

  String? get fileName => exportData.parameters?.fileName;

  String? get filePath =>
      canOpenFile ? exportData.parameters!.exportFilePath : null;

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

  Color _getStatusColor(BuildContext context, TaskStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case TaskStatus.running:
        return colorScheme.primary;
      case TaskStatus.completed:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  String _getStatusText(BuildContext context) {
    final isRunning = exportData.status == TaskStatus.running;
    return isRunning
        ? '${_statusLabel(context, exportData.status)} ${(exportData.progress * 100).round()}%'
        : _statusLabel(context, exportData.status);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingSmall,
        vertical: kSpacingSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧：导出图标
          RectangleIconButton.medium(
            icon: Icons.file_download,
            iconColor: colorScheme.surfaceContainerLowest,
            backgroundColor: colorScheme.primaryContainer,
            onPressed: null,
          ),
          const SizedBox(width: kSpacingSmall),
          // 任务状态信息
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 文件名（可点击）
                // todo: 改成linkbutton
                canOpenFile
                    ? GestureDetector(
                        onTap: () async {
                          await openFile(filePath!);
                        },
                        child: Text(
                          fileName ?? '-',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      )
                    : Text(
                        fileName ?? '-',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        // style: Theme.of(context).textTheme.bodyMedium,
                      ),
                const SizedBox(height: kSpacingTiny),
                // 状态・时间・任务详情（状态有颜色，时间和详情灰色，用"・"分隔）
                Row(
                  children: [
                    exportData.status == TaskStatus.failed &&
                            exportData.errorMessage != null
                        ? Tooltip(
                            message: exportData.errorMessage!,
                            child: Text(
                              _getStatusText(context),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: _getStatusColor(
                                        context, exportData.status),
                                  ),
                            ),
                          )
                        : Text(
                            _getStatusText(context),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: _getStatusColor(
                                      context, exportData.status),
                                ),
                          ),
                    Text(
                      '・${exportData.createdAt.formatDateTime(context)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    if (exportData.desc != null && exportData.desc!.isNotEmpty)
                      Flexible(
                        child: Text(
                          '・${exportData.desc}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // 右侧：打开文件图标
          if (canOpenFile) ...[
            const SizedBox(width: kSpacingSmall),
            RectangleIconButton.small(
              icon: Icons.folder_open,
              onPressed: () async {
                await openFileInFolder(filePath!);
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// 任务项组件工厂函数
class TaskOverviewItem {
  const TaskOverviewItem._();

  static Widget fromTask(TaskModel task, {Key? key}) {
    switch (task.type) {
      case TaskType.exportData:
        return ExportDataTaskOverviewItem(
          key: key,
          task: task,
        );
    }
  }
}

/// 任务概览弹窗封装组件，负责展示 OverlayMenu + 内容
/// 使用 OverlayMenu 的 tabs，将每个任务拆成独立条目展示。
class TaskOverviewMenu extends ConsumerWidget {
  final Widget child;

  const TaskOverviewMenu({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const headerHeight = 42.0;
    const footerHeight = 42.0;
    const itemHeight = 62.0;

    final overview = ref.watch(taskOverviewServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final allTasks = [
      ...overview.runningTasks,
      ...overview.recentTasks,
    ];

    // 运行中的任务和最近的任务
    final tabs = allTasks.isEmpty
        ? [
            OverlayMenuItem(
              height: itemHeight * 4,
              child: EmptyPage(
                child: Text(
                  l10n.task_no_tasks,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          ]
        : allTasks
            .map(
              (task) => OverlayMenuItem(
                height: itemHeight,
                hoverColor: colorScheme.surfaceContainerLow,
                child: TaskOverviewItem.fromTask(task),
              ),
            )
            .toList();

    final header = OverlayMenuHeader(
      height: headerHeight,
      child: Padding(
        padding: const EdgeInsets.only(
          left: kSpacingSmall + kSpacingTiny, // 文字与图标对齐
          right: kSpacingSmall,
          top: kSpacingSmall,
          bottom: kSpacingSmall,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.task_recent_tasks,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
          ),
        ),
      ),
    );

    final footer = OverlayMenuFooter(
      height: footerHeight,
      onTap: () {
        // 关闭弹窗并跳转到任务页面
        context.go('/tasks');
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: kSpacingSmall + kSpacingTiny, // 文字与图标对齐
          right: kSpacingSmall,
          top: kSpacingSmall,
          bottom: kSpacingSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.task_view_more,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
            ),
            RectangleIconButton.small(
              icon: Icons.open_in_new,
              iconColor: colorScheme.onSurfaceVariant,
              onPressed: null,
            ),
          ],
        ),
      ),
    );

    return OverlayMenu(
      maxHeight: headerHeight + footerHeight + itemHeight * 5,
      maxWidth: 500,
      spacing: kSpacingTiny,
      tabs: tabs,
      header: header,
      footer: footer,
      child: child,
    );
  }
}
