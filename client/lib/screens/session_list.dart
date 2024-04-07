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
    return Expanded(
      child: Consumer<SessionListProvider>(
          builder: (context, sessionListProvider, _) {
        return ListView(
          padding: const EdgeInsets.only(right: 10, left: 5),
          children: [
            for (var i = 0; i < sessionListProvider.sessions.data.length; i++)
              SessionTile(
                index: i,
                selected: sessionListProvider.sessions.data
                    .isSelected(sessionListProvider.sessions.data[i]),
                session: sessionListProvider.sessions.data[i],
              )
          ],
        );
      }),
    );
  }
}

class SessionTile extends StatefulWidget {
  final int index;
  final bool selected;
  final SessionModel session; // todo

  const SessionTile(
      {Key? key,
      required this.index,
      required this.selected,
      required this.session})
      : super(key: key);

  @override
  State<SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<SessionTile> {
  Color getTrailingColor() {
    switch (widget.session.conn.state) {
      case SQLConnectState.connected:
        return Colors.green;
      case SQLConnectState.connecting:
        return Colors.yellow;
      case SQLConnectState.failed:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.2), //边框颜色
            width: 1, //边框宽度
          ), // 边色与边宽度
          color: widget.selected
              ? Colors.grey.withOpacity(0.2)
              : Colors.white, // 底色
          boxShadow: [
            BoxShadow(
              blurRadius: 1, //阴影范围
              spreadRadius: 0.1, //阴影浓度
              color: Colors.grey.withOpacity(0.2), //阴影颜色
            ),
          ],
          // borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          hoverColor: Colors.grey.withOpacity(0.1),
          onTap: widget.selected
              ? null
              : () {
                  context
                      .read<SessionListProvider>()
                      .selectSessionByIndex(widget.index);
                },
          child: ListTile(
            dense: true,
            titleAlignment: ListTileTitleAlignment.center,
            title: const Text("test1", overflow: TextOverflow.ellipsis),
            subtitle: Text(
                "${widget.session.conn.meta.host}:${widget.session.conn.meta.port}",
                overflow: TextOverflow.ellipsis),
            leading: Image.asset("assets/icons/mysql_icon.png"),
            trailing: PopupMenuButton(
              offset: const Offset(35, 0),
              surfaceTintColor: Colors.white,
              onSelected: (value) {
                if (value == "a") {
                  context
                      .read<SessionListProvider>()
                      .connect(widget.session.id);
                } else if (value == "b") {
                  context.read<SessionListProvider>().close(widget.session.id);
                }
              },
              itemBuilder: (context) => <PopupMenuEntry>[
                const PopupMenuItem<String>(
                  height: 30,
                  value: "a",
                  child: Text("连接"),
                ),
                const PopupMenuDivider(height: 0.1),
                const PopupMenuItem<String>(
                  height: 30,
                  value: "b",
                  child: Text("断开"),
                ),
                const PopupMenuDivider(height: 0.1),
                const PopupMenuItem<String>(
                  height: 30,
                  value: "c",
                  child: Text("关闭"),
                ),
              ],
              child: Icon(
                Icons.more_vert_outlined,
                color: getTrailingColor(),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 6.0),
          ),
        ));
  }
}
