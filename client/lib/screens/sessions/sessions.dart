import 'package:client/models/sql_result.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/screens/sessions/session_add.dart';
import 'package:client/screens/sessions/session_sql_editor.dart';
import 'package:client/screens/sessions/session_tabs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SQLEditPage extends StatefulWidget {
  const SQLEditPage({super.key});

  @override
  State<SQLEditPage> createState() => _SQLEditPageState();
}

class _SQLEditPageState extends State<SQLEditPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SessionTabs(),
        Expanded(
            child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            children: [
              Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
                if (sessionProvider.initialized()) {
                  return const Expanded(child: SqlEditor());
                } else {
                  return const AddSession();
                }
              }),
              Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
                if (sessionProvider.initialized() &&
                    !sessionProvider.showRecord &&
                    sessionProvider.getCurrentSQLResult() != null) {
                  SQLResultModel result =
                      sessionProvider.getCurrentSQLResult()!;
                  return SizedBox(
                    height: 30,
                    child: Row(
                      children: [
                        Text('effect rows: ${result.effectRows}'),
                        Text('duration: ${result.executeTime!.inSeconds}'),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox(height: 30);
                }
              }),
            ],
          ),
        )),
      ],
    );
  }
}
