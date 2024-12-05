import 'package:client/providers/sessions.dart';
import 'package:client/screens/sessions/session_metadata.dart';
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
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10)),
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        const double codeButtonHeight = 36;

        final Widget left = Expanded(
          child: Column(
            children: [
              SplitView(
                controller: sessionProvider.session!.multiSplitViewCtrl,
                axis: Axis.vertical,
                first: CodeEditor(
                    key: ValueKey(sessionProvider.getSQLEditCode()),
                    codeController: sessionProvider.getSQLEditCode()),
                second: const Expanded(child: SqlResultTables()),
              ),
            ],
          ),
        );

        return Column(
          children: [
            SessionOpBar(
                codeController: sessionProvider.getSQLEditCode(),
                height: codeButtonHeight),
            sessionProvider.isRightPageOpen
                ? Expanded(
                    child: SplitView(
                      axis: Axis.horizontal,
                      controller:
                          sessionProvider.session!.metaDataSplitViewCtrl,
                      first: left,
                      second: SessionMetadata(
                        controller:
                            sessionProvider.session!.metadataController, //todo
                      ),
                    ),
                  )
                : left,
          ],
        );
      }),
    );
  }
}

