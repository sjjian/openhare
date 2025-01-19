import 'package:client/providers/sessions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:common/parser.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sql_editor/re_editor.dart';

class SessionOpBar extends StatelessWidget {
  final CodeLineEditingController codeController;
  final double height;

  const SessionOpBar({Key? key, required this.codeController, this.height = 36})
      : super(key: key);

  String getQuery(SessionProvider sessionProvider) {
    var content = codeController.text.toString();
    List<SQLChunk> querys = Splitter(content, ";").split();
    CodeLineSelection s = codeController.selection;
    String query;
    // 当界面手动选中了文本片段则仅执行该片段，当前还不支持多SQL执行.
    if (!s.isCollapsed) {
      query = codeController.selectedText;
    } else {
      int line = s.baseIndex + 1;
      int row = s.baseOffset;
      SQLChunk chunk = querys.firstWhere((chunk) {
        if (line < chunk.end.line) {
          return true;
        } else if (line == chunk.end.line && row <= chunk.end.row) {
          return true;
        }
        return false;
      }, orElse: () => SQLChunk.empty());
      query = chunk.content;
    }
    return query.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: height),
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        final canQuery = sessionProvider.canQuery();
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                iconSize: height,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(2),
                onPressed: canQuery
                    ? () {
                        String query = getQuery(sessionProvider);
                        if (query.isNotEmpty) {
                          sessionProvider.query(query, false);
                        }
                      }
                    : null,
                icon: Icon(Icons.play_arrow_rounded,
                    color: canQuery ? Colors.green : Colors.grey)),
            IconButton(
                iconSize: height,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(2),
                onPressed: canQuery
                    ? () {
                        String query = getQuery(sessionProvider);
                        if (query.isNotEmpty) {
                          sessionProvider.query(query, true);
                        }
                      }
                    : null,
                icon: Stack(alignment: Alignment.center, children: [
                  Icon(Icons.play_arrow_rounded,
                      color: canQuery ? Colors.green : Colors.grey),
                  const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 12,
                  ),
                ])),
            IconButton(
                iconSize: height,
                padding: const EdgeInsets.all(2),
                alignment: Alignment.topLeft,
                onPressed: canQuery
                    ? () {
                        String query = getQuery(sessionProvider);
                        if (query.isNotEmpty) {
                          sessionProvider.query("explain $query", true);
                        }
                      }
                    : null,
                icon: Icon(
                  Icons.e_mobiledata,
                  color: canQuery
                      ? const Color.fromARGB(255, 241, 192, 84)
                      : Colors.grey,
                )),
            // schema list
            const VerticalDivider(
              indent: 5,
              endIndent: 5,
            ),
            SchemaBar(
                disable: canQuery ? false : true,
                currentSchema: sessionProvider.session!.conn!.currentSchema),
            const Spacer(),
            if (sessionProvider.isRightPageOpen == false)
              IconButton(
                onPressed: () {
                  sessionProvider.showRightPage();
                },
                icon: const Icon(Icons.format_indent_decrease),
              )
          ],
        );
      }),
    );
  }
}

class SchemaBar extends StatefulWidget {
  final String? currentSchema;
  final bool disable;

  const SchemaBar({
    Key? key,
    required this.disable,
    this.currentSchema,
  }) : super(key: key);

  @override
  State<SchemaBar> createState() => _SchemaBarState();
}

class _SchemaBarState extends State<SchemaBar> {
  bool isEnter = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isEnter = true;
        });
      },
      onExit: (_) {
        setState(() {
          isEnter = false;
        });
      },
      child: GestureDetector(
        onTapUp: (detail) async {
          if (widget.disable) {
            return;
          }
          final position = detail.globalPosition;
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          final overlayPos = overlay.localToGlobal(Offset.zero);

          SessionProvider sessionProvider =
              Provider.of<SessionProvider>(context, listen: false);
          List<String> schemas = await sessionProvider.getSchemas();

          // todo
          showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                position.dx - overlayPos.dx,
                position.dy - overlayPos.dy,
                position.dx - overlayPos.dx,
                position.dy - overlayPos.dy,
              ),
              items: schemas.map((schema) {
                return PopupMenuItem<String>(
                    height: 30,
                    onTap: () {
                      SessionProvider sessionProvider =
                          Provider.of<SessionProvider>(context, listen: false);
                      sessionProvider.setCurrentSchema(schema);
                    },
                    child: Text(schema));
              }).toList());
        },
        child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            color: (isEnter && !widget.disable)
                ? Theme.of(context).colorScheme.surfaceContainerHigh // schema 鼠标移入的颜色
                : null,
            child: Row(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedDatabase,
                  color: Colors.black,
                  size: 20,
                ),
                Container(
                    padding: const EdgeInsets.only(left: 5),
                    width: 100,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.currentSchema ?? "",
                          overflow: TextOverflow.ellipsis,
                        ))),
              ],
            )),
      ),
    );
  }
}
