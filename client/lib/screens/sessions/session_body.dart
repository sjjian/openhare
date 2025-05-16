import 'package:client/models/interface.dart';
import 'package:client/providers/model.dart';
import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:client/screens/sessions/session_operation_bar.dart';
import 'package:client/screens/sessions/session_sql_editor.dart';
import 'package:client/screens/sessions/session_sql_results.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/split_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionBodyPage extends ConsumerWidget {
  const SessionBodyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CurrentSession session = ref.watch(currentSessionProvider)!;

    final Widget left = Column(
      children: [
        SessionOpBar(codeController: (session as Session).getSQLEditCode()),
        Expanded(
          child: SplitView(
            controller: session.multiSplitViewCtrl,
            axis: Axis.vertical,
            first: SQLEditor(
                key: ValueKey(session.getSQLEditCode()),
                codeController: session.getSQLEditCode()),
            second: const SqlResultTables(),
          ),
        ),
      ],
    );
    return Container(
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: session.isRightPageOpen
          ? SplitView(
              axis: Axis.horizontal,
              controller: session.metaDataSplitViewCtrl,
              first: left,
              second: const SessionDrawerBody(),
            )
          : left,
    );
  }
}
