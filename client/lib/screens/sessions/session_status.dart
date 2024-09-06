import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/models/sql_result.dart';
import 'package:client/utils/duration_extend.dart';

class SessionStatus extends StatefulWidget {
  const SessionStatus({Key? key}) : super(key: key);

  @override
  State<SessionStatus> createState() => _SessionStatusState();
}

class _SessionStatusState extends State<SessionStatus> {
  @override
  Widget build(BuildContext context) {
    // todo: 采用更通用的形式
    return Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
      if (sessionProvider.initialized() &&
          !sessionProvider.showRecord &&
          sessionProvider.getCurrentSQLResult() != null) {
        SQLResultModel result = sessionProvider.getCurrentSQLResult()!;
        if (result.state == SQLExecuteState.done) {
          return SizedBox(
            height: 30,
            child: Row(
              children: [
                Tooltip(
                    message: 'effect rows: ${result.effectRows}',
                    child: Text('effect rows: ${result.effectRows}')),
                const Text("  |  "),
                Tooltip(
                    message: 'duration: ${result.executeTime!.inSeconds}',
                    child: Text('duration: ${result.executeTime!.format()}')),
                const Text("  |  "),
                Tooltip(
                  message: result.query,
                  child: SizedBox(
                      width: 200,
                      child: Text("query: ${result.query.trimLeft().split("\n")[0]}",
                          overflow: TextOverflow.ellipsis)),
                )
              ],
            ),
          );
        } else {
          return const SizedBox(height: 30);
        }
      } else {
        return const SizedBox(height: 30);
      }
    });
  }
}
