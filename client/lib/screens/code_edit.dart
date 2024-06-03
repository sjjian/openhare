import 'package:client/providers/sessions.dart';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/sql.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:provider/provider.dart';

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
        data: const CodeThemeData(styles: a11yLightTheme),
        child: CodeField(
          expands: true,
          controller: widget.codeController,
          textStyle: const TextStyle(fontFamily: 'SourceCode'),
        ),
      ));

      Widget codeButton = Container(
        constraints: const BoxConstraints(maxHeight: 40),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
            final canQuery = sessionProvider.canQuery();
            return IconButton(
                alignment: Alignment.topLeft,
                onPressed: canQuery
                    ? () {
                        final query = widget.codeController.text.toString();
                        if (query.isNotEmpty) {
                          sessionProvider.query(query);
                        }
                      }
                    : null,
                icon: Icon(Icons.play_arrow_rounded,
                    size: 36, color: canQuery ? Colors.green : Colors.grey));
          })
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
