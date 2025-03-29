import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_drawer_metadata.dart';
import 'package:client/screens/sessions/session_drawer_sql_result.dart';
import 'package:flutter/material.dart';
import 'package:client/providers/sessions.dart';
import 'package:provider/provider.dart';

class SessionDrawerBody extends StatefulWidget {
  const SessionDrawerBody({Key? key}) : super(key: key);

  @override
  State<SessionDrawerBody> createState() => _SessionDrawerBodyState();
}

class _SessionDrawerBodyState extends State<SessionDrawerBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerLow, // session drawer 背景色
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        return Column(
          children: [
            const SessionDrawerBar(),
            Expanded(
              child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: switch (sessionProvider.session!.drawerPage) {
                    DrawerPage.sqlResult => const SessionDrawerSqlResult(),
                    _ => const SessionDrawerMetadata(),
                  }),
            ),
          ],
        );
      }),
    );
  }
}

class SessionDrawerBar extends StatelessWidget {
  final double height;

  const SessionDrawerBar({Key? key, this.height = 36}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainer, // session drawer bar 背景色
      constraints: BoxConstraints(maxHeight: height),
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  sessionProvider.goToTree();
                },
                icon: (sessionProvider.session!.drawerPage ==
                        DrawerPage.metadataTree)
                    ? Icon(
                        Icons.account_tree_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .primary, // metadata 按钮色
                      )
                    : const Icon(Icons.account_tree_outlined)),
            IconButton(
                onPressed: () {
                  sessionProvider.showSQLResult();
                },
                icon: (sessionProvider.session!.drawerPage ==
                        DrawerPage.sqlResult)
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
                sessionProvider.isRightPageOpen()
                    ? sessionProvider.hideRightPage()
                    : sessionProvider.showRightPage();
              },
              icon: sessionProvider.isRightPageOpen()
                  ? const Icon(Icons.format_indent_increase)
                  : const Icon(Icons.format_indent_decrease),
            )
          ],
        );
      }),
    );
  }
}
