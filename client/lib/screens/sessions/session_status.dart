import 'dart:io';
import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/duration_extend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              message:
                  '${AppLocalizations.of(context)!.effect_rows}: $affectedRowsDisplay',
              child: Text(
                  '${AppLocalizations.of(context)!.effect_rows}: $affectedRowsDisplay')),
          const Text("  |  "),
          Tooltip(
              message:
                  '${AppLocalizations.of(context)!.duration}: $executeTimeDisplay',
              child: Text(
                  '${AppLocalizations.of(context)!.duration}: $executeTimeDisplay')),
          const Text("  |  "),
          Tooltip(
            message:
                model.query ?? AppLocalizations.of(context)!.no_query_executed,
            child: SizedBox(
                width: 200,
                child: Text(
                    "${AppLocalizations.of(context)!.query}: $shortQueryDisplay",
                    overflow: TextOverflow.ellipsis)),
          ),
          const Text("  |  "),
          if (model.state == SQLExecuteState.done && model.resultId != null)
            IconButton(
                onPressed: () async {
                  //todo: 下载失效了，需要测试。
                  String? outputFile = await FilePicker.platform.saveFile(
                    dialogTitle:
                        AppLocalizations.of(context)!.display_msg_downlaod,
                    fileName:
                        '${model.instanceName}-${DateTime.now().toIso8601String().replaceAll(":", "-").split('.')[0]}.xlsx',
                  );
                  if (outputFile == null) {
                    return;
                  }
                  File file = File(outputFile);
                  await file.writeAsBytes(ref
                      .read(sQLResultServicesProvider(model.resultId!).notifier)
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
