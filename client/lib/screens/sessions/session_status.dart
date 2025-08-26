import 'dart:io';
import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/duration_extend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/l10n/app_localizations.dart';

class SessionStatusTab extends ConsumerWidget {
  const SessionStatusTab({Key? key}) : super(key: key);

  Widget divider(BuildContext context) {
    return const VerticalDivider(
      thickness: kDividerThickness,
      width: kDividerSize,
      indent: 10,
      endIndent: 10,
    );
  }

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
      padding: const EdgeInsets.only(left: kSpacingSmall),
      child: Row(
        children: [
          Tooltip(
            message: model.connErrorMsg ?? '-',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 80),
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("${AppLocalizations.of(context)!.short_conn}:"),
                    const SizedBox(width: 4),
                    Expanded(
                        child: switch (model.connState) {
                      SQLConnectState.connected ||
                      SQLConnectState.executing =>
                        const Icon(Icons.check_circle,
                            size: kIconSizeTiny, color: Colors.green),
                      SQLConnectState.failed ||
                      SQLConnectState.unHealth =>
                        const Icon(Icons.error,
                            size: kIconSizeTiny, color: Colors.red),
                      _ => const Text("-"),
                    } // 根据model.state展示不同的图标
                        ),
                  ],
                ),
              ),
            ),
          ),
          if (model.resultId != null) ...[
            divider(context),
            ValueStatusWidget(
                label: AppLocalizations.of(context)!.effect_rows,
                value: affectedRowsDisplay,
                tooltip: affectedRowsDisplay),
            divider(context),
            ValueStatusWidget(
                label: AppLocalizations.of(context)!.duration,
                value: executeTimeDisplay,
                tooltip: executeTimeDisplay),
            divider(context),
            ValueStatusWidget(
                width: 300,
                label: AppLocalizations.of(context)!.query,
                value: shortQueryDisplay,
                tooltip: model.query ??
                    AppLocalizations.of(context)!.no_query_executed),
            if (model.state == SQLExecuteState.done && model.resultId != null)
              RectangleIconButton.medium(
                icon: Icons.download_rounded,
                iconColor: Colors.green,
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
                      .read(selectedSQLResultNotifierProvider.notifier)
                      .toExcel()
                      .save()!);
                },
              ),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}

class ValueStatusWidget extends StatelessWidget {
  final String label;
  final String value;
  final String? tooltip;
  final double width;

  const ValueStatusWidget({
    Key? key,
    required this.label,
    required this.value,
    this.tooltip,
    this.width = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? value,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          constraints: BoxConstraints(maxWidth: width),
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('$label:'),
              const SizedBox(width: kSpacingTiny),
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
