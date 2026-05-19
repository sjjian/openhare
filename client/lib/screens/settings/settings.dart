import 'package:client/models/ai.dart';
import 'package:client/models/settings.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/services/ai/agent.dart';
import 'package:client/services/settings/settings.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/dialog.dart';
import 'package:client/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/widgets/divider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(settingProvider);
    final tab = ref.watch(settingTabServiceProvider).selectedSettingType;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PageSkeleton(
      key: const Key("settings"),
      child: BodyPageSkeleton(
        header: Row(
          children: [
            Text(
              l10n.settings,
              style: theme.textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SettingsNavTab(
                  label: l10n.settings_tab_general,
                  selected: tab == SettingType.system,
                  onTap: () => ref.read(settingTabServiceProvider.notifier).setSelectedSettingType(SettingType.system),
                ),
                SizedBox(width: kSpacingMedium),
                _SettingsNavTab(
                  label: l10n.llm_api,
                  selected: tab == SettingType.llmApi,
                  onTap: () => ref.read(settingTabServiceProvider.notifier).setSelectedSettingType(SettingType.llmApi),
                ),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: tab == SettingType.system ? 0 : 1,
                sizing: StackFit.expand,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(top: kSpacingMedium),
                    child: SystemSettingPage(model: model.systemSetting),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: kSpacingMedium),
                    child: const LLMApiSettingPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsNavTab extends StatefulWidget {
  const _SettingsNavTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SettingsNavTab> createState() => _SettingsNavTabState();
}

class _SettingsNavTabState extends State<_SettingsNavTab> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    final Color labelColor;
    if (widget.selected) {
      labelColor = _hovering ? Color.lerp(primary, theme.colorScheme.onSurface, 0.15)! : primary;
    } else {
      labelColor = _hovering ? primary : muted;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: labelColor,
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.selected ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.preferences,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: kSpacingSmall),
        const PixelDivider(),
        const SizedBox(height: kSpacingMedium),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: Row(
                children: [
                  const Icon(Icons.language),
                  const SizedBox(width: kSpacingSmall),
                  Text(l10n.language),
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
                  Text(l10n.theme),
                ],
              ),
            ),
            Row(
              children: [
                _SettingRadioOption(
                  title: Text(l10n.theme_light),
                  value: "light",
                  selectedValue: model.theme,
                  onTap: () => ref.read(systemSettingServiceProvider.notifier).setTheme("light"),
                ),
                const SizedBox(width: 8),
                _SettingRadioOption(
                  title: Text(l10n.theme_dark),
                  value: "dark",
                  selectedValue: model.theme,
                  onTap: () => ref.read(systemSettingServiceProvider.notifier).setTheme("dark"),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: kSpacingMedium),
        Row(
          children: [
            Text(
              l10n.settings_sql_shortcuts_section,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: kSpacingSmall),
        const PixelDivider(),
        const SizedBox(height: kSpacingMedium),
        ShortcutSettingField(
          kind: KeyboardShortcut.sqlExecute,
          leading: RectangleIconButton.medium(
            tooltip: l10n.button_tooltip_run_sql,
            icon: Icons.play_circle_outline_rounded,
            iconColor: Colors.green,
            verticalOffset: 0,
            onPressed: null,
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        ShortcutSettingField(
          kind: KeyboardShortcut.sqlExecuteAdd,
          leading: RectangleIconButton.medium(
            tooltip: l10n.button_tooltip_run_sql_new_tab,
            icon: Icons.not_started_outlined,
            iconColor: Colors.green,
            verticalOffset: 0,
            onPressed: null,
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        ShortcutSettingField(
          kind: KeyboardShortcut.sqlExplain,
          leading: RectangleIconButton.medium(
            tooltip: l10n.button_tooltip_explain_sql,
            icon: Icons.poll_outlined,
            iconColor: Color.fromARGB(255, 241, 192, 84),
            verticalOffset: 0,
            onPressed: null,
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        ShortcutSettingField(
          kind: KeyboardShortcut.sqlExport,
          leading: RectangleIconButton.medium(
            tooltip: l10n.button_tooltip_sql_result_download,
            icon: Icons.file_download_sharp,
            iconColor: Colors.green,
            verticalOffset: 1,
            onPressed: null,
          ),
        ),
      ],
    );
  }
}

class ShortcutSettingField extends ConsumerStatefulWidget {
  const ShortcutSettingField({
    super.key,
    required this.kind,
    required this.leading,
  });

  final KeyboardShortcut kind;
  final Widget leading;

  @override
  ConsumerState<ShortcutSettingField> createState() => ShortcutSettingFieldState();
}

class ShortcutSettingFieldState extends ConsumerState<ShortcutSettingField> {
  String? _conflictMessage;
  final FocusNode _focusNode = FocusNode();
  late final bool Function(KeyEvent) _hardwareHandler;
  bool _hardwareHandlerAttached = false;

  @override
  void initState() {
    super.initState();
    _hardwareHandler = _onHardwareKeyEvent;
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() => _conflictMessage = null);
      if (!_hardwareHandlerAttached) {
        HardwareKeyboard.instance.addHandler(_hardwareHandler);
        _hardwareHandlerAttached = true;
      }
    } else {
      _detachHardwareHandler();
    }
    setState(() {});
  }

  void _detachHardwareHandler() {
    if (_hardwareHandlerAttached) {
      HardwareKeyboard.instance.removeHandler(_hardwareHandler);
      _hardwareHandlerAttached = false;
    }
  }

  bool _tryApply(ShortcutModel? committed) {
    final notifier = ref.read(systemSettingServiceProvider.notifier);
    final attempted = committed ?? defaultShortcutModel(widget.kind);
    try {
      notifier.setShortcutModel(widget.kind, attempted);
    } on ShortcutBindingConflictException {
      setState(() {
        _conflictMessage = AppLocalizations.of(context)!.settings_sql_shortcut_conflict(attempted.toDisplayString());
      });
      return false;
    }
    setState(() => _conflictMessage = null);
    return true;
  }

  bool _isModifierLogicalKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.shift ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.alt ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.meta ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight ||
        key == LogicalKeyboardKey.capsLock;
  }

  ShortcutModel? _shortcutFromKeyDown(KeyDownEvent event) {
    if (_isModifierLogicalKey(event.logicalKey)) {
      return null;
    }
    final hw = HardwareKeyboard.instance;
    return ShortcutModel(
      keyId: event.logicalKey.keyId,
      meta: hw.isMetaPressed,
      control: hw.isControlPressed,
      alt: hw.isAltPressed,
      shift: hw.isShiftPressed,
    );
  }

  bool _onHardwareKeyEvent(KeyEvent event) {
    if (!_focusNode.hasFocus) {
      return false;
    }
    if (event is! KeyDownEvent) {
      return false;
    }

    if (event.logicalKey == LogicalKeyboardKey.tab) {
      return false;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace || event.logicalKey == LogicalKeyboardKey.delete) {
      final ok = _tryApply(null);
      if (ok) {
        _focusNode.unfocus();
      }
      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _focusNode.unfocus();
      return true;
    }

    final stored = _shortcutFromKeyDown(event);
    if (stored == null) {
      return false;
    }

    final ok = _tryApply(stored);
    if (ok) {
      _focusNode.unfocus();
    }
    return true;
  }

  @override
  void dispose() {
    _detachHardwareHandler();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    ref.watch(systemSettingServiceProvider);
    final notifier = ref.read(systemSettingServiceProvider.notifier);
    final displayLabel = notifier.getShortcutModel(widget.kind).toDisplayString();

    final outlineVariant = theme.colorScheme.outlineVariant;
    final primary = theme.colorScheme.primary;
    final hasFocus = _focusNode.hasFocus;
    final borderSide = BorderSide(
      color: hasFocus ? primary : outlineVariant,
      width: hasFocus ? 2 : 1,
    );
    const shortcutFieldRadius = BorderRadius.all(Radius.circular(12));

    final captureField = Tooltip(
      message: l10n.settings_sql_shortcut_field_hint,
      waitDuration: const Duration(milliseconds: 400),
      child: Focus(
        focusNode: _focusNode,
        child: MouseRegion(
          cursor: SystemMouseCursors.text,
          child: GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            behavior: HitTestBehavior.opaque,
            child: InputDecorator(
              isFocused: hasFocus,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderSide: borderSide, borderRadius: shortcutFieldRadius),
                enabledBorder: OutlineInputBorder(borderSide: borderSide, borderRadius: shortcutFieldRadius),
                focusedBorder: OutlineInputBorder(borderSide: borderSide, borderRadius: shortcutFieldRadius),
              ),
              child: Text(
                displayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.leading,
        const SizedBox(width: kSpacingSmall),
        SizedBox(width: 240, child: captureField),
        if (_conflictMessage != null) ...[
          const SizedBox(width: kSpacingSmall),
          Expanded(
            child: Text(
              _conflictMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
      childAspectRatio: 1.5,
      children: [
        for (var id in models.agents.keys)
          LLMApiSettingItem(
            key: Key(id.value.toString()),
            model: models.agents[id]!,
            onUpdate: (m) {
              ref.read(lLMAgentServiceProvider.notifier).updateSetting(id, m);
            },
            onDelete: (m) {
              ref.read(lLMAgentServiceProvider.notifier).delete(m);
            },
          ),
        AddLLMApiSettingItem(
          onAdd: (m) {
            ref.read(lLMAgentServiceProvider.notifier).create(m);
          },
        ),
      ],
    );
  }
}

// todo: 表单输入框抽取公共库
InputDecoration _buildDialogInputDecoration(BuildContext context, {required String labelText}) {
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
    border: defaultBorder,
    enabledBorder: defaultBorder,
    disabledBorder: defaultBorder,
    focusedBorder: defaultBorder,
    errorBorder: errorBorderStyle,
    focusedErrorBorder: errorBorderStyle,
  );
}

void showLLMApiSettingDialog(
  BuildContext context,
  String title,
  LLMAgentModel? model,
  Function(LLMAgentSettingModel) onSubmit,
) {
  final nameController = TextEditingController(text: model?.setting.name);
  final baseUrlController = TextEditingController(text: model?.setting.baseUrl);
  final apiKeyController = TextEditingController(text: model?.setting.apiKey);
  final modelNameController = TextEditingController(text: model?.setting.modelName);

  showDialog(
    context: context,
    builder: (context) {
      return CustomDialog(
        title: title,
        subtitle: AppLocalizations.of(context)!.llm_api_only_openai_compatible,
        titleIcon: Icon(Icons.extension, color: Theme.of(context).colorScheme.primary),
        maxWidth: 600,
        maxHeight: 420,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
            ),
          ),
          const SizedBox(width: kSpacingSmall),
          TextButton(
            onPressed: () {
              onSubmit(
                LLMAgentSettingModel(
                  name: nameController.text,
                  baseUrl: baseUrlController.text,
                  apiKey: apiKeyController.text,
                  modelName: modelNameController.text,
                ),
              );
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.submit),
          ),
        ],
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: _buildDialogInputDecoration(
                context,
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: kSpacingMedium),
            TextField(
              controller: baseUrlController,
              decoration: _buildDialogInputDecoration(
                context,
                labelText: 'Base URL',
              ),
            ),
            const SizedBox(height: kSpacingMedium),
            TextField(
              controller: apiKeyController,
              decoration: _buildDialogInputDecoration(
                context,
                labelText: 'API Key',
              ),
            ),
            const SizedBox(height: kSpacingMedium),
            TextField(
              controller: modelNameController,
              decoration: _buildDialogInputDecoration(
                context,
                labelText: 'Model',
              ),
            ),
          ],
        ),
      );
    },
  );
}

class LLMApiSettingItem extends ConsumerWidget {
  final LLMAgentModel model;
  final Function(LLMAgentSettingModel) onUpdate;
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
                switch (status.state) {
                  LLMAgentState.testing => const Loading.small(),
                  LLMAgentState.available => RectangleIconButton.small(
                    tooltip: AppLocalizations.of(context)!.button_tooltip_ai_test,
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                    onPressed: () {
                      ref.read(lLMAgentServiceProvider.notifier).ping(model.id);
                    },
                  ),
                  LLMAgentState.unavailable => RectangleIconButton.small(
                    tooltip: status.error ?? "",
                    icon: Icons.error_outline,
                    iconColor: Colors.red,
                    onPressed: () {
                      ref.read(lLMAgentServiceProvider.notifier).ping(model.id);
                    },
                  ),
                  LLMAgentState.unknown => RectangleIconButton.small(
                    tooltip: AppLocalizations.of(context)!.button_tooltip_ai_test,
                    icon: Icons.flash_on,
                    onPressed: () {
                      ref.read(lLMAgentServiceProvider.notifier).ping(model.id);
                    },
                  ),
                },
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
  final Function(LLMAgentSettingModel) onAdd;
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
