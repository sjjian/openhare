import 'package:client/models/interface.dart';
import 'package:client/services/sessions.dart';
import 'package:client/services/session_conn.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionTabs extends ConsumerWidget {
  const SessionTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionTab sessionTab = ref.watch(sessionsServicesProvider);
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
            for (var i = 0; i < sessionTab.sessions.length; i++)
              (sessionTab.sessions[i].instance.target == null)
                  ? CommonTabWrap(
                      label: "new",
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
                      selected: sessionTab.sessions
                          .isSelected(sessionTab.sessions[i]),
                    )
                  : CommonTabWrap(
                      avatar: Image.asset(connectionMetaMap[
                              sessionTab.sessions[i].instance.target!.dbType]!
                          .logoAssertPath),
                      label: sessionTab
                          .sessions[i].instance.target!.connectValue.name,
                      items: <PopupMenuEntry>[
                        PopupMenuItem<String>(
                          height: 30,
                          onTap: () {
                            ref
                                .read(sessionConnServicesProvider(sessionTab.sessions[i].id).notifier)
                                .connect();
                          },
                          child: const Text("连接"),
                        ),
                        const PopupMenuDivider(height: 0.1),
                        PopupMenuItem<String>(
                          height: 30,
                          onTap: () {
                            ref
                                .read(sessionConnServicesProvider(sessionTab.sessions[i].id).notifier)
                                .close();
                          },
                          child: const Text("断开"),
                        ),
                        const PopupMenuDivider(height: 0.1),
                        PopupMenuItem<String>(
                          height: 30,
                          onTap: () {
                            ref
                                .read(sessionsServicesProvider.notifier)
                                .deleteSessionByIndex(i);
                          },
                          child: const Text("关闭"),
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
                      selected: sessionTab.sessions
                          .isSelected(sessionTab.sessions[i]),
                    )
          ]),
    );
  }
}
