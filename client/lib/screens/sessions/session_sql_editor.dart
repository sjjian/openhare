import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/sql.dart';

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
          textStyle: GoogleFonts.robotoMono(),
        ),
      ));
      return codeField;
    });
  }
}

class SQLCodeController extends CodeController {
  SQLCodeController()
      : super(text: "", language: sql, modifiers: [
          const IndentModifier(),
          const CloseBlockModifier(),
          const SQlTabModifier(),
        ]);
}

class SQlTabModifier extends CodeModifier {
  // BuildContext context;
  const SQlTabModifier() : super('\t');

  @override
  TextEditingValue? updateString(
    String text,
    TextSelection sel,
    EditorParams params,
  ) {

    // todo
    // showMenu(
    //     // context: BuildContext(),
    //     // position: RelativeRect.fromLTRB(
    //     //   position.dx - overlayPos.dx,
    //     //   position.dy - overlayPos.dy,
    //     //   position.dx - overlayPos.dx,
    //     //   position.dy - overlayPos.dy,
    //     // ),
    //     items: [
    //       PopupMenuItem<String>(
    //           height: 30,
    //           onTap: () {
    //            print(1);
    //           },
    //           child: const Text("test"))
    //     ]);
    final tmp = replace(text, sel.start, sel.end, "");
    return tmp;
  }
}
