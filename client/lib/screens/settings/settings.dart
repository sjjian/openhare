import 'package:client/models/settings.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/services/settings/settings.dart';
import 'package:client/widgets/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SettingModel model = ref.watch(settingNotifierProvider);

    return PageSkeleton(
      key: const Key("settings"),
      child: BodyPageSkeleton(
        header: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.settings,
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingTabButton(
                    text: AppLocalizations.of(context)!.preferences,
                    onTap: () {
                      ref
                          .read(settingTabServiceProvider.notifier)
                          .setSelectedSettingType(SettingType.system);
                    },
                    isSelected: model.settingTab.selectedSettingType ==
                        SettingType.system,
                  ),
                  const SizedBox(width: kSpacingMedium),
                  SettingTabButton(
                    text: AppLocalizations.of(context)!.llm_api,
                    onTap: () {
                      ref
                          .read(settingTabServiceProvider.notifier)
                          .setSelectedSettingType(SettingType.llmApi);
                    },
                    isSelected: model.settingTab.selectedSettingType ==
                        SettingType.llmApi,
                  ),
                ],
              ),
            ),
            const SizedBox(height: kSpacingSmall),
            Expanded(
              child: IndexedStack(
                index: model.settingTab.selectedSettingType.index,
                children: [
                  SystemSettingPage(model: model.systemSetting),
                  LLMApiSettingPage(models: model.llmApiSettings),
                ],
              ),
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
                  Text(AppLocalizations.of(context)!.language)
                ],
              ),
            ),
            SizedBox(
              width: 140,
              child: RadioListTile<String>(
                title: const Text("English"),
                value: "en",
                groupValue: model.language,
                onChanged: (value) {
                  ref
                      .read(systemSettingServiceProvider.notifier)
                      .setLanguage(value!);
                },
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(
              width: 140,
              child: RadioListTile<String>(
                title: const Text("中文"),
                value: "zh",
                groupValue: model.language,
                onChanged: (value) {
                  ref
                      .read(systemSettingServiceProvider.notifier)
                      .setLanguage(value!);
                },
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: kSpacingTiny),
        const Divider(
          thickness: kDividerThickness,
          height: kDividerSize,
        ),
        const SizedBox(height: kSpacingTiny),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: Row(
                children: [
                  const Icon(Icons.color_lens),
                  const SizedBox(width: kSpacingSmall),
                  Text(AppLocalizations.of(context)!.theme)
                ],
              ),
            ),
            SizedBox(
              width: 140,
              child: RadioListTile<String>(
                title: Text(AppLocalizations.of(context)!.theme_light),
                value: "light",
                groupValue: model.theme,
                onChanged: (value) {
                  ref
                      .read(systemSettingServiceProvider.notifier)
                      .setTheme(value!);
                },
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero, // Remove default padding
              ),
            ),
            SizedBox(
              width: 140,
              child: RadioListTile<String>(
                title: Text(AppLocalizations.of(context)!.theme_dark),
                value: "dark",
                groupValue: model.theme,
                onChanged: (value) {
                  ref
                      .read(systemSettingServiceProvider.notifier)
                      .setTheme(value!);
                },
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Spacer(),
          ],
        ),
        const Spacer(),
      ],
    );
  }
}

class LLMApiSettingPage extends ConsumerWidget {
  final List<LLMApiSettingModel> models;
  const LLMApiSettingPage({super.key, required this.models});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.extent(
      maxCrossAxisExtent: 350,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        for (var model in models)
          LLMApiSettingItem(
            key: Key(model.name),
            model: model,
            onUpdate: (m) {
              ref
                  .read(lLMApiSettingServiceProvider.notifier)
                  .updateLLMApiSetting(m);
            },
            onDelete: (m) {
              ref
                  .read(lLMApiSettingServiceProvider.notifier)
                  .deleteLLMApiSetting(m.id);
            },
          ),
        AddLLMApiSettingItem(onAdd: (m) {
          ref
              .read(lLMApiSettingServiceProvider.notifier)
              .createLLMApiSetting(m);
        }),
      ],
    );
  }
}

// 使用卡片Card的形式展示，在右上角有删除按钮，下方有测试，和更新按钮，点击后弹窗编辑，内容包括名称、baseUrl, apiKey, modelName，删除按钮。
class LLMApiSettingItem extends ConsumerWidget {
  final LLMApiSettingModel model;
  final Function(LLMApiSettingModel) onUpdate;
  final Function(LLMApiSettingModel) onDelete;

  const LLMApiSettingItem({
    super.key,
    required this.model,
    required this.onUpdate,
    required this.onDelete,
  });

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: model.name);
    final baseUrlController = TextEditingController(text: model.baseUrl);
    final apiKeyController = TextEditingController(text: model.apiKey);
    final modelNameController = TextEditingController(text: model.modelName);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: 400,
            height: 400,
            padding: const EdgeInsets.fromLTRB(
                kSpacingMedium, kSpacingLarge, kSpacingMedium, kSpacingMedium),
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${AppLocalizations.of(context)!.update} ${model.name}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: kSpacingMedium),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: kSpacingSmall),
                TextField(
                  controller: baseUrlController,
                  decoration: const InputDecoration(labelText: 'Base URL'),
                ),
                const SizedBox(height: kSpacingSmall),
                TextField(
                  controller: apiKeyController,
                  decoration: const InputDecoration(labelText: 'API Key'),
                ),
                const SizedBox(height: kSpacingSmall),
                TextField(
                  controller: modelNameController,
                  decoration: const InputDecoration(labelText: 'Model'),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                        onUpdate(LLMApiSettingModel(
                          id: model.id,
                          name: nameController.text,
                          baseUrl: baseUrlController.text,
                          apiKey: apiKeyController.text,
                          modelName: modelNameController.text,
                        ));
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.submit),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: const BoxConstraints(),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kSpacingTiny),
            Row(
              children: [
                Icon(Icons.api, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: kSpacingTiny),
                Expanded(
                  child: Text(
                    model.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    onDelete(model); // todo: 需要二次确认
                  },
                )
              ],
            ),
            const SizedBox(height: kSpacingTiny),
            _InfoRow(label: "Base URL", value: model.baseUrl),
            const SizedBox(height: kSpacingTiny),
            _InfoRow(
              label: "API Key",
              value: model.apiKey.length > 10
                  ? model.apiKey.replaceRange(4, model.apiKey.length - 4,
                      '*' * (model.apiKey.length - 8))
                  : model.apiKey,
            ),
            const SizedBox(height: kSpacingTiny),
            _InfoRow(label: "Model", value: model.modelName),
            // const SizedBox(height: kSpacingTiny),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    // TODO: 测试逻辑
                  },
                ),
                const SizedBox(width: kSpacingTiny),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditDialog(context);
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
  final Function(LLMApiSettingModel) onAdd;
  const AddLLMApiSettingItem({super.key, required this.onAdd});

  void _addLLMApiSettingDialog(BuildContext context) {
    final nameController = TextEditingController(text: "");
    final baseUrlController = TextEditingController(text: "");
    final apiKeyController = TextEditingController(text: "");
    final modelNameController = TextEditingController(text: "");

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: 400,
            height: 400,
            padding: const EdgeInsets.fromLTRB(
                kSpacingMedium, kSpacingLarge, kSpacingMedium, kSpacingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.create,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: kSpacingMedium),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: kSpacingSmall),
                TextField(
                  controller: baseUrlController,
                  decoration: const InputDecoration(labelText: 'Base URL'),
                ),
                const SizedBox(height: kSpacingSmall),
                TextField(
                  controller: apiKeyController,
                  decoration: const InputDecoration(labelText: 'API Key'),
                ),
                const SizedBox(height: kSpacingSmall),
                TextField(
                  controller: modelNameController,
                  decoration: const InputDecoration(labelText: 'Model Name'),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    const SizedBox(width: kSpacingSmall),
                    TextButton(
                      onPressed: () {
                        onAdd(LLMApiSettingModel(
                          id: const LLMApiSettingId(value: 0),
                          name: nameController.text,
                          baseUrl: baseUrlController.text,
                          apiKey: apiKeyController.text,
                          modelName: modelNameController.text,
                        ));
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.submit),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            width: 1),
      ),
      child: Center(
        child: IconButton(
            onPressed: () {
              _addLLMApiSettingDialog(context);
            },
            icon: Icon(Icons.add,
                size: kIconSizeLarge,
                color: Theme.of(context).colorScheme.surfaceDim)),
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

class SettingTabButton extends StatefulWidget {
  final String text;
  final Function() onTap;
  final bool isSelected;
  const SettingTabButton(
      {Key? key,
      required this.text,
      required this.onTap,
      required this.isSelected})
      : super(key: key);

  @override
  State<SettingTabButton> createState() => _SettingTabButtonState();
}

class _SettingTabButtonState extends State<SettingTabButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color? defaultColor = Theme.of(context).textTheme.titleMedium?.color;

    Color getTextColor() {
      if (widget.isSelected) {
        return primaryColor;
      } else if (_isHovering) {
        return primaryColor;
      } else {
        return defaultColor ?? Colors.black;
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isSelected ? primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: getTextColor(),
                ),
          ),
        ),
      ),
    );
  }
}
