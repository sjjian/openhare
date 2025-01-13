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
  String? sqlResult;

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

  void showSQLResult(String result) {
    page = DrawerPage.sqlResult;
    sqlResult = result;
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
    widget.controller.addListener(() => mounted ? setState(() {
    }) : null);
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        return Expanded(
          child: Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: switch (widget.controller.page) {
                DrawerPage.metadataTable => SessionDrawerMetadataDetail(controller: widget.controller),
                DrawerPage.sqlResult => SessionDrawerSqlResult(controller: widget.controller),
                _ => SessionDrawerMetadata(controller: widget.controller),
              }),
        );
      }),
    );
  }
}
