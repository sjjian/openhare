import 'package:client/models/ai.dart';
import 'package:client/models/settings.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/services/ai/agent.dart';
import 'package:client/services/settings/settings.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
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
                  const LLMApiSettingPage(),
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
  const LLMApiSettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final models = ref.watch(lLMAgentNotifierProvider);

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
        AddLLMApiSettingItem(onAdd: (m) {
          ref.read(lLMAgentServiceProvider.notifier).create(m);
        }),
      ],
    );
  }
}

void showLLMApiSettingDialog(BuildContext context, String title,
    LLMAgentModel? model, Function(LLMAgentSettingModel) onSubmit) {
  final nameController = TextEditingController(text: model?.setting.name);
  final baseUrlController = TextEditingController(text: model?.setting.baseUrl);
  final apiKeyController = TextEditingController(text: model?.setting.apiKey);
  final modelNameController =
      TextEditingController(text: model?.setting.modelName);

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
              Text(title, style: Theme.of(context).textTheme.titleLarge),
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
                      onSubmit(LLMAgentSettingModel(
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
    final status = ref.watch(lLMAgentNotifierProvider).agents[model.id]!.status;

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
        padding: const EdgeInsets.fromLTRB(
            kSpacingMedium, kSpacingSmall, kSpacingMedium, kSpacingSmall),
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
                    model.setting.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  iconSize: kIconSizeSmall,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    onDelete(model.id); // todo: 需要二次确认
                  },
                )
              ],
            ),
            const SizedBox(height: kSpacingTiny),
            _InfoRow(label: "Base URL", value: model.setting.baseUrl),
            const SizedBox(height: kSpacingTiny),
            _InfoRow(
              label: "API Key",
              value: model.setting.apiKey.length > 10
                  ? model.setting.apiKey.replaceRange(
                      4,
                      model.setting.apiKey.length - 4,
                      '*' * (model.setting.apiKey.length - 8))
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
                  LLMAgentState.testing => const Loading(),
                  LLMAgentState.available => IconButton(
                      iconSize: kIconSizeSmall,
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.green),
                      onPressed: () {
                        ref
                            .read(lLMAgentServiceProvider.notifier)
                            .ping(model.id);
                      },
                    ),
                  LLMAgentState.unavailable => IconButton(
                      iconSize: kIconSizeSmall,
                      icon: const Icon(Icons.error_outline, color: Colors.red),
                      onPressed: () {
                        ref
                            .read(lLMAgentServiceProvider.notifier)
                            .ping(model.id);
                      },
                    ),
                  LLMAgentState.unknown => IconButton(
                      iconSize: kIconSizeSmall,
                      icon: const Icon(Icons.flash_on),
                      onPressed: () {
                        ref
                            .read(lLMAgentServiceProvider.notifier)
                            .ping(model.id);
                      },
                    ),
                },
                const SizedBox(width: kSpacingTiny),
                IconButton(
                  iconSize: kIconSizeSmall,
                  icon: const Icon(Icons.edit),
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
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            width: 1),
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
          icon: Icon(Icons.add,
              size: kIconSizeLarge,
              color: Theme.of(context).colorScheme.surfaceDim),
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
