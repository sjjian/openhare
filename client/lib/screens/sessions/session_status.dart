import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/models/sql_result.dart';
import 'package:client/utils/duration_extend.dart';

class SessionStatus extends StatelessWidget {
  const SessionStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // todo: 采用更通用的形式
    return Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
      if (sessionProvider.initialized() &&
          !sessionProvider.showRecord &&
          sessionProvider.getCurrentSQLResult() != null) {
        SQLResultModel result = sessionProvider.getCurrentSQLResult()!;
        if (result.state == SQLExecuteState.done) {
          return Container(
            padding: const EdgeInsets.only(left: 5),
            color: Theme.of(context).colorScheme.surfaceContainer,
            height: 30,
            child: Row(
              children: [
                Tooltip(
                    message: 'effect rows: ${result.effectRows}',
                    child: Text('effect rows: ${result.effectRows}')),
                const Text("  |  "),
                Tooltip(
                    message: 'duration: ${result.executeTime!.format()}',
                    child: Text('duration: ${result.executeTime!.format()}')),
                const Text("  |  "),
                Tooltip(
                  message: result.query,
                  child: SizedBox(
                      width: 200,
                      child: Text(
                          "query: ${result.query.trimLeft().split("\n")[0]}",
                          overflow: TextOverflow.ellipsis)),
                )
              ],
            ),
          );
        } else {
          return Container(
              height: 30,
              color: Theme.of(context).colorScheme.surfaceContainer);
        }
      } else {
        return Container(
            height: 30, color: Theme.of(context).colorScheme.surfaceContainer);
      }
    });
  }
}
