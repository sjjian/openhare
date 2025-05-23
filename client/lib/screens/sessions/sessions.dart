import 'package:client/providers/sessions.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/screens/sessions/session_add.dart';
import 'package:client/screens/sessions/session_body.dart';
import 'package:client/screens/sessions/session_status.dart';
import 'package:client/screens/sessions/session_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/models/interface.dart';

class SessionsPage extends ConsumerWidget {
  const SessionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(sessionTabControllerProvider);
    print("session page rebuild");
    SelectedSessionId? sessionIdModel =
        ref.watch(selectedSessionIdControllerProvider);

    print("session id: ${sessionIdModel?.sessionId}");
    return PageSkeleton(
        key: const Key("sessions"),
        topBar: const SessionTabs(),
        bottomBar: const SessionStatusTab(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: (sessionIdModel == null ||
                  sessionIdModel.sessionId == 0 ||
                  sessionIdModel.instanceId == null)
              ? const AddSession()
              : const SessionBodyPage(),
        ));
  }
}
