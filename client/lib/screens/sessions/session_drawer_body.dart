import 'package:client/core/connection/result_set.dart';
import 'package:client/screens/sessions/session_drawer_metadata.dart';
import 'package:client/screens/sessions/session_drawer_sql_result.dart';
import 'package:flutter/material.dart';
import 'package:client/providers/sessions.dart';
import 'package:provider/provider.dart';

enum DrawerPage {
  metadataTree,
  metadataTable,
  sqlResult,
}

class SessionDrawerController extends ChangeNotifier {
  DrawerPage page = DrawerPage.metadataTree;
  String? currentSchema;
  String? currentTable;
  ResultSetValue? sqlResult;

  SessionDrawerController();

  void goToTree() {
    page = DrawerPage.metadataTree;
    notifyListeners();
  }

  void openTable(String schema, String table) {
    page = DrawerPage.metadataTable;
    currentSchema = schema;
    currentTable = table;
    notifyListeners();
  }

  void showSQLResult({ResultSetValue? result}) {
    page = DrawerPage.sqlResult;
    sqlResult = result ?? sqlResult;
    notifyListeners();
  }
}

class SessionDrawerBody extends StatefulWidget {
  final SessionDrawerController controller;

  const SessionDrawerBody({Key? key, required this.controller})
      : super(key: key);

  @override
  State<SessionDrawerBody> createState() => _SessionDrawerBodyState();
}

class _SessionDrawerBodyState extends State<SessionDrawerBody> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow, // session drawer 背景色
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        return Column(
          children: [
            SessionDrawerBar(controller: widget.controller),
            Expanded(
              child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: switch (widget.controller.page) {
                    DrawerPage.metadataTable => SessionDrawerMetadataDetail(
                        controller: widget.controller),
                    DrawerPage.sqlResult =>
                      SessionDrawerSqlResult(controller: widget.controller),
                    _ => SessionDrawerMetadata(controller: widget.controller),
                  }),
            ),
          ],
        );
      }),
    );
  }
}

class SessionDrawerBar extends StatelessWidget {
  final SessionDrawerController controller;
  final double height;

  const SessionDrawerBar({Key? key, required this.controller, this.height = 36})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer, // session drawer bar 背景色
      constraints: BoxConstraints(maxHeight: height),
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  controller.goToTree();
                },
                icon: (controller.page == DrawerPage.metadataTree ||
                        controller.page == DrawerPage.metadataTable)
                    ? Icon(
                        Icons.account_tree_rounded,
                        color: Theme.of(context).colorScheme.primary, // metadata 按钮色
                      )
                    : const Icon(Icons.account_tree_outlined)),
            IconButton(
                onPressed: () {
                  controller.showSQLResult();
                },
                icon: (controller.page == DrawerPage.sqlResult)
                    ? Icon(
                        Icons.article_rounded,
                        color: Theme.of(context).colorScheme.primary,  // sql result 按钮色
                      )
                    : const Icon(Icons.article_outlined)),
            const Spacer(),
            IconButton(
              onPressed: () {
                sessionProvider.isRightPageOpen
                    ? sessionProvider.hideRightPage()
                    : sessionProvider.showRightPage();
              },
              icon: sessionProvider.isRightPageOpen
                  ? const Icon(Icons.format_indent_increase)
                  : const Icon(Icons.format_indent_decrease),
            )
          ],
        );
      }),
    );
  }
}
