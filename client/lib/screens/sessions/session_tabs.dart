import 'package:client/models/sessions.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionTabs extends StatefulWidget {
  const SessionTabs({Key? key}) : super(key: key);

  @override
  State<SessionTabs> createState() => _SessionTabsState();
}

class _SessionTabsState extends State<SessionTabs> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SessionListProvider>(
        builder: (context, sessionListProvider, _) {
      return CommonTabBar(
          tabStyle: CommonTabStyle(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            selectedColor: Theme.of(context).colorScheme.surfaceContainerLow,
            hoverColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
          addTab: () {
            sessionListProvider.addSession(SessionModel());
          },
          onReorder: (oldIndex, newIndex) {
            sessionListProvider.reorderSession(oldIndex, newIndex);
          },
          tabs: [
            for (var i = 0; i < sessionListProvider.sessions.data.length; i++)
              CommonTabWrap(
                avatar: Image.asset("assets/icons/mysql_icon.png"),
                label: sessionListProvider.sessions.data[i].conn != null
                    ? sessionListProvider.sessions.data[i].conn!.instance.addr
                    : "new",
                items: <PopupMenuEntry>[
                  PopupMenuItem<String>(
                    height: 30,
                    onTap: () {
                      sessionListProvider
                          .connect(sessionListProvider.sessions.data[i]);
                    },
                    child: const Text("连接"),
                  ),
                  const PopupMenuDivider(height: 0.1),
                  PopupMenuItem<String>(
                    height: 30,
                    onTap: () {
                      sessionListProvider
                          .close(sessionListProvider.sessions.data[i]);
                    },
                    child: const Text("断开"),
                  ),
                  const PopupMenuDivider(height: 0.1),
                  PopupMenuItem<String>(
                    height: 30,
                    onTap: () {
                      sessionListProvider
                          .deleteSessionByIndex(i);
                    },
                    child: const Text("关闭"),
                  ),
                ],
                onTap: () {
                  sessionListProvider.selectSessionByIndex(i);
                },
                onDeleted: () {
                  sessionListProvider
                      .deleteSessionByIndex(i);
                },
                selected: sessionListProvider.sessions.data
                    .isSelected(sessionListProvider.sessions.data[i]),
              )
          ]);
    });
  }
}
