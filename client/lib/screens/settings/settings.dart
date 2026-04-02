import 'dart:async';

import 'package:client/models/ai.dart';
import 'package:client/models/settings.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/services/ai/agent.dart';
import 'package:client/services/ai/llm_sdk.dart';
import 'package:client/services/settings/settings.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/dialog.dart';
import 'package:client/widgets/divider.dart';
import 'package:client/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SettingModel model = ref.watch(settingProvider);

    return PageSkeleton(
      key: const Key("settings"),
      child: BodyPageSkeleton(
        header: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.settings,
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.preferences,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),
            SystemSettingPage(model: model.systemSetting),
            const SizedBox(height: kSpacingMedium),
            const PixelDivider(),
            const SizedBox(height: kSpacingMedium),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.llm_api,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: kSpacingMedium),
            const Expanded(
              child: LLMApiSettingPage(),
            ),
          ],
        ),
      ),
    );
  }
}

class SystemSettingPage extends ConsumerWidget {
  final SystemSettingModel model;
  const SystemSettingPage({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 120,
              child: Row(
                children: [
                  const Icon(Icons.language),
                  const SizedBox(width: kSpacingSmall),
                  Text(AppLocalizations.of(context)!.language),
                ],
              ),
            ),
            Row(
              children: [
                _SettingRadioOption(
                  title: const Text("English"),
                  value: "en",
                  selectedValue: model.language,
                  onTap: () => ref.read(systemSettingServiceProvider.notifier).setLanguage("en"),
                ),
                const SizedBox(width: 8),
                _SettingRadioOption(
                  title: const Text("中文"),
                  value: "zh",
                  selectedValue: model.language,
                  onTap: () => ref.read(systemSettingServiceProvider.notifier).setLanguage("zh"),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: kSpacingSmall),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: Row(
                children: [
                  const Icon(Icons.color_lens),
                  const SizedBox(width: kSpacingSmall),
                  Text(AppLocalizations.of(context)!.theme),
                ],
              ),
            ),
            Row(
              children: [
                _SettingRadioOption(
                  title: Text(AppLocalizations.of(context)!.theme_light),
                  value: "light",
                  selectedValue: model.theme,
                  onTap: () => ref.read(systemSettingServiceProvider.notifier).setTheme("light"),
                ),
                const SizedBox(width: 8),
                _SettingRadioOption(
                  title: Text(AppLocalizations.of(context)!.theme_dark),
                  value: "dark",
                  selectedValue: model.theme,
                  onTap: () => ref.read(systemSettingServiceProvider.notifier).setTheme("dark"),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}

class _SettingRadioOption extends StatelessWidget {
  final Widget title;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;

  const _SettingRadioOption({
    required this.title,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedValue == value;

    return SizedBox(
      width: 140,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(kSpacingSmall),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.surfaceContainerLow : colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: kIconSizeSmall,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: kSpacingSmall),
                Expanded(child: title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LLMApiSettingPage extends ConsumerWidget {
  const LLMApiSettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final models = ref.watch(lLMAgentProvider);

    return GridView.extent(
      maxCrossAxisExtent: 350,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: [
        for (var id in models.agents.keys)
          LLMApiSettingItem(
            key: Key(id.value.toString()),
            model: models.agents[id]!,
            onUpdate: (m, status) {
              ref.read(lLMAgentServiceProvider.notifier).updateSetting(id, m, status: status);
            },
            onDelete: (m) {
              ref.read(lLMAgentServiceProvider.notifier).delete(m);
            },
          ),
        AddLLMApiSettingItem(
          onAdd: (m, status) {
            ref.read(lLMAgentServiceProvider.notifier).create(m, status: status);
          },
        ),
      ],
    );
  }
}

// todo: 表单输入框抽取公共库
InputDecoration _buildDialogInputDecoration(
  BuildContext context, {
  required String labelText,
  String? helperText,
  Widget? suffixIcon,
}) {
  final defaultBorder = OutlineInputBorder(
    borderSide: BorderSide(
      color: Theme.of(context).colorScheme.outline,
    ),
  );
  final errorBorderStyle = OutlineInputBorder(
    borderSide: BorderSide(
      color: Theme.of(context).colorScheme.error,
    ),
  );

  return InputDecoration(
    labelText: labelText,
    helperText: helperText,
    suffixIcon: suffixIcon,
    border: defaultBorder,
    enabledBorder: defaultBorder,
    disabledBorder: defaultBorder,
    focusedBorder: defaultBorder,
    errorBorder: errorBorderStyle,
    focusedErrorBorder: errorBorderStyle,
  );
}

String _readableError(Object error) {
  final text = error.toString().trim();
  for (final prefix in const ['Exception: ', 'FormatException: ']) {
    if (text.startsWith(prefix)) {
      return text.substring(prefix.length);
    }
  }
  return text;
}

void showLLMApiSettingDialog(
  BuildContext context,
  String title,
  LLMAgentModel? model,
  void Function(LLMAgentSettingModel, LLMAgentStatusModel?) onSubmit,
) {
  showDialog(
    context: context,
    builder: (context) {
      return _LLMApiSettingDialogContent(
        title: title,
        model: model,
        onSubmit: onSubmit,
      );
    },
  );
}

class _LLMApiSettingDialogContent extends ConsumerStatefulWidget {
  final String title;
  final LLMAgentModel? model;
  final void Function(LLMAgentSettingModel, LLMAgentStatusModel?) onSubmit;

  const _LLMApiSettingDialogContent({
    required this.title,
    required this.model,
    required this.onSubmit,
  });

  @override
  ConsumerState<_LLMApiSettingDialogContent> createState() => _LLMApiSettingDialogContentState();
}

class _LLMApiSettingDialogContentState extends ConsumerState<_LLMApiSettingDialogContent> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelController;
  late final FocusNode _modelFocusNode;
  late final MenuController _modelMenuController;

  bool _obscureApiKey = true;
  bool _isFetchingModels = false;
  bool _isTestingConnection = false;
  List<String> _availableModels = const [];
  String? _fetchStatusMessage;
  bool _fetchStatusError = false;
  String? _testStatusMessage;
  bool _testStatusError = false;
  LLMAgentStatusModel? _draftStatusToSync;

  @override
  void initState() {
    super.initState();
    final setting = widget.model?.setting;
    _nameController = TextEditingController(text: setting?.name ?? '');
    _baseUrlController = TextEditingController(text: setting?.baseUrl ?? defaultOpenAIBaseUrl);
    _apiKeyController = TextEditingController(text: setting?.apiKey ?? '');
    _modelController = TextEditingController(text: setting?.modelName ?? '');
    _modelFocusNode = FocusNode();
    _modelMenuController = MenuController();
    _modelFocusNode.addListener(_handleModelFieldFocusChange);
    _modelController.addListener(_invalidateTestState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.removeListener(_invalidateTestState);
    _modelController.dispose();
    _modelFocusNode.removeListener(_handleModelFieldFocusChange);
    _modelFocusNode.dispose();
    super.dispose();
  }

  LLMAgentSettingModel _buildDraftSetting() {
    final rawName = _nameController.text.trim();
    final modelName = _modelController.text.trim();

    return LLMAgentSettingModel(
      name: rawName.isNotEmpty
          ? rawName
          : buildDefaultLLMAgentName(
              baseUrl: _baseUrlController.text.trim(),
              modelName: modelName,
            ),
      baseUrl: _baseUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      modelName: modelName,
    );
  }

  bool _hasConnectionFieldsChanged() {
    final original = widget.model?.setting;
    if (original == null) {
      return true;
    }

    return original.baseUrl.trim() != _baseUrlController.text.trim() ||
        original.apiKey.trim() != _apiKeyController.text.trim() ||
        original.modelName.trim() != _modelController.text.trim();
  }

  void _invalidateFetchState() {
    final shouldUpdate = _fetchStatusMessage != null || _fetchStatusError || _availableModels.isNotEmpty;
    if (!shouldUpdate) {
      return;
    }

    setState(() {
      _availableModels = const [];
      _fetchStatusMessage = null;
      _fetchStatusError = false;
    });
  }

  void _invalidateTestState() {
    final shouldUpdate = _testStatusMessage != null || _testStatusError || _draftStatusToSync != null;
    if (!shouldUpdate) {
      return;
    }

    setState(() {
      _testStatusMessage = null;
      _testStatusError = false;
      _draftStatusToSync = null;
    });
  }

  String? _requiredValidator(BuildContext context, String? value) {
    if ((value ?? '').trim().isEmpty) {
      return AppLocalizations.of(context)!.field_val_msg_value_reqiured;
    }
    return null;
  }

  bool _ensureModelSelected() {
    if (_modelController.text.trim().isNotEmpty) {
      return true;
    }

    setState(() {
      _testStatusError = true;
      _testStatusMessage = AppLocalizations.of(context)!.field_val_msg_value_reqiured;
    });
    _modelFocusNode.requestFocus();
    return false;
  }

  void _handleModelFieldFocusChange() {
    if (!_modelFocusNode.hasFocus || _isFetchingModels) {
      return;
    }

    if (_baseUrlController.text.trim().isEmpty || _apiKeyController.text.trim().isEmpty) {
      setState(() {
        _fetchStatusError = true;
        _fetchStatusMessage = AppLocalizations.of(context)!.llm_api_fetch_prerequisite;
      });
      return;
    }

    if (_availableModels.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _modelFocusNode.hasFocus) {
          _modelMenuController.open();
        }
      });
      return;
    }

    _handleFetchModels(openMenuAfterFetch: true);
  }

  Future<void> _handleFetchModels({bool openMenuAfterFetch = false}) async {
    if (_baseUrlController.text.trim().isEmpty || _apiKeyController.text.trim().isEmpty) {
      setState(() {
        _fetchStatusError = true;
        _fetchStatusMessage = AppLocalizations.of(context)!.llm_api_fetch_prerequisite;
      });
      return;
    }

    setState(() {
      _isFetchingModels = true;
      _fetchStatusError = false;
      _fetchStatusMessage = null;
    });

    try {
      final models = await ref.read(lLMAgentServiceProvider.notifier).fetchModelsDraft(_buildDraftSetting());
      if (!mounted) {
        return;
      }

      setState(() {
        _availableModels = models;
        _fetchStatusError = false;
        _fetchStatusMessage = models.isEmpty
            ? AppLocalizations.of(context)!.llm_api_models_empty
            : AppLocalizations.of(context)!.llm_api_models_found(models.length);
      });
      if (openMenuAfterFetch && models.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _modelFocusNode.hasFocus) {
            _modelMenuController.open();
          }
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _availableModels = const [];
        _fetchStatusError = true;
        _fetchStatusMessage =
            '${AppLocalizations.of(context)!.llm_api_fetch_failed_but_manual_ok}: ${_readableError(error)}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingModels = false;
        });
      }
    }
  }

  Future<void> _handleTestConnection() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (!_ensureModelSelected()) {
      return;
    }

    setState(() {
      _isTestingConnection = true;
      _testStatusError = false;
      _testStatusMessage = null;
    });

    try {
      await ref.read(lLMAgentServiceProvider.notifier).pingDraft(_buildDraftSetting());
      if (!mounted) {
        return;
      }

      setState(() {
        _testStatusError = false;
        _testStatusMessage = AppLocalizations.of(context)!.llm_api_connection_success;
        _draftStatusToSync = const LLMAgentStatusModel(state: LLMAgentState.available);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = _readableError(error);
      setState(() {
        _testStatusError = true;
        _testStatusMessage = '${AppLocalizations.of(context)!.test_failed}: $message';
        _draftStatusToSync = LLMAgentStatusModel(
          state: LLMAgentState.unavailable,
          error: message,
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isTestingConnection = false;
        });
      }
    }
  }

  void _resetForm() {
    final original = widget.model?.setting;
    _formKey.currentState?.reset();
    _nameController.text = original?.name ?? '';
    _baseUrlController.text = original?.baseUrl ?? defaultOpenAIBaseUrl;
    _apiKeyController.text = original?.apiKey ?? '';
    _modelController.text = original?.modelName ?? '';
    _availableModels = const [];
    _fetchStatusMessage = null;
    _fetchStatusError = false;
    _testStatusMessage = null;
    _testStatusError = false;
    _draftStatusToSync = null;
    setState(() {});
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (!_ensureModelSelected()) {
      return;
    }

    final syncedStatus = _draftStatusToSync ?? (!_hasConnectionFieldsChanged() ? widget.model?.status : null);
    widget.onSubmit(_buildDraftSetting(), syncedStatus);
    Navigator.of(context).pop();
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall,
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, title),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  LLMAgentStatusModel get _effectiveDialogStatus {
    if (_isTestingConnection) {
      return const LLMAgentStatusModel(state: LLMAgentState.testing);
    }
    if (_draftStatusToSync != null) {
      return _draftStatusToSync!;
    }
    if (!_hasConnectionFieldsChanged() && widget.model != null) {
      return widget.model!.status;
    }
    return const LLMAgentStatusModel(state: LLMAgentState.unknown);
  }

  String _dialogStatusTooltip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = _effectiveDialogStatus;
    return switch (status.state) {
      LLMAgentState.available => l10n.llm_api_connection_success,
      LLMAgentState.unavailable => status.error ?? l10n.test_failed,
      LLMAgentState.testing => l10n.testing,
      LLMAgentState.unknown => l10n.llm_api_test_connection,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return CustomDialog(
      title: widget.title,
      subtitle: l10n.llm_api_only_openai_compatible,
      titleIcon: Icon(Icons.extension, color: Theme.of(context).colorScheme.primary),
      maxWidth: 720,
      maxHeight: 560,
      actions: [
        TextButton(
          onPressed: _resetForm,
          child: Text(l10n.llm_api_reset_form),
        ),
        const SizedBox(width: kSpacingSmall),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.cancel),
        ),
        const SizedBox(width: kSpacingSmall),
        _LLMAgentTestAction(
          status: _effectiveDialogStatus,
          tooltip: _dialogStatusTooltip(context),
          onPressed: _handleTestConnection,
        ),
        const SizedBox(width: kSpacingSmall),
        FilledButton(
          onPressed: _handleSubmit,
          child: Text(l10n.submit),
        ),
      ],
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                context,
                title: l10n.llm_api_connection_info,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      key: const Key('llm-name-field'),
                      controller: _nameController,
                      decoration: _buildDialogInputDecoration(
                        context,
                        labelText: l10n.llm_api_name,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('llm-base-url-field'),
                      controller: _baseUrlController,
                      validator: (value) => _requiredValidator(context, value),
                      onChanged: (_) {
                        _invalidateFetchState();
                        _invalidateTestState();
                      },
                      decoration: _buildDialogInputDecoration(
                        context,
                        labelText: l10n.llm_api_endpoint,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('llm-api-key-field'),
                      controller: _apiKeyController,
                      validator: (value) => _requiredValidator(context, value),
                      obscureText: _obscureApiKey,
                      onChanged: (_) {
                        _invalidateFetchState();
                        _invalidateTestState();
                      },
                      decoration: _buildDialogInputDecoration(
                        context,
                        labelText: 'API Key',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureApiKey ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscureApiKey = !_obscureApiKey;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                title: l10n.llm_api_model_info,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      key: const Key('llm-model-field'),
                      width: double.infinity,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return DropdownMenu<String>(
                            controller: _modelController,
                            focusNode: _modelFocusNode,
                            menuController: _modelMenuController,
                            width: constraints.maxWidth,
                            menuHeight: 240,
                            requestFocusOnTap: true,
                            enableFilter: true,
                            enableSearch: true,
                            hintText: _isFetchingModels ? l10n.testing : null,
                            helperText: null,
                            label: const Text('Model'),
                            onSelected: (selection) {
                              if (selection == null) {
                                return;
                              }
                              _modelController.text = selection;
                              _invalidateTestState();
                            },
                            inputDecorationTheme: const InputDecorationTheme(
                              border: OutlineInputBorder(),
                            ),
                            dropdownMenuEntries: _availableModels
                                .map(
                                  (option) => DropdownMenuEntry<String>(
                                    value: option,
                                    label: option,
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ),
                    if (_fetchStatusMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _isFetchingModels ? l10n.testing : _fetchStatusMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _fetchStatusError ? colorScheme.error : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LLMApiSettingItem extends ConsumerWidget {
  final LLMAgentModel model;
  final void Function(LLMAgentSettingModel, LLMAgentStatusModel?) onUpdate;
  final Function(LLMAgentId) onDelete;

  const LLMApiSettingItem({
    super.key,
    required this.model,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(lLMAgentProvider).agents[model.id]!.status;

    return Container(
      constraints: const BoxConstraints(),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow, // LLM API配置卡片的背景颜色
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), // 添加模型的卡片边框颜色
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kSpacingMedium, kSpacingSmall, kSpacingMedium, kSpacingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    model.setting.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                RectangleIconButton.small(
                  icon: Icons.close,
                  onPressed: () {
                    onDelete(model.id); // todo: 需要二次确认
                  },
                ),
              ],
            ),
            const SizedBox(height: kSpacingSmall),
            _InfoRow(label: "Base URL", value: model.setting.baseUrl),
            const SizedBox(height: kSpacingTiny),
            _InfoRow(
              label: "API Key",
              value: model.setting.apiKey.length > 10
                  ? model.setting.apiKey.replaceRange(
                      4,
                      model.setting.apiKey.length - 4,
                      '*' * (model.setting.apiKey.length - 8),
                    )
                  : model.setting.apiKey,
            ),
            const SizedBox(height: kSpacingTiny),
            _InfoRow(label: "Model", value: model.setting.modelName),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                _LLMAgentTestAction(
                  status: status,
                  tooltip: status.state == LLMAgentState.unavailable
                      ? (status.error ?? AppLocalizations.of(context)!.button_tooltip_ai_test)
                      : AppLocalizations.of(context)!.button_tooltip_ai_test,
                  onPressed: () async {
                    ref.read(lLMAgentServiceProvider.notifier).ping(model.id);
                  },
                ),
                RectangleIconButton.small(
                  icon: Icons.edit,
                  onPressed: () {
                    showLLMApiSettingDialog(
                      context,
                      '${AppLocalizations.of(context)!.update}: ${model.setting.name}',
                      model,
                      onUpdate,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddLLMApiSettingItem extends StatelessWidget {
  final void Function(LLMAgentSettingModel, LLMAgentStatusModel?) onAdd;
  const AddLLMApiSettingItem({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow, // 添加模型的卡片的背景颜色
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), // 添加模型的卡片边框颜色
      ),
      child: Center(
        child: IconButton(
          onPressed: () {
            showLLMApiSettingDialog(
              context,
              AppLocalizations.of(context)!.create,
              null,
              onAdd,
            );
          },
          icon: Icon(
            Icons.add,
            size: kIconSizeLarge,
            color: Theme.of(context).colorScheme.onSurfaceVariant, // 添加模型的按钮颜色
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _LLMAgentTestAction extends StatelessWidget {
  final LLMAgentStatusModel status;
  final String tooltip;
  final Future<void> Function() onPressed;

  const _LLMAgentTestAction({
    required this.status,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    switch (status.state) {
      case LLMAgentState.testing:
        return const Loading.small();
      case LLMAgentState.available:
        return RectangleIconButton.small(
          tooltip: tooltip,
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
          onPressed: () {
            unawaited(onPressed());
          },
        );
      case LLMAgentState.unavailable:
        return RectangleIconButton.small(
          tooltip: tooltip,
          icon: Icons.error_outline,
          iconColor: Theme.of(context).colorScheme.error,
          onPressed: () {
            unawaited(onPressed());
          },
        );
      case LLMAgentState.unknown:
        return RectangleIconButton.small(
          tooltip: tooltip,
          icon: Icons.flash_on,
          onPressed: () {
            unawaited(onPressed());
          },
        );
    }
  }
}
