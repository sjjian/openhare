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
    return LayoutBuilder(builder: (ctx, c) {
      Widget codeField = Expanded(
          child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: CodeTheme(
          data: const CodeThemeData(styles: a11yLightTheme),
          child: CodeField(
            expands: true,
            controller: _codeController!,
            textStyle: const TextStyle(fontFamily: 'SourceCode'),
          ),
        ),
      ));

      Widget codeButton = Container(
        constraints: const BoxConstraints(maxHeight: 40),
        decoration: const BoxDecoration(
            border: Border(
                right: BorderSide(color: Colors.grey),
                left: BorderSide(color: Colors.grey),
                bottom: BorderSide(color: Colors.grey))),
        child: const Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Icon(Icons.play_arrow_rounded, size: 36, color: Colors.green)
        ]),
      );

      if (c.maxHeight <= 40) {
        codeButton = Expanded(child: codeButton);
        return Column(children: [codeButton]);
      } else {
        return Column(
          children: [codeField, codeButton],
        );
      }
    });
  }
}
