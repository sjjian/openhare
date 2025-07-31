import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SessionTabs extends ConsumerWidget {
  const SessionTabs({Key? key}) : super(key: key);

  bool connIsBusy(SessionDetailModel model) {
    return (model.connId != null &&
        model.connState != null &&
        (model.connState == SQLConnectState.executing ||
            model.connState == SQLConnectState.connecting));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionDetailListModel model = ref.watch(sessionsNotifierProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: CommonTabBar(
          tabStyle: CommonTabStyle(
            minWidth: 90,
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
                      selected: model.sessions[i].sessionId ==
                          model.selectedSession?.sessionId,
                    )
                  : CommonTabWrap(
                      avatar: (model.sessions[i].sessionId !=
                                  model.selectedSession?.sessionId &&
                              connIsBusy(model.sessions[i]))
                          ? const Padding(
                              padding: EdgeInsets.all(2),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Image.asset(
                              connectionMetaMap[model.sessions[i].dbType!]!
                                  .logoAssertPath),
                      label: model.sessions[i].instanceName!,
                      items: <PopupMenuEntry>[
                        PopupMenuItem<String>(
                          height: 30,
                          onTap: () async {
                            await ref
                                .read(sessionsServicesProvider.notifier)
                                .connectSession(model.sessions[i].sessionId);
                          },
                          child: Text(AppLocalizations.of(context)!.connect),
                        ),
                        const PopupMenuDivider(height: 0.1),
                        PopupMenuItem<String>(
                          height: 30,
                          onTap: () async {
                            await ref
                                .read(sessionsServicesProvider.notifier)
                                .disconnectSession(model.sessions[i].sessionId);
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
                      selected: model.sessions[i].sessionId ==
                          model.selectedSession?.sessionId,
                    )
          ]),
    );
  }
}
