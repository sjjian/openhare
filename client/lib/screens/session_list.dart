import 'package:client/models/connection.dart';
import 'package:client/models/sessions.dart';
import 'package:client/providers/sessions.dart';
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
      return Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: SizedBox(
          height: 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < sessionListProvider.sessions.data.length; i++)
                SessionTab(
                  key: GlobalKey(),
                  index: i,
                  selected: sessionListProvider.sessions.data
                      .isSelected(sessionListProvider.sessions.data[i]),
                  session: sessionListProvider.sessions.data[i],
                ),
              const Expanded(
                child: Spacer(),
              )
            ],
          ),
        ),
      );
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
                  context.read<SessionListProvider>().connect(widget.session.id);;
                },
                child: Text("连接"),
              ),
              const PopupMenuDivider(height: 0.1),
              PopupMenuItem<String>(
                height: 30,
                value: "b",
                onTap:() {
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
            color: widget.selected? Theme.of(context).colorScheme.surfaceContainer: Theme.of(context).colorScheme.surfaceContainerHigh,
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
