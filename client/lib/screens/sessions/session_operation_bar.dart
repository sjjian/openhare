import 'package:client/providers/sessions.dart';
import 'package:client/screens/sessions/session_sql_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:common/parser.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:re_editor/re_editor.dart';

class SessionOpBar extends StatelessWidget {
  final CodeLineEditingController codeController;
  final double height;

  const SessionOpBar({Key? key, required this.codeController, this.height = 36})
      : super(key: key);

  String getQuery(SessionProvider sessionProvider) {
    var content = codeController.text.toString();
    List<String> querys = Splitter(content, ";").split();
    CodeLineSelection s = codeController.selection;

    String query;
    // 当界面手动选中了文本片段则仅执行该片段，当前还不支持多SQL执行.
    if (!s.isCollapsed) {
      query =
          codeController.text.toString().substring(s.start.index, s.end.index);
    } else {
      // 当前界面未选中SQL, 则当前游标在哪个SQL片段内就执行哪个SQL. todo: 移动到通用的地方.
      int totalLength = 0;
      query = querys.firstWhere((query) {
        totalLength = totalLength + query.length;
        if (s.start.index <= totalLength) {
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
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
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
            const Expanded(child: Spacer()),
            IconButton(
              onPressed: () {
                sessionProvider.isRightPageOpen
                    ? sessionProvider.hideRightPage()
                    : sessionProvider.showRightPage();
              },
              icon: sessionProvider.isRightPageOpen
                  ? const Icon(Icons.format_indent_increase)
                  : const Icon(Icons.format_indent_decrease),
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
