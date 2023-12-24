import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/sql.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';

class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key});

  @override
  _CodeEditorState createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    const source = "select * from db1.t1;";
    // Instantiate the CodeController
    _codeController = CodeController(
      text: source,
      language: sql,
    );
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: CodeTheme(
        data: const CodeThemeData(styles: a11yLightTheme),
        child: CodeField(
          minLines: 20,
          maxLines: 20,
          controller: _codeController!,
          textStyle: const TextStyle(fontFamily: 'SourceCode'),
        ),
      ),
    );
  }
}
