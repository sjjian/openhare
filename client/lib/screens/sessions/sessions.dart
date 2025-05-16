import 'package:client/screens/page_skeleton.dart';
import 'package:client/screens/sessions/session_add.dart';
import 'package:client/screens/sessions/session_body.dart';
import 'package:client/screens/sessions/session_status.dart';
import 'package:client/screens/sessions/session_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/providers/model.dart';
import 'package:client/models/sessions.dart';

class SessionsPage extends ConsumerWidget {
  const SessionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // BaseSession session = ref.watch(currentSessionProvider)!;
    SessionsCache sessions = ref.watch(sessionsProvider);

    return PageSkeleton(
        key: const Key("sessions"),
        topBar: const SessionTabs(),
        bottomBar: const SessionStatusTab(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: switch (sessions.data.selected()!) {
            UnInitSession() => const AddSession(),
            Session() => const SessionBodyPage(),
          },
        ));
  }
}
