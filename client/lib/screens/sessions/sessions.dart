import 'package:client/providers/sessions.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/screens/sessions/session_add.dart';
import 'package:client/screens/sessions/session_body.dart';
import 'package:client/screens/sessions/session_status.dart';
import 'package:client/screens/sessions/session_tabs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageSkeleton(
        key: const Key("sessions"),
        topBar: const SessionTabs(),
        bottomBar: const SessionStatus(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child:
              Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
            if (sessionProvider.initialized()) {
              return const SessionBodyPage();
            } else {
              return const AddSession();
            }
          }),
        ));
  }
}
