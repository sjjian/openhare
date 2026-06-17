import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:client/screens/sessions/session_drawer_metadata.dart';
import 'package:client/screens/sessions/session_operation_bar.dart';
import 'package:client/screens/sessions/session_sql_editor.dart';
import 'package:client/screens/sessions/session_sql_results.dart';
import 'package:client/services/sessions/session_drawer.dart';
import 'package:client/services/sessions/session_controller.dart';
import 'package:client/widgets/divider.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/split_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionBodyPage extends ConsumerWidget {
  const SessionBodyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionDrawerModel sessionDrawer = ref.watch(sessionDrawerProvider);
    SessionController sessionController = ref.watch(selectedSessionControllerProvider);

    return Column(
      children: [
        SessionOpBar(codeController: sessionController.sqlEditorController),
        const PixelDivider(),
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            child: SplitView(
              controller: sessionController.leftSidebarSplitViewCtrl,
              reverse: true,
              showSecond: sessionDrawer.isMetadataTreeOpen,
              second: const SessionDrawerMetadata(),
              first: SplitView(
                controller: sessionController.rightSidebarSplitViewCtrl,
                showSecond: sessionDrawer.isRightPageOpen,
                second: const SessionDrawerBody(),
                first: SplitView(
                  controller: sessionController.editorResultSplitViewCtrl,
                  axis: Axis.vertical,
                  second: const SqlResultTables(),
                  first: SQLEditor(
                    key: ValueKey(sessionController.sqlEditorController),
                    codeController: sessionController.sqlEditorController,
                    scrollController: sessionController.sqlEditorScrollController,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
