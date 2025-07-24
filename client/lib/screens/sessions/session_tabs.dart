import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'session_tabs.g.dart';

@Riverpod(keepAlive: true)
class SessionsTabNotifier extends _$SessionsTabNotifier {
  @override
  SessionListModel build() {
    return ref.watch(sessionsServicesProvider);
  }
}

class SessionTabs extends ConsumerWidget {
  const SessionTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionListModel model = ref.watch(sessionsTabNotifierProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: CommonTabBar(
          tabStyle: CommonTabStyle(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest, // session tab 背景色
            selectedColor: Theme.of(context)
                .colorScheme
                .surfaceContainer, // session tab 选择的颜色
            hoverColor:
                Theme.of(context).colorScheme.surfaceDim, // session tab 鼠标移入的颜色
          ),
          addTab: () {
            ref.read(sessionsServicesProvider.notifier).newSession();
          },
          onReorder: (oldIndex, newIndex) {
            ref
                .read(sessionsServicesProvider.notifier)
                .reorderSession(oldIndex, newIndex);
          },
          tabs: [
            for (var i = 0; i < model.sessions.length; i++)
              (model.sessions[i].instanceId == null)
                  ? CommonTabWrap(
                      label: AppLocalizations.of(context)!.new_tab,
                      onTap: () {
                        ref
                            .read(sessionsServicesProvider.notifier)
                            .selectSessionByIndex(i);
                      },
                      onDeleted: () {
                        ref
                            .read(sessionsServicesProvider.notifier)
                            .deleteSessionByIndex(i);
                      },
                      selected: model.sessions[i] == model.selectedSession,
                    )
                  : CommonTabWrap(
                      avatar: Image.asset(
                          connectionMetaMap[model.sessions[i].dbType!]!
                              .logoAssertPath),
                      label: model.sessions[i].instanceName!,
                      items: <PopupMenuEntry>[
                        PopupMenuItem<String>(
                          height: 30,
                          onTap: () async {
                            final connModel = await ref
                                .read(sessionConnsServicesProvider.notifier)
                                .createConn(
                                  model.sessions[i].instanceId!,
                                  currentSchema: model.sessions[i].currentSchema,
                                );
                            await ref
                                .read(sessionConnServicesProvider(
                                        connModel.connId)
                                    .notifier)
                                .connect();

                            ref
                                .read(sessionsServicesProvider.notifier)
                                .setConnId(model.sessions[i].sessionId,
                                    connModel.connId);
                          },
                          child: Text(AppLocalizations.of(context)!.connect),
                        ),
                        const PopupMenuDivider(height: 0.1),
                        PopupMenuItem<String>(
                          height: 30,
                          onTap: () {
                            ref
                                .read(sessionConnServicesProvider(
                                        model.sessions[i].connId!)
                                    .notifier)
                                .close();
                          },
                          child: Text(AppLocalizations.of(context)!.disconnect),
                        ),
                        const PopupMenuDivider(height: 0.1),
                        PopupMenuItem<String>(
                          height: 30,
                          onTap: () {
                            ref
                                .read(sessionsServicesProvider.notifier)
                                .deleteSessionByIndex(i);
                          },
                          child: Text(AppLocalizations.of(context)!.close),
                        ),
                      ],
                      onTap: () {
                        ref
                            .read(sessionsServicesProvider.notifier)
                            .selectSessionByIndex(i);
                      },
                      onDeleted: () {
                        ref
                            .read(sessionsServicesProvider.notifier)
                            .deleteSessionByIndex(i);
                      },
                      selected: model.sessions[i] == model.selectedSession,
                    )
          ]),
    );
  }
}
