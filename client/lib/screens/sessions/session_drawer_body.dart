import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_drawer_chat.dart';
import 'package:client/screens/sessions/session_drawer_sql_result.dart';
import 'package:client/services/sessions/session_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionDrawerBody extends ConsumerWidget {
  const SessionDrawerBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionDrawer = ref.watch(sessionDrawerProvider);
    return Column(
      children: [
        Expanded(
          child: switch (sessionDrawer.drawerPage) {
            DrawerPage.aiChat => const SessionDrawerChat(),
            _ => const SessionDrawerSqlResult(),
          },
        ),
      ],
    );
  }
}
