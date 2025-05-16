import 'package:client/models/interface.dart';
import 'package:client/providers/sessions.dart';
import 'package:flutter/material.dart';
import 'package:sql_parser/parser.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:client/providers/model.dart';
import 'package:client/models/sessions.dart';

class SessionOpBar extends ConsumerWidget {
  final CodeLineEditingController codeController;
  final double height;

  const SessionOpBar({Key? key, required this.codeController, this.height = 36})
      : super(key: key);

  String getQuery() {
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
  Widget build(BuildContext context, WidgetRef ref) {
    BaseSession session = ref.watch(currentSessionProvider)!;
    CurrentSessionDrawer sessionDrawer = ref.watch(sessionDrawerControllerProvider)!;

    final canQuery = (session as Session).canQuery();
    return Container(
      constraints: BoxConstraints(maxHeight: height),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              iconSize: height,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(2),
              onPressed: canQuery
                  ? () {
                      String query = getQuery();
                      if (query.isNotEmpty) {
                        ref
                            .read(sessionProviderProvider.notifier)
                            .query(query, false);
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
                      String query = getQuery();
                      if (query.isNotEmpty) {
                        ref
                            .read(sessionProviderProvider.notifier)
                            .query(query, true);
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
                      String query = getQuery();
                      if (query.isNotEmpty) {
                        ref
                            .read(sessionProviderProvider.notifier)
                            .query("explain $query", true);
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
              currentSchema: session.model.currentSchema),
          const Spacer(),
          if (sessionDrawer.isRightPageOpen == false)
            IconButton(
              onPressed: () {
                ref
                    .read(sessionDrawerControllerProvider.notifier)
                    .showRightPage();
              },
              icon: const Icon(Icons.format_indent_decrease),
            )
        ],
      ),
    );
  }
}

class SchemaBar extends HookConsumerWidget {
  final String? currentSchema;
  final bool disable;

  const SchemaBar({
    Key? key,
    required this.disable,
    this.currentSchema,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BaseSession session = ref.watch(currentSessionProvider)!;
    const isEnter = false;

    return MouseRegion(
      onEnter: (_) {
        // isEnter. = true;
      },
      onExit: (_) {
        // isEnter.value = false;
      },
      child: GestureDetector(
        onTapUp: (detail) async {
          if (disable) {
            return;
          }
          final position = detail.globalPosition;
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          final overlayPos = overlay.localToGlobal(Offset.zero);

          List<String> schemas = await (session as Session).getSchemas();

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
                      ref
                          .read(sessionProviderProvider.notifier)
                          .setCurrentSchema(schema);
                    },
                    child: Text(schema));
              }).toList());
        },
        child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            color: (isEnter && !disable)
                ? Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh // schema 鼠标移入的颜色
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
                          currentSchema ?? "",
                          overflow: TextOverflow.ellipsis,
                        ))),
              ],
            )),
      ),
    );
  }
}
