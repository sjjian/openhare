import 'package:client/providers/sessions.dart';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:provider/provider.dart';
import 'package:common/parser.dart';

class CodeButtionBar extends StatefulWidget {
  final CodeController codeController;
  final double height;

  const CodeButtionBar(
      {Key? key, required this.codeController, this.height = 36})
      : super(key: key);

  @override
  State<CodeButtionBar> createState() => _CodeButtionBarState();
}

class _CodeButtionBarState extends State<CodeButtionBar> {
  void query(SessionProvider sessionProvider, bool newResult) {
    var content = widget.codeController.text.toString();
    List<String> querys = Splitter(content, ";").split();
    TextSelection s = widget.codeController.selection;

    String query;
    // 当界面手动选中了文本片段则仅执行该片段，当前还不支持多SQL执行.
    if (!s.isCollapsed) {
      query = widget.codeController.text.toString().substring(s.start, s.end);
    } else {
      // 当前界面未选中SQL, 则当前游标在哪个SQL片段内就执行哪个SQL. todo: 移动到通用的地方.
      int totalLength = 0;
      query = querys.firstWhere((query) {
        totalLength = totalLength + query.length;
        if (s.start <= totalLength) {
          return true;
        } else {
          return false;
        }
      }, orElse: () => "");
    }
    if (query.trim().isNotEmpty) {
      sessionProvider.query(query, newResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 5),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      constraints: BoxConstraints(maxHeight: widget.height),
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        final canQuery = sessionProvider.canQuery();
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                iconSize: widget.height,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(2),
                onPressed: canQuery
                    ? () {
                        query(sessionProvider, false);
                      }
                    : null,
                icon: Icon(Icons.play_arrow_rounded,
                    color: canQuery ? Colors.green : Colors.grey)),
            IconButton(
                iconSize: widget.height,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(2),
                onPressed: canQuery
                    ? () {
                        query(sessionProvider, true);
                      }
                    : null,
                icon: Icon(Icons.play_arrow_rounded,
                    color: canQuery ? Colors.green : Colors.grey)),
          ],
        );
      }),
    );
  }
}
