import 'package:client/providers/model.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:client/providers/model.dart';
import 'package:client/models/sessions.dart';

class SessionTabs extends ConsumerWidget {
  const SessionTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionsCache sessions = ref.watch(sessionsProvider);
    // SessionsCache sessions = ref.watch(sessionTabProviderProvider);
    print("SessionTabs page rebuild, session count: ${sessions.data.length}, hash: ${sessions.hashCode}");
    // print("SessionTabs page rebuild, session count: ${sessions.data.length}");
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
            ref.read(sessionTabProviderProvider.notifier).newSession();
          },
          onReorder: (oldIndex, newIndex) {
            ref.read(sessionTabProviderProvider.notifier).reorderSession(oldIndex, newIndex);
          },
          tabs: [
            for (var i = 0; i < sessions.data.length; i++)
              switch (sessions.data[i]) {
                UnInitSession() => CommonTabWrap(
                    label: "new",
                    onTap: () {
                      ref.read(sessionTabProviderProvider.notifier).selectSessionByIndex(i);
                    },
                    onDeleted: () {
                      ref.read(sessionTabProviderProvider.notifier).deleteSessionByIndex(i);
                    },
                    selected: sessions.data.isSelected(sessions.data[i]),
                  ),
                Session() => CommonTabWrap(
                    avatar:
                        (sessions.data[i] as Session).model.instance.target !=
                                null
                            ? Image.asset(connectionMetaMap[
                                    (sessions.data[i] as Session)
                                        .model
                                        .instance
                                        .target!
                                        .dbType]!
                                .logoAssertPath)
                            : null,
                    label: (sessions.data[i] as Session).conn2 != null
                        ? (sessions.data[i] as Session)
                            .model
                            .instance
                            .target!
                            .connectValue
                            .name
                        : "new",
                    items: <PopupMenuEntry>[
                      PopupMenuItem<String>(
                        height: 30,
                        onTap: () {
                          ref.read(sessionTabProviderProvider.notifier).connect(
                              (sessions.data[i] as Session));
                        },
                        child: const Text("连接"),
                      ),
                      const PopupMenuDivider(height: 0.1),
                      PopupMenuItem<String>(
                        height: 30,
                        onTap: () {
                          ref.read(sessionTabProviderProvider.notifier).close(
                              (sessions.data[i] as Session));
                        },
                        child: const Text("断开"),
                      ),
                      const PopupMenuDivider(height: 0.1),
                      PopupMenuItem<String>(
                        height: 30,
                        onTap: () {
                          ref.read(sessionTabProviderProvider.notifier).deleteSessionByIndex(i);
                        },
                        child: const Text("关闭"),
                      ),
                    ],
                    onTap: () {
                      ref.read(sessionTabProviderProvider.notifier).selectSessionByIndex(i);
                    },
                    onDeleted: () {
                      ref.read(sessionTabProviderProvider.notifier).deleteSessionByIndex(i);
                    },
                    selected: sessions.data.isSelected(sessions.data[i]),
                  )
              }
          ]),
    );
  }
}
