import 'dart:convert';
import 'dart:typed_data';
import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/utils/file_type.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionDrawerSqlResult extends ConsumerWidget {
  const SessionDrawerSqlResult({Key? key}) : super(key: key);

  Widget buildDisplayField(
      BuildContext context, SessionDrawerModel sessionDrawer) {
    BaseQueryValue? result = sessionDrawer.sqlResult;
    if (result == null) {
      return const ValueDisplayField(data: "");
    }
    BaseQueryColumn? column = sessionDrawer.sqlColumn;
    if (column == null) {
      return ValueDisplayField(data: result.getString() ?? "");
    }
    final dataType = column.dataType();
    if (dataType == DataType.blob) {
      List<int> bytes = result.getBytes();
      FileType fileType = getFileType(bytes);
      if (fileType == FileType.gif ||
          fileType == FileType.png ||
          fileType == FileType.jpeg) {
        return Align(
          alignment: Alignment.topLeft,
          child: Image.memory(Uint8List.fromList(bytes)),
        );
      }
    }
    if (dataType == DataType.json) {
      return ValueDisplayField(
        data: formatJson(result.getString() ?? "{}"),
        language: "json",
      );
    } else {
      return ValueDisplayField(data: result.getString() ?? "");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionDrawer = ref.watch(sessionDrawerNotifierProvider);
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: buildDisplayField(context, sessionDrawer),
            // child: buildDisplayField(context),
          ),
        ],);
  }
}

class ValueDisplayField extends StatelessWidget {
  final String data;
  final String? language;

  const ValueDisplayField({super.key, required this.data, this.language});

  static Map<String, CodeHighlightThemeMode> languages = {
    'json': CodeHighlightThemeMode(mode: langJson),
  };

  @override
  Widget build(BuildContext context) {
    CodeLineEditingController controller = CodeLineEditingController();
    controller.text = data;
    return CodeEditor(
      style: CodeEditorStyle(
        codeTheme: language != null
            ? CodeHighlightTheme(
                languages:
                    Map.from({language: ValueDisplayField.languages[language]}),
                theme: atomOneLightTheme)
            : null,
      ),
      controller: controller,
      readOnly: true,
      wordWrap: false,
    );
  }
}

String formatJson(String jsonString) {
  var jsonMap = jsonDecode(jsonString);
  var encoder = const JsonEncoder.withIndent('  ');
  return encoder.convert(jsonMap);
}
