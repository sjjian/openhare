import 'package:client/models/sessions.dart';
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
                onDeleted: () {
                  
                },
                selected: sessionListProvider.sessions.data
                    .isSelected(sessionListProvider.sessions.data[i]),
              )
          ]);
    });
  }
}

class SessionTab extends StatefulWidget {
  final int index;
  final bool selected;
  final SessionModel session;
  const SessionTab(
      {Key? key,
      required this.index,
      required this.selected,
      required this.session})
      : super(key: key);

  @override
  State<SessionTab> createState() => _SessionTabState();
}

class _SessionTabState extends State<SessionTab> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SessionListProvider>().selectSessionByIndex(widget.index);
      },
      onSecondaryTapUp: (detail) {
        final position = detail.globalPosition;
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final overlayPos = overlay.localToGlobal(Offset.zero);

        showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              position.dx - overlayPos.dx,
              position.dy - overlayPos.dy,
              position.dx - overlayPos.dx,
              position.dy - overlayPos.dy,
            ),
            items: <PopupMenuEntry>[
              PopupMenuItem<String>(
                height: 30,
                value: "a",
                onTap: () {
                  context
                      .read<SessionListProvider>()
                      .connect(widget.session.id);
                  ;
                },
                child: const Text("连接"),
              ),
              const PopupMenuDivider(height: 0.1),
              PopupMenuItem<String>(
                height: 30,
                value: "b",
                onTap: () {
                  context.read<SessionListProvider>().close(widget.session.id);
                },
                child: const Text("断开"),
              ),
              const PopupMenuDivider(height: 0.1),
              const PopupMenuItem<String>(
                height: 30,
                value: "c",
                child: Text("关闭"),
              ),
            ]);
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        width: 150,
        height: 35,
        decoration: BoxDecoration(
            color: widget.selected
                ? Theme.of(context).colorScheme.surfaceContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(5))),
        child: Row(
          children: [
            Image.asset(width: 20, height: 20, "assets/icons/mysql_icon.png"),
            Container(
              constraints: const BoxConstraints(maxWidth: 50),
              child: Text(
                widget.session.conn.meta.host,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Expanded(child: Spacer()),
            Container(
                constraints: const BoxConstraints(maxHeight: 30, maxWidth: 30),
                child: IconButton(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minHeight: 100),
                  onPressed: () {
                    print(1);
                  },
                  icon: const Icon(size: 10, Icons.close),
                ))
          ],
        ),
      ),
    );
  }
}
