import 'package:client/providers/sessions.dart';
import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:client/screens/sessions/session_operation_bar.dart';
import 'package:client/screens/sessions/session_sql_editor.dart';
import 'package:client/screens/sessions/session_sql_results.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/widgets/split_view.dart';

class SessionBodyPage extends StatelessWidget {
  const SessionBodyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        final Widget left = Column(
          children: [
            SessionOpBar(codeController: sessionProvider.session!.getSQLEditCode()),
            Expanded(
              child: SplitView(
                controller: sessionProvider.session!.multiSplitViewCtrl,
                axis: Axis.vertical,
                first: SQLEditor(
                    key: ValueKey(sessionProvider.session!.getSQLEditCode()),
                    codeController: sessionProvider.session!.getSQLEditCode()),
                second: const SqlResultTables(),
              ),
            ),
          ],
        );
        return sessionProvider.isRightPageOpen()
            ? SplitView(
                axis: Axis.horizontal,
                controller: sessionProvider.session!.metaDataSplitViewCtrl,
                first: left,
                second: const SessionDrawerBody(),
              )
            : left;
      }),
    );
  }
}
