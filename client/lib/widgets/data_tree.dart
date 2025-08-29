import 'package:client/widgets/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

abstract class DataNode {
  List<DataNode> get children;
  Widget builder(BuildContext context, bool isOpen);
  Widget closeIcons(BuildContext context);
  Widget openIcons(BuildContext context);
}

class DataTree extends StatefulWidget {
  final TreeController<DataNode> controller;

  const DataTree({Key? key, required this.controller}) : super(key: key);

  @override
  State<DataTree> createState() => _DataTreeState();
}

class _DataTreeState extends State<DataTree> {
  @override
  Widget build(BuildContext context) {
    return TreeView<DataNode>(
      treeController: widget.controller,
      nodeBuilder: (BuildContext context, TreeEntry<DataNode> entry) {
        return MyTreeTile(
          key: ValueKey(entry.node),
          entry: entry,
          onTap: () => widget.controller.toggleExpansion(entry.node),
        );
      },
    );
  }
}

// Create a widget to display the data held by your tree nodes.
class MyTreeTile extends StatefulWidget {
  final TreeEntry<DataNode> entry;
  final VoidCallback onTap;

  const MyTreeTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  State<MyTreeTile> createState() => _MyTreeTileState();
}

class _MyTreeTileState extends State<MyTreeTile> {
  bool isEnter = false;

  bool get isOpen => widget.entry.hasChildren && widget.entry.isExpanded;

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
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          color: isEnter
              ? Theme.of(context)
                  .colorScheme
                  .surfaceContainer // meta data detail 鼠标移入的颜色
              : null,
          child: TreeIndentation(
            entry: widget.entry,
            guide: const IndentGuide.scopingLines(
              indent: 20,
              thickness: 0,
            ),
            child: SizedBox(
              height: 25,
              child: Row(
                children: [
                  (widget.entry.hasChildren)
                      ? (widget.entry.isExpanded)
                          ? const Icon(Icons.expand_more, size: kIconSizeSmall)
                          : const Icon(Icons.chevron_right,
                              size: kIconSizeSmall)
                      : const SizedBox(width: kIconSizeSmall),
                  (isOpen)
                      ? widget.entry.node.openIcons(context)
                      : widget.entry.node.closeIcons(context),
                  const SizedBox(width: kSpacingTiny),
                  Expanded(
                    child: widget.entry.node.builder(context, isOpen),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
