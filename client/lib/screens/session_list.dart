import 'package:client/providers/sessions.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionList extends StatefulWidget {
  const SessionList({Key? key}) : super(key: key);

  @override
  State<SessionList> createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
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
          tabs: [
            for (var i = 0; i < sessionListProvider.sessions.data.length; i++)
              CommonTabWrap(
                avatar: Image.asset("assets/icons/mysql_icon.png"),
                label: sessionListProvider.sessions.data[i].conn.meta.host,
                items: <PopupMenuEntry>[
                  PopupMenuItem<String>(
                    height: 30,
                    onTap: () {
                      sessionListProvider
                          .connect(sessionListProvider.sessions.data[i].id);
                    },
                    child: const Text("连接"),
                  ),
                  const PopupMenuDivider(height: 0.1),
                  PopupMenuItem<String>(
                    height: 30,
                    onTap: () {
                      sessionListProvider
                          .close(sessionListProvider.sessions.data[i].id);
                    },
                    child: const Text("断开"),
                  ),
                  const PopupMenuDivider(height: 0.1),
                  const PopupMenuItem<String>(
                    height: 30,
                    child: Text("关闭"),
                  ),
                ],
                onTap: () {
                  sessionListProvider.selectSessionByIndex(i);
                },
                onDeleted: () {},
                selected: sessionListProvider.sessions.data
                    .isSelected(sessionListProvider.sessions.data[i]),
              )
          ]);
    });
  }
}
