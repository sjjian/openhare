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
      children: [
        const SessionTabs(),
        Expanded(
            child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            children: [
              Expanded(child: Consumer<SessionProvider>(
                  builder: (context, sessionProvider, _) {
                final selectedConn = sessionProvider.selectedConn();
                if (selectedConn) {
                  return SqlEditor();
                } else {
                  return AddSession();
                }
              })),
              SizedBox(height: 30)
            ],
          ),
        )),
      ],
    );
  }
}
