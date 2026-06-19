import 'dart:io';

import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/instances.dart';
import 'package:client/models/tasks.dart';
import 'package:client/services/ai/agent.dart';
import 'package:client/services/tasks/export_data.dart';
import 'package:client/utils/file_utils.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/dialog.dart';
import 'package:client/widgets/form.dart';
import 'package:client/widgets/loading.dart';
import 'package:client/widgets/sql_highlight.dart';
import 'package:db_driver/db_driver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

Future<ExportDataParameters?> showExportDataDialog(
  BuildContext context, {
  required InstanceId instanceId,
  required DatabaseRef? schema,
  required String query,
  required DatabaseType dbType,
}) async {
  return showDialog<ExportDataParameters>(
    context: context,
    builder: (_) => _ExportDataDialogContent(
      instanceId: instanceId,
      schema: schema,
      query: query,
      dbType: dbType,
    ),
  );
}

class _ExportDataDialogContent extends ConsumerStatefulWidget {
  final InstanceId instanceId;
  final DatabaseRef? schema;
  final String query;
  final DatabaseType dbType;

  const _ExportDataDialogContent({
    required this.instanceId,
    required this.schema,
    required this.query,
    required this.dbType,
  });

  @override
  ConsumerState<_ExportDataDialogContent> createState() => _ExportDataDialogContentState();
}

class _ExportDataDialogContentState extends ConsumerState<_ExportDataDialogContent> {
  static const _fieldDir = 'exportDir';
  static const _fieldFileName = 'fileName';
  static const _fieldDesc = 'desc';

  bool _isGenerating = false;
  String? _errorMessage;
  late final TextEditingController dirController;
  late final TextEditingController fileNameController;
  late final TextEditingController descController;
  final _formValidation = TrackedFormValidationController();

  @override
  void initState() {
    super.initState();
    // 填充文件名
    fileNameController = TextEditingController(
      text: 'export-${DateTime.now().toIso8601String().split('.').first.replaceAll(':', '-')}.csv',
    );
    // 自动填充目录, 确保有权限访问
    final latestTask = ref.read(latestExportTaskProvider);
    final latestDir = latestTask?.parameters?.fileDir;
    if (latestDir != null && checkDirectoryAccessible(latestDir) == null) {
      dirController = TextEditingController(text: latestDir);
    } else {
      dirController = TextEditingController();
    }

    descController = TextEditingController();
  }

  @override
  void dispose() {
    dirController.dispose();
    fileNameController.dispose();
    descController.dispose();
    _formValidation.dispose();
    super.dispose();
  }

  Future<void> _selectDirectory() async {
    final directory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: AppLocalizations.of(context)!.display_msg_downlaod,
    );
    if (directory != null) {
      dirController.text = directory;
      _formValidation.revalidateFields([_fieldDir]);
    }
  }

  String? _validateDirectory(dynamic value) {
    final trimmed = value is String ? value.trim() : '';
    if (trimmed.isEmpty) {
      return null;
    }
    final error = checkDirectoryAccessible(trimmed);
    if (error == null) {
      return null;
    }
    final localizations = AppLocalizations.of(context)!;
    switch (error) {
      case DirectoryAccessError.notExists:
        return localizations.error_directory_not_exists;
      case DirectoryAccessError.noPermission:
        if (Platform.isMacOS) {
          return localizations.error_directory_no_permission_macos;
        }
        return localizations.error_directory_no_permission;
    }
  }

  ExportDataParameters _getExportDataParameters() {
    return ExportDataParameters(
      instanceId: widget.instanceId,
      schema: widget.schema?.toString() ?? "",
      query: widget.query,
      fileDir: dirController.text.trim(),
      fileName: fileNameController.text.trim(),
    );
  }

  void _handleSubmit() {
    if (!_formValidation.validate()) {
      return;
    }

    final parameters = _getExportDataParameters();

    ref
        .read(exportDataTasksServicesProvider.notifier)
        .exportData(
          parameters,
          desc: descController.text,
        );

    Navigator.of(context).pop();
  }

  Future<void> _generateFileNameWithAI() async {
    final llmAgents = ref.read(lLMAgentProvider);
    final lastUsedAgent = llmAgents.lastUsedLLMAgent;

    if (lastUsedAgent == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.error_llm_agent_not_found;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
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

      // 设置文件名，确保带有.csv后缀
      String fileName = result.fileName.trim();
      if (!fileName.toLowerCase().endsWith('.csv')) {
        fileName = '$fileName.csv';
      }
      fileNameController.text = fileName;

      // 设置描述（如果有）
      if (result.desc != null && result.desc!.isNotEmpty) {
        descController.text = result.desc!;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.error_generate_file_name_failed(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Widget _buildSqlSectionSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);

    return RichText(
      text: TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: l10n.export_data_exporting),
          const TextSpan(text: ' '),
          TextSpan(
            text: '`${widget.schema}`',
            style: textStyle?.copyWith(color: cs.primary),
          ),
          TextSpan(text: ' ${l10n.export_data_schema_sql}'),
        ],
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSqlSectionSubtitle(context),
        const SizedBox(height: kSpacingMedium),
        Expanded(
          child: SizedBox.expand(
            child: TrackedTextFormField.labeledRow(
              context: context,
              label: l10n.export_data_sql_label,
              isRequired: false,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(kSpacingSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: ScrollConfiguration(
                  behavior: _NoScrollbarBehavior(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText.rich(
                        getSQLHighlightTextSpan(
                          widget.dbType.dialectType,
                          widget.query,
                          defalutStyle: GoogleFonts.robotoMono(
                            textStyle: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileNameSuffixIcons() {
    return Container(
      padding: const EdgeInsets.only(right: kSpacingTiny),
      width: kIconButtonSizeSmall + kIconButtonSizeMedium + kSpacingTiny,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_errorMessage != null)
            RectangleIconButton.small(
              icon: Icons.error_outline,
              iconColor: Theme.of(context).colorScheme.error,
              tooltip: _errorMessage!,
            ),
          (_isGenerating)
              ? const Loading.medium()
              : RectangleIconButton.medium(
                  icon: Icons.auto_awesome,
                  tooltip: AppLocalizations.of(context)!.tooltip_ai_generate_file_name,
                  iconColor: Colors.purple[600]!,
                  onPressed: _generateFileNameWithAI,
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomDialog(
      title: l10n.export_data_title,
      titleIcon: const Icon(Icons.file_download, color: Colors.green),
      maxWidth: 960,
      content: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrackedTextFormField(
            validationController: _formValidation,
            fieldName: _fieldDir,
            label: l10n.export_data_directory_label,
            isRequired: true,
            controller: dirController,
            validator: _validateDirectory,
            suffixIconBuilder: (context) => RectangleIconButton(
              size: kIconButtonSizeSmall,
              iconSize: kIconSizeSmall,
              padding: 6,
              icon: Icons.folder_open,
              tooltip: l10n.tooltip_select_directory,
              iconColor: Theme.of(context).colorScheme.primary,
              onPressed: _selectDirectory,
            ),
          ),
          TrackedTextFormField(
            validationController: _formValidation,
            fieldName: _fieldFileName,
            label: l10n.task_column_file_name,
            isRequired: true,
            controller: fileNameController,
            readOnly: _isGenerating,
            suffixIconBuilder: (context) => _buildFileNameSuffixIcons(),
          ),
          TrackedDescFormField(
            validationController: _formValidation,
            fieldName: _fieldDesc,
            label: l10n.db_instance_desc,
            controller: descController,
            readOnly: _isGenerating,
          ),
          Expanded(child: _buildTaskInfoCard()),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        const SizedBox(width: kSpacingSmall),
        TextButton(
          onPressed: _handleSubmit,
          child: Text(l10n.submit),
        ),
      ],
    );
  }
}
