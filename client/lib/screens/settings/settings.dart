import 'package:client/models/settings.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/services/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

@Riverpod(keepAlive: true)
class SettingNotifier extends _$SettingNotifier {
  @override
  SettingModel build() {
    return ref.watch(settingServiceProvider);
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(settingNotifierProvider);
    return PageSkeleton(
      key: const Key("settings"),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    decoration: BoxDecoration(
                        border:
                            Border(bottom: Divider.createBorderSide(context))),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.sys_settings,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer()
                      ],
                    ),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 140,
                              child: Row(
                                children: [
                                  const Icon(Icons.language),
                                  const SizedBox(width: 8),
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
                                      .read(settingServiceProvider.notifier)
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
                                      .read(settingServiceProvider.notifier)
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
                      ),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 140,
                              child: Row(
                                children: [
                                  const Icon(Icons.language),
                                  const SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.language)
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: RadioListTile<String>(
                                title: Text(
                                    AppLocalizations.of(context)!.theme_light),
                                value: "light",
                                groupValue: model.theme,
                                onChanged: (value) {
                                  ref
                                      .read(settingServiceProvider.notifier)
                                      .setTheme(value!);
                                },
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                contentPadding:
                                    EdgeInsets.zero, // Remove default padding
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: RadioListTile<String>(
                                title: Text(
                                    AppLocalizations.of(context)!.theme_dark),
                                value: "dark",
                                groupValue: model.theme,
                                onChanged: (value) {
                                  ref
                                      .read(settingServiceProvider.notifier)
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
                      ),
                      const Spacer(),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
