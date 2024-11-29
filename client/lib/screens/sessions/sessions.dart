import 'package:client/providers/sessions.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/screens/sessions/session_add.dart';
import 'package:client/screens/sessions/session_drawer.dart';
import 'package:client/screens/sessions/session_sql_editor.dart';
import 'package:client/screens/sessions/session_status.dart';
import 'package:client/screens/sessions/session_tabs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SQLEditPage extends StatefulWidget {
  const SQLEditPage({super.key});

  @override
  State<SQLEditPage> createState() => _SQLEditPageState();
}

class _SQLEditPageState extends State<SQLEditPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            children: [
              Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
                if (sessionProvider.initialized()) {
                  return const SessionBodyPage(isOpened: true);
                } else {
                  return const AddSession();
                }
              }),
            ],
          ),
        )),
      ],
    );
  }
}

class SessionsPage extends StatelessWidget {
  const SessionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PageSkeleton(
        key: Key("sessions"),
        topBar: SessionTabs(),
        bottomBar: SessionStatus(),
        drawer: SessionDrawer(),
        child: SQLEditPage());
  }
}

class SessionBodyPage extends StatefulWidget {
  final bool isOpened;

  const SessionBodyPage({Key? key, required this.isOpened}) : super(key: key);

  @override
  State<SessionBodyPage> createState() => _SessionBodyPageState();
}

class _SessionBodyPageState extends State<SessionBodyPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (widget.isOpened){
    // _scaffoldKey.currentState!.openEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scaffold(
          key: _scaffoldKey,
          onEndDrawerChanged: (isOpened) {
            print(isOpened);
          },
          // key: sessionProvider.session!.scaffoldKey,
          endDrawer: const SessionDrawer(),
          body: const SqlEditor()),
    );
  }
}
