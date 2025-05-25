import 'dart:io';
import 'package:client/core/conn.dart';
import 'package:client/models/interface.dart';
import 'package:client/providers/session_sql_result.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/providers/session_conn.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:client/repositories/session_sql_result.dart';
import 'package:client/utils/duration_extend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionStatusTab extends ConsumerWidget {
  const SessionStatusTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SelectedSessionId sessionIdModel = ref.watch(selectedSessionIdControllerProvider);
    if (sessionIdModel.instanceId == null || sessionIdModel.sessionId == 0) {
      return Container(
        height: 30,
      );
    }
    SQLResult? sqlResult = ref.watch(sQLResultControllerProvider);
    SessionConnModel sessionConnModel = ref.watch(sessionConnControllerProvider(sessionIdModel.sessionId));
    // todo: 采用更通用的形式
    if (sqlResult == null) {
      return Container(
        height: 30,
      );
    }
    if (sqlResult.state == SQLExecuteState.done) {
      return Container(
        padding: const EdgeInsets.only(left: 5),
        height: 30,
        child: Row(
          children: [
            Tooltip(
                message: 'effect rows: ${sqlResult.affectedRows}',
                child: Text('effect rows: ${sqlResult.affectedRows}')),
            const Text("  |  "),
            Tooltip(
                message: 'duration: ${sqlResult.executeTime!.format()}',
                child: Text('duration: ${sqlResult.executeTime!.format()}')),
            const Text("  |  "),
            Tooltip(
              message: sqlResult.query,
              child: SizedBox(
                  width: 200,
                  child: Text(
                      "query: ${sqlResult.query.trimLeft().split("\n")[0]}",
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
                  await file.writeAsBytes(sqlResult.toExcel().save()!);
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
