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
        bottomBar: const SessionStatusTab(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Consumer2<SessionProvider, NewSessionProvider>(
              builder: (context, sessionProvider, newSessionProvider, _) {
            SessionsProvider sessionsProvider =
                Provider.of<SessionsProvider>(context);
            return switch (sessionsProvider.sessions.data.selected()!) {
              UnInitSession() => const AddSession(),
              Session() => const SessionBodyPage(),
            };
          }),
        ));
  }
}
