import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_drawer_metadata.dart';
import 'package:client/screens/sessions/session_drawer_sql_result.dart';
import 'package:client/services/sessions/sessions.dart';
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
          .surfaceContainerLow, // session drawer 背景色
      child: Column(
        children: [
          const SessionDrawerBar(),
          Expanded(
            child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: switch (sessionDrawer.drawerPage) {
                  DrawerPage.sqlResult => const SessionDrawerSqlResult(),
                  _ => const SessionDrawerMetadata(),
                }),
          ),
        ],
      ),
    );
  }
}

class SessionDrawerBar extends ConsumerWidget {
  final double height;

  const SessionDrawerBar({Key? key, this.height = 36}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionDrawer = ref.watch(sessionDrawerNotifierProvider);
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainer, // session drawer bar 背景色
      constraints: BoxConstraints(maxHeight: height),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                ref.read(sessionDrawerNotifierProvider.notifier).goToTree();
              },
              icon: (sessionDrawer.drawerPage == DrawerPage.metadataTree)
                  ? Icon(
                      Icons.account_tree_rounded,
                      color:
                          Theme.of(context).colorScheme.primary, // metadata 按钮色
                    )
                  : const Icon(Icons.account_tree_outlined)),
          IconButton(
              onPressed: () {
                ref.read(sessionDrawerNotifierProvider.notifier).showSQLResult();
              },
              icon: (sessionDrawer.drawerPage == DrawerPage.sqlResult)
                  ? Icon(
                      Icons.article_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .primary, // sql result 按钮色
                    )
                  : const Icon(Icons.article_outlined)),
          const Spacer(),
          IconButton(
            onPressed: () {
              sessionDrawer.isRightPageOpen
                  ? ref.read(sessionDrawerNotifierProvider.notifier).hideRightPage()
                  : ref.read(sessionDrawerNotifierProvider.notifier).showRightPage();
            },
            icon: sessionDrawer.isRightPageOpen
                ? const Icon(Icons.format_indent_increase)
                : const Icon(Icons.format_indent_decrease),
          )
        ],
      ),
    );
  }
}
