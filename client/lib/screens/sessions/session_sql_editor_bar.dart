import 'package:client/providers/sessions.dart';
import 'package:client/screens/sessions/session_drawer.dart';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:provider/provider.dart';
import 'package:common/parser.dart';
import 'package:hugeicons/hugeicons.dart';

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
  String getQuery(SessionProvider sessionProvider) {
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
    return query.trim();
  }

  @override
  Widget build(BuildContext context) {
    // CustomDrawer c = CustomDrawer(context: context, child: const Text("test"));
    return Container(
      // padding: const EdgeInsets.only(left: 5),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      
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
                        String query = getQuery(sessionProvider);
                        if (query.isNotEmpty) {
                          sessionProvider.query(query, false);
                        }
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
                iconSize: widget.height,
                padding: const EdgeInsets.all(2),
                alignment: Alignment.topLeft,
                onPressed: canQuery? () {
                  String query = getQuery(sessionProvider);
                  if (query.isNotEmpty) {
                    sessionProvider.query("explain $query", true);
                  }
                }: null,
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
            const Expanded(child: Spacer()),
             IconButton(onPressed: () {
              Scaffold.of(context).openEndDrawer();
            }, icon: const Icon(Icons.menu)),
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
                ? Theme.of(context).colorScheme.surfaceContainerHighest
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
