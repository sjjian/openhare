import 'package:client/models/connection.dart';
import 'package:client/models/sessions.dart';
import 'package:client/providers/sessions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionTileList extends StatefulWidget {
  const SessionTileList({Key? key}) : super(key: key);

  @override
  State<SessionTileList> createState() => _SessionTileListState();
}

class _SessionTileListState extends State<SessionTileList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<SessionTileProvider>(
          builder: (context, sessionTileProvider, _) {
        return ListView(
            padding: const EdgeInsets.only(right: 10, left: 5),
            children: sessionTileProvider.sessions.data.map((session) {
              return SessionTile(
                session: session,
              );
            }).toList());
      }),
    );
  }
}

class SessionTile extends StatefulWidget {
  final SessionModel session; // todo

  const SessionTile({Key? key, required this.session}) : super(key: key);

  @override
  State<SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<SessionTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.2), //边框颜色
            width: 1, //边框宽度
          ), // 边色与边宽度
          color: Colors.white, // 底色
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
          hoverColor: Colors.blue,
          onTap: () {
            print(1);
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
                      .read<SessionTileProvider>()
                      .connect(widget.session.id);
                } else if (value == "b") {
                  context.read<SessionTileProvider>().close(widget.session.id);
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
                color: widget.session.conn.state == SQLConnectState.connected
                    ? Colors.green
                    : Colors.black,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 6.0),
          ),
        ));
  }
}
