import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';


class CodeEditor extends StatefulWidget {
  final CodeController codeController;

  const CodeEditor({super.key, required this.codeController});

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      Widget codeField = Expanded(
          child: CodeTheme(
        data: CodeThemeData(
            styles: Theme.of(context).brightness == Brightness.dark
                ? a11yDarkTheme
                : a11yLightTheme),
        child: CodeField(
          lineNumberStyle: LineNumberStyle(
              background: Theme.of(context).colorScheme.surfaceContainerLowest),
          expands: true,
          controller: widget.codeController,
          textStyle: const TextStyle(fontFamily: 'Roboto Mono'),
        ),
      ));
      return codeField;
    });
  }
}