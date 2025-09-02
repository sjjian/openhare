import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:client/screens/sessions/session_operation_bar.dart';
import 'package:client/screens/sessions/session_sql_editor.dart';
import 'package:client/screens/sessions/session_sql_results.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/services/sessions/session_controller.dart';
import 'package:client/widgets/const.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/split_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionBodyPage extends ConsumerWidget {
  const SessionBodyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionEditorModel sessionEditor = ref.watch(sessionEditorNotifierProvider);
    SessionDrawerModel sessionDrawer = ref.watch(sessionDrawerNotifierProvider);
    SessionController sessionController =
        SessionController.sessionController(sessionDrawer.sessionId);

    final Widget left = Row(
      children: [
        Expanded(
          child: SplitView(
            controller: sessionController.multiSplitViewCtrl,
            axis: Axis.vertical,
            first: SQLEditor(
                key: ValueKey(sessionEditor.code),
                codeController: sessionEditor.code),
            second: const SqlResultTables(),
          ),
        ),
        VerticalDivider(
          width: kBlockDividerSize,
          thickness: kBlockDividerThickness,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
    return Column(
      children: [
        SessionOpBar(codeController: sessionEditor.code),
        Divider(
          height: kBlockDividerSize,
          thickness: kBlockDividerThickness,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            child: sessionDrawer.isRightPageOpen
                ? SplitView(
                    axis: Axis.horizontal,
                    controller: sessionController.metaDataSplitViewCtrl,
                    first: left,
                    second: const SessionDrawerBody(),
                  )
                : left,
          ),
        ),
      ],
    );
  }
}
