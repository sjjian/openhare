import 'dart:io';
import 'package:client/core/conn.dart';
import 'package:client/models/interface.dart';
import 'package:client/services/session_conn.dart';
import 'package:client/services/session_sql_result.dart';
import 'package:client/services/sessions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/duration_extend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_status.g.dart';

@Riverpod(keepAlive: true)
class SelectedSessionStatusNotifier
    extends _$SelectedSessionStatusNotifier {
  @override
  SessionStatusModel? build() {
    SelectedSessionId? sessionIdModel =
        ref.watch(selectedSessionIdServicesProvider);
    if (sessionIdModel == null) {
      return null;
    }
    SQLResultModel? sqlResultModel =
        ref.watch(selectedSQLResultControllerProvider);

    SessionConnModel sessionConnModel =
        ref.watch(sessionConnServicesProvider(sessionIdModel.sessionId));

    return SessionStatusModel(
      sessionId: sessionIdModel.sessionId,
      instanceName: sessionConnModel.conn.model.name,
      resultId: sqlResultModel?.result.id,
      state: sqlResultModel?.result.state ?? SQLExecuteState.init,
      query: sqlResultModel?.result.query,
      executeTime: sqlResultModel?.result.executeTime,
      affectedRows: sqlResultModel?.result.data?.affectedRows,
    );
  }
}

class SessionStatusTab extends ConsumerWidget {
  const SessionStatusTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionStatusModel? model =
        ref.watch(selectedSessionStatusNotifierProvider);
    if (model == null) {
      return Container(
        height: 30,
      );
    }
    String affectedRowsDisplay = "${model.affectedRows ?? "-"}";
    String executeTimeDisplay = model.executeTime?.format() ?? "-";
    String shortQueryDisplay = model.query?.trimLeft().split("\n")[0] ?? "-";
    
    return Container(
      padding: const EdgeInsets.only(left: 5),
      height: 30,
      child: Row(
        children: [
          Tooltip(
              message: 'effect rows: $affectedRowsDisplay',
              child: Text('effect rows: $affectedRowsDisplay')),
          const Text("  |  "),
          Tooltip(
              message: 'duration: $executeTimeDisplay',
              child: Text('duration: $executeTimeDisplay')),
          const Text("  |  "),
          Tooltip(
            message: model.query ?? "No query executed",
            child: SizedBox(
                width: 200,
                child: Text("query: $shortQueryDisplay",
                    overflow: TextOverflow.ellipsis)),
          ),
          const Text("  |  "),
          if (model.state == SQLExecuteState.done && model.resultId != null)
            IconButton(
                onPressed: () async {
                  //todo: 下载失效了，需要测试。
                  String? outputFile = await FilePicker.platform.saveFile(
                    dialogTitle: 'Please select an output file:',
                    fileName:
                        '${model.instanceName}-${DateTime.now().toIso8601String().replaceAll(":", "-").split('.')[0]}.xlsx',
                  );
                  if (outputFile == null) {
                    return;
                  }
                  File file = File(outputFile);
                  await file.writeAsBytes(ref
                      .read(sQLResultServicesProvider(
                              model.sessionId, model.resultId!)
                          .notifier)
                      .toExcel()
                      .save()!);
                },
                icon: const Icon(
                  Icons.download_rounded,
                  color: Colors.green,
                ))
        ],
      ),
    );
  }
}
