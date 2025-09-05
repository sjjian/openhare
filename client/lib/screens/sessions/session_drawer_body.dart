import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_drawer_chat.dart';
import 'package:client/screens/sessions/session_drawer_metadata.dart';
import 'package:client/screens/sessions/session_drawer_sql_result.dart';
import 'package:client/services/sessions/session_drawer.dart';
import 'package:client/widgets/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionDrawerBody extends ConsumerWidget {
  const SessionDrawerBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionDrawer = ref.watch(sessionDrawerNotifierProvider);
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerLowest, // session drawer 背景色
      child: Column(
        children: [
          Expanded(
            child: Container(
                padding: const EdgeInsets.fromLTRB(kSpacingSmall - 5, 0,
                    kSpacingSmall, 0), // 左边减去5, 减掉split view 多出来的空间
                child: switch (sessionDrawer.drawerPage) {
                  DrawerPage.sqlResult => const SessionDrawerSqlResult(),
                  DrawerPage.aiChat => const SessionDrawerChat(),
                  _ => const SessionDrawerMetadata(),
                }),
          ),
        ],
      ),
    );
  }
}
