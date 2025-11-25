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
  bool _isGenerating = false;
  String? _errorMessage;
  bool _hasTriedInitializeDir = false; // 是否已尝试过初始化目录
  late final TextEditingController instanceIdController;
  late final TextEditingController dirController;
  late final TextEditingController fileNameController;
  late final TextEditingController descController;
  final _formKey = GlobalKey<FormState>();

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
        dirController.text = directory;
      });
      // 清除验证错误并更新按钮状态
      _formKey.currentState?.validate();
    }
  }

  ExportDataParameters _getExportDataParameters() {
    return ExportDataParameters(
      instanceId: widget.instanceId,
      schema: widget.schema,
      query: widget.query,
      fileDir: dirController.text.trim(),
      fileName: fileNameController.text.trim(),
    );
  }

  bool _isFormValid() {
    final formState = _formKey.currentState;
    if (formState == null) return false;

    // 检查所有字段是否有效
    final dirValid = dirController.text.trim().isNotEmpty;
    final fileNameValid = fileNameController.text.trim().isNotEmpty;

    return dirValid && fileNameValid;
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final parameters = _getExportDataParameters();

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
  }

  Future<void> _generateFileNameWithAI() async {
    final llmAgents = ref.read(lLMAgentServiceProvider);
    final lastUsedAgent = llmAgents.lastUsedLLMAgent;

    if (lastUsedAgent == null) {
      _showError(AppLocalizations.of(context)!.error_llm_agent_not_found);
      return;
    }

    // 清除之前的错误
    _showError(null);

    setState(() {
      _isGenerating = true;
    });

    try {
      // 构建参数
      final parameters = _getExportDataParameters();

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

      // 成功时清除错误并触发验证，更新按钮状态
      _showError(null);
      if (mounted) {
        setState(() {
          _formKey.currentState?.validate();
        });
      }
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)!
            .error_generate_file_name_failed(e.toString()));
      }
    } finally {
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
                      TextSpan(
                          text: AppLocalizations.of(context)!
                              .export_data_exporting),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: widget.schema,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                          text:
                              ' ${AppLocalizations.of(context)!.export_data_schema_sql}'),
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

  Widget _buildFileNameSuffixIcons(
      BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.only(right: kSpacingTiny),
      width: kIconButtonSizeSmall + kIconButtonSizeMedium + kSpacingTiny,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_errorMessage != null)
            RectangleIconButton.small(
              icon: Icons.error_outline,
              iconColor: colorScheme.error,
              tooltip: _errorMessage!,
            ),
          (_isGenerating)
              ? const Loading.medium()
              : RectangleIconButton.medium(
                  icon: Icons.auto_awesome,
                  tooltip: AppLocalizations.of(context)!
                      .tooltip_ai_generate_file_name,
                  iconColor: Colors.purple[600]!,
                  onPressed: _generateFileNameWithAI,
                ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    ColorScheme colorScheme, {
    required String labelText,
    Widget? suffixIcon,
    bool required = false,
  }) {
    return InputDecoration(
      label: required
          ? Text.rich(
              TextSpan(
                text: labelText,
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
              ),
            )
          : null,
      labelText: required ? null : labelText,
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
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 0.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 0.5,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final latestTask = ref.watch(latestExportTaskProvider);

    // 当有最新任务且目录字段为空时，自动填充目录（仅尝试一次）
    if (!_hasTriedInitializeDir &&
        latestTask != null &&
        dirController.text.trim().isEmpty) {
      final exportParams = latestTask.exportDataParameters;
      if (exportParams != null && exportParams.fileDir.isNotEmpty) {
        _hasTriedInitializeDir = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && dirController.text.trim().isEmpty) {
            setState(() {
              dirController.text = exportParams.fileDir;
            });
          }
        });
      } else {
        _hasTriedInitializeDir = true;
      }
    }

    return CustomDialog(
      title: AppLocalizations.of(context)!.export_data_title,
      titleIcon: const RectangleIconButton.medium(
        icon: Icons.file_download,
        iconColor: Colors.green,
        verticalOffset: 1.5,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 目录选择
            TextFormField(
              controller: dirController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              // 触发重建以更新提交按钮的启用状态
              onChanged: (_) {
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!
                      .export_data_directory_required;
                }
                return null;
              },
              decoration: _buildInputDecoration(
                colorScheme,
                labelText:
                    AppLocalizations.of(context)!.export_data_directory_label,
                required: true,
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: RectangleIconButton.medium(
                    icon: Icons.folder_open,
                    tooltip:
                        AppLocalizations.of(context)!.tooltip_select_directory,
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
                TextFormField(
                  controller: fileNameController,
                  enabled: !_isGenerating,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  // 触发重建以更新提交按钮的启用状态
                  onChanged: (_) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!
                          .export_data_file_name_required;
                    }
                    return null;
                  },
                  decoration: _buildInputDecoration(
                    colorScheme,
                    labelText:
                        AppLocalizations.of(context)!.task_column_file_name,
                    required: true,
                    suffixIcon: _buildFileNameSuffixIcons(context, colorScheme),
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),
            // 备注
            TextField(
              controller: descController,
              enabled: !_isGenerating,
              decoration: _buildInputDecoration(
                colorScheme,
                labelText: AppLocalizations.of(context)!.db_instance_desc,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: kSpacingMedium),
            // 任务信息卡片
            Expanded(child: _buildTaskInfoCard(context)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        const SizedBox(width: kSpacingSmall),
        TextButton(
          onPressed: _isFormValid() ? _handleSubmit : null,
          child: Text(AppLocalizations.of(context)!.submit),
        ),
      ],
    );
  }
}
