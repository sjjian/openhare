import 'package:client/models/sessions.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/screens/sessions/session_add.dart';
import 'package:client/screens/sessions/session_body.dart';
import 'package:client/screens/sessions/session_status.dart';
import 'package:client/screens/sessions/session_tabs.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionsPage extends ConsumerWidget {
  const SessionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionDetailModel? session = ref.watch(selectedSessionNotifierProvider);
    return PageSkeleton(
      key: const Key("sessions"),
      topBar: const SessionTabs(),
      bottomBar: const SessionStatusTab(),
      child: (session == null || session.instanceId == null)
          ? const AddSession()
          : const SessionBodyPage(),
    );
  }
}
