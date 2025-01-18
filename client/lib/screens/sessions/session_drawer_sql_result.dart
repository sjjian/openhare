import 'dart:convert';
import 'dart:typed_data';
import 'package:client/core/connection/result_set.dart';
import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:client/utils/file_type.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

class SessionDrawerSqlResult extends StatelessWidget {
  final SessionDrawerController controller;

  const SessionDrawerSqlResult({Key? key, required this.controller})
      : super(key: key);

  Widget buildDisplayField(BuildContext context) {
    ResultSetValue? result = controller.sqlResult;
    if (result == null || result.asString() == null) {
      return const ValueDisplayField(data: "");
    }
    if (result.type() == ValueType.bit) {
      List<int> bytes = result.asByte();
      FileType fileType = getFileType(result.asByte());
      if (fileType == FileType.gif ||
          fileType == FileType.png ||
          fileType == FileType.jpeg) {
        return Align(
          alignment: Alignment.topLeft,
          child: Image.memory(Uint8List.fromList(bytes)),
        );
      }
    }
    if (result.type() == ValueType.json) {
      return ValueDisplayField(
        data: formatJson(result.asString()!),
        language: "json",
      );
    } else {
      return ValueDisplayField(data: result.asString()!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Divider(
            endIndent: 10,
          ),
          Expanded(child: buildDisplayField(context)),
        ]);
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
