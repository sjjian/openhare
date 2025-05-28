import 'dart:io';
import 'package:client/core/conn.dart';
import 'package:client/models/interface.dart';
import 'package:client/providers/session_sql_result.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/providers/session_conn.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/duration_extend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionStatusTab extends ConsumerWidget {
  const SessionStatusTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // todo: 删除
    SelectedSessionId sessionIdModel = ref.watch(selectedSessionIdControllerProvider);
    if (sessionIdModel.instanceId == null || sessionIdModel.sessionId == 0) {
      return Container(
        height: 30,
      );
    }
    SQLResultModel? sqlResultModel = ref.watch(selectedSQLResultControllerProvider);
    SessionConnModel sessionConnModel = ref.watch(sessionConnControllerProvider(sessionIdModel.sessionId));
    // todo: 采用更通用的形式
    if (sqlResultModel == null) {
      return Container(
        height: 30,
      );
    }
    if (sqlResultModel.result.state == SQLExecuteState.done) {
      return Container(
        padding: const EdgeInsets.only(left: 5),
        height: 30,
        child: Row(
          children: [
            Tooltip(
                message: 'effect rows: ${sqlResultModel.result.data!.affectedRows}',
                child: Text('effect rows: ${sqlResultModel.result.data!.affectedRows}')),
            const Text("  |  "),
            Tooltip(
                message: 'duration: ${sqlResultModel.result.executeTime!.format()}',
                child: Text('duration: ${sqlResultModel.result.executeTime!.format()}')),
            const Text("  |  "),
            Tooltip(
              message: sqlResultModel.result.query,
              child: SizedBox(
                  width: 200,
                  child: Text(
                      "query: ${sqlResultModel.result.query!.trimLeft().split("\n")[0]}",
                      overflow: TextOverflow.ellipsis)),
            ),
            const Text("  |  "),
            IconButton(
                onPressed: () async {
                  String? outputFile = await FilePicker.platform.saveFile(
                    dialogTitle: 'Please select an output file:',
                    fileName:
                        '${sessionConnModel.conn.model.instance.target!.connectValue.name}-${DateTime.now().toIso8601String().replaceAll(":", "-").split('.')[0]}.xlsx',
                  );
                  if (outputFile == null) {
                    return;
                  }
                  File file = File(outputFile);
                  await file.writeAsBytes(sqlResultModel.result.toExcel().save()!);
                },
                icon: const Icon(
                  Icons.download_rounded,
                  color: Colors.green,
                ))
          ],
        ),
      );
    }
    return Container(
      height: 30,
    );
  }
}
