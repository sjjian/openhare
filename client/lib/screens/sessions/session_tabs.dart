import 'package:client/models/sessions.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionTabs extends StatelessWidget {
  const SessionTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionsProvider>(builder: (context, sessionsProvider, _) {
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
              hoverColor: Theme.of(context)
                  .colorScheme
                  .surfaceDim, // session tab 鼠标移入的颜色
            ),
            addTab: () {
              sessionsProvider.newSession();
            },
            onReorder: (oldIndex, newIndex) {
              sessionsProvider.reorderSession(oldIndex, newIndex);
            },
            tabs: [
              for (var i = 0; i < sessionsProvider.sessions.data.length; i++)
                switch (sessionsProvider.sessions.data[i]) {
                  UnInitSession() => CommonTabWrap(
                      label: "new",
                      onTap: () {
                        sessionsProvider.selectSessionByIndex(i);
                      },
                      onDeleted: () {
                        sessionsProvider.deleteSessionByIndex(i);
                      },
                      selected: sessionsProvider.sessions.data
                          .isSelected(sessionsProvider.sessions.data[i]),
                    ),
                  Session() => CommonTabWrap(
                      avatar: (sessionsProvider.sessions.data[i] as Session)
                                  .model
                                  .instance
                                  .target !=
                              null
                          ? Image.asset(connectionMetaMap[
                                  (sessionsProvider.sessions.data[i] as Session)
                                      .model
                                      .instance
                                      .target!
                                      .dbType]!
                              .logoAssertPath)
                          : null,
                      label: (sessionsProvider.sessions.data[i] as Session)
                                  .conn2 !=
                              null
                          ? (sessionsProvider.sessions.data[i] as Session)
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
                            sessionsProvider.connect(
                                (sessionsProvider.sessions.data[i] as Session));
                          },
                          child: const Text("连接"),
                        ),
                        const PopupMenuDivider(height: 0.1),
                        PopupMenuItem<String>(
                          height: 30,
                          onTap: () {
                            sessionsProvider.close(
                                (sessionsProvider.sessions.data[i] as Session));
                          },
                          child: const Text("断开"),
                        ),
                        const PopupMenuDivider(height: 0.1),
                        PopupMenuItem<String>(
                          height: 30,
                          onTap: () {
                            sessionsProvider.deleteSessionByIndex(i);
                          },
                          child: const Text("关闭"),
                        ),
                      ],
                      onTap: () {
                        sessionsProvider.selectSessionByIndex(i);
                      },
                      onDeleted: () {
                        sessionsProvider.deleteSessionByIndex(i);
                      },
                      selected: sessionsProvider.sessions.data
                          .isSelected(sessionsProvider.sessions.data[i]),
                    )
                }
            ]),
      );
    });
  }
}
