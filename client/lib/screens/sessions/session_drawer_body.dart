import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_drawer_metadata.dart';
import 'package:client/screens/sessions/session_drawer_sql_result.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/icon_button.dart';
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
          RectangleIconButton(
              icon: (sessionDrawer.drawerPage == DrawerPage.metadataTree)
                  ? Icons.account_tree_rounded
                  : Icons.account_tree_outlined,
              iconColor: (sessionDrawer.drawerPage == DrawerPage.metadataTree)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                ref.read(sessionDrawerNotifierProvider.notifier).goToTree();
              }),
          RectangleIconButton(
              icon: (sessionDrawer.drawerPage == DrawerPage.sqlResult)
                  ? Icons.article_rounded
                  : Icons.article_outlined,
              iconColor: (sessionDrawer.drawerPage == DrawerPage.sqlResult)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                ref
                    .read(sessionDrawerNotifierProvider.notifier)
                    .showSQLResult();
              }),
          const Spacer(),
          RectangleIconButton(
            icon: sessionDrawer.isRightPageOpen
                ? Icons.format_indent_increase
                : Icons.format_indent_decrease,
            iconColor: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              sessionDrawer.isRightPageOpen
                  ? ref
                      .read(sessionDrawerNotifierProvider.notifier)
                      .hideRightPage()
                  : ref
                      .read(sessionDrawerNotifierProvider.notifier)
                      .showRightPage();
            },
          )
        ],
      ),
    );
  }
}
