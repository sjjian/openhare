import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/instances.dart';
import 'package:client/models/tasks.dart';
import 'package:client/services/ai/agent.dart';
import 'package:client/services/tasks/task.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/dialog.dart';
import 'package:client/widgets/loading.dart';
import 'package:client/widgets/sql_highlight.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

Future<ExportDataParameters?> showExportDataDialog(
  BuildContext context, {
  required InstanceId instanceId,
  required String schema,
  required String query,
}) async {
  return showDialog<ExportDataParameters>(
    context: context,
    builder: (dialogContext) {
      return _ExportDataDialogContent(
        parentContext: context,
        instanceId: instanceId,
        schema: schema,
        query: query,
      );
    },
  );
}

class _ExportDataDialogContent extends ConsumerStatefulWidget {
  final BuildContext parentContext;
  final InstanceId instanceId;
  final String schema;
  final String query;

  const _ExportDataDialogContent({
    required this.parentContext,
    required this.instanceId,
    required this.schema,
    required this.query,
  });

  @override
  ConsumerState<_ExportDataDialogContent> createState() =>
      _ExportDataDialogContentState();
}

class _ExportDataDialogContentState
    extends ConsumerState<_ExportDataDialogContent> {
  String? selectedDir;
  bool _isGenerating = false;
  String? _errorMessage;
  late final TextEditingController instanceIdController;
  late final TextEditingController dirController;
  late final TextEditingController fileNameController;
  late final TextEditingController descController;

  @override
  void initState() {
    super.initState();
    instanceIdController = TextEditingController(
      text: widget.instanceId.value.toString(),
    );
    dirController = TextEditingController();
    fileNameController = TextEditingController(
      text:
          'export-${DateTime.now().toIso8601String().replaceAll(":", "-").split('.')[0]}.xlsx',
    );
    descController = TextEditingController();
  }

  @override
  void dispose() {
    instanceIdController.dispose();
    dirController.dispose();
    fileNameController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _selectDirectory() async {
    final directory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: AppLocalizations.of(context)!.display_msg_downlaod,
    );
    if (directory != null) {
      setState(() {
        selectedDir = directory;
        dirController.text = directory;
      });
    }
  }

  void _handleSubmit() {
    if (selectedDir == null ||
        selectedDir!.isEmpty ||
        fileNameController.text.trim().isEmpty) {
      return;
    }

    final parameters = ExportDataParameters(
      instanceId: widget.instanceId,
      schema: widget.schema,
      query: widget.query,
      fileDir: selectedDir!,
      fileName: fileNameController.text.trim(),
    );

    ref.read(tasksServicesProvider.notifier).exportData(
          parameters,
          desc: descController.text,
        );

    Navigator.of(context).pop();
  }

  void _showError(String? message) {
    setState(() {
      _errorMessage = message;
    });
    // 3秒后自动清除错误消息
    if (message != null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _errorMessage == message) {
          setState(() {
            _errorMessage = null;
          });
        }
      });
    }
  }

  Future<void> _generateFileNameWithAI() async {
    try {
      final llmAgents = ref.read(lLMAgentServiceProvider);
      final lastUsedAgent = llmAgents.lastUsedLLMAgent;

      if (lastUsedAgent == null) {
        _showError('未找到可用的LLM Agent，请先在设置中配置');
        return;
      }

      // 清除之前的错误
      _showError(null);

      setState(() {
        _isGenerating = true;
      });

      try {
        // 构建参数
        final parameters = ExportDataParameters(
          instanceId: widget.instanceId,
          schema: widget.schema,
          query: widget.query,
          fileDir: selectedDir ?? '',
          fileName: fileNameController.text.trim(),
        );

        // 调用AI生成文件名和描述
        final result = await ref
            .read(lLMAgentServiceProvider.notifier)
            .generateExportFileName(
              lastUsedAgent.id,
              parameters,
            );

        // 设置文件名，确保带有.xlsx后缀
        String fileName = result.fileName.trim();
        if (!fileName.toLowerCase().endsWith('.xlsx')) {
          fileName = '$fileName.xlsx';
        }
        fileNameController.text = fileName;

        // 设置描述（如果有）
        if (result.desc != null && result.desc!.isNotEmpty) {
          descController.text = result.desc!;
        }

        // 成功时清除错误
        _showError(null);
      } catch (e) {
        _showError('生成文件名失败: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
        }
      }
    } catch (e) {
      _showError('发生未知错误: ${e.toString()}');
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Widget _buildTaskInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final textStyle = GoogleFonts.robotoMono(
      textStyle: textTheme.bodySmall,
      color: colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingSmall,
              vertical: kSpacingMedium,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: colorScheme.outline,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    children: [
                      const TextSpan(text: '正在导出 '),
                      TextSpan(
                        text: widget.schema,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const TextSpan(text: ' schema 的 SQL，SQL 如下：'),
                    ],
                  ),
                ),
                const SizedBox(height: kSpacingMedium),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: _NoScrollbarBehavior(),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SelectableText.rich(
                          getSQLHighlightTextSpan(
                            widget.query,
                            defalutStyle: textStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    ColorScheme colorScheme, {
    required String labelText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 0.5,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return CustomDialog(
      title: '导出数据',
      titleIcon: const Icon(
        Icons.file_download,
        color: Colors.green,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 目录选择
          TextField(
            controller: dirController,
            decoration: _buildInputDecoration(
              colorScheme,
              labelText: '保存的地址',
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: RectangleIconButton.medium(
                  icon: Icons.folder_open,
                  tooltip: "选择目录",
                  iconColor: colorScheme.primary,
                  onPressed: _selectDirectory,
                ),
              ),
            ),
          ),
          const SizedBox(height: kSpacingMedium),
          // 文件名输入
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: fileNameController,
                enabled: !_isGenerating,
                decoration: _buildInputDecoration(
                  colorScheme,
                  labelText: '文件名',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: _isGenerating
                        ? const Loading.medium()
                        : RectangleIconButton.medium(
                            icon: Icons.auto_awesome,
                            tooltip: _errorMessage ?? "使用AI自动生成文件名和描述",
                            iconColor: _errorMessage != null
                                ? colorScheme.error
                                : Colors.purple[600]!,
                            onPressed: _generateFileNameWithAI,
                          ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: kSpacingSmall),
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: kSpacingMedium),
          // 备注
          TextField(
            controller: descController,
            enabled: !_isGenerating,
            decoration: _buildInputDecoration(
              colorScheme,
              labelText: '备注',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: kSpacingMedium),
          // 任务信息卡片
          Expanded(child: _buildTaskInfoCard(context)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        const SizedBox(width: kSpacingSmall),
        TextButton(
          onPressed: selectedDir == null ||
                  selectedDir!.isEmpty ||
                  fileNameController.text.trim().isEmpty
              ? null
              : _handleSubmit,
          child: Text(AppLocalizations.of(context)!.submit),
        ),
      ],
    );
  }
}
