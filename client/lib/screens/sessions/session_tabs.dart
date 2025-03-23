import 'package:client/models/sessions.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionTabs extends StatelessWidget {
  const SessionTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionListProvider>(
        builder: (context, sessionListProvider, _) {
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
              sessionListProvider.addSession(SessionModel());
            },
            onReorder: (oldIndex, newIndex) {
              sessionListProvider.reorderSession(oldIndex, newIndex);
            },
            tabs: [
              for (var i = 0; i < sessionListProvider.sessions.data.length; i++)
                CommonTabWrap(
                  avatar: Image.asset("assets/icons/mysql_icon.png"),
                  label: sessionListProvider.sessions.data[i].conn2 != null
                      ? sessionListProvider.sessions.data[i].instance!.name
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
                        sessionListProvider.deleteSessionByIndex(i);
                      },
                      child: const Text("关闭"),
                    ),
                  ],
                  onTap: () {
                    sessionListProvider.selectSessionByIndex(i);
                  },
                  onDeleted: () {
                    sessionListProvider.deleteSessionByIndex(i);
                  },
                  selected: sessionListProvider.sessions.data
                      .isSelected(sessionListProvider.sessions.data[i]),
                )
            ]),
      );
    });
  }
}
