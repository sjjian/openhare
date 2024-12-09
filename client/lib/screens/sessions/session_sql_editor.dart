import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/sql.dart';

class CodeEditor extends StatefulWidget {
  final SqlEditingController codeController;

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
        // child: CodeField(
        //   lineNumberStyle: LineNumberStyle(
        //       background: Theme.of(context).colorScheme.surfaceContainerLowest),
        //   expands: true,
        //   controller: widget.codeController,
        //   textStyle: GoogleFonts.robotoMono(),
        // ),
        child: SqlField(codeController: widget.codeController),
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

class SqlField extends StatefulWidget {
  final SqlEditingController codeController;
  const SqlField({Key? key, required this.codeController}) : super(key: key);

  @override
  State<SqlField> createState() => _SqlFieldState();
}

class _SqlFieldState extends State<SqlField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.codeController,
      expands: true,
      maxLines: null,
      minLines: null,
      decoration: const InputDecoration(
        disabledBorder: InputBorder.none,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
      )
    );
  }
}

class SqlEditingController extends TextEditingController {
  SqlEditingController(String? text):super(text: text);

  @override
  set value(TextEditingValue newValue) {
    print("====================================");
    print(newValue.selection);
    print(newValue.composing);
    int l = newValue.selection.start - value.selection.start;
    if (l == 0) {
      print("没有输入字符");
    }else if (l > 0) {
      print("插入了${l}个字符");
    }else {
      print("删除了${l}个字符");
    }
    super.value = newValue;
  }
}