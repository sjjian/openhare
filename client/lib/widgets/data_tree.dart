import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

abstract class DataNode {
  List<DataNode> get children;
  Widget builder(BuildContext context);
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
            guide: const IndentGuide.connectingLines(indent: 20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                children: [
                  FolderButton(
                    openedIcon: widget.entry.node.openIcons(context),
                    closedIcon: widget.entry.node.closeIcons(context),
                    icon: widget.entry.node.openIcons(context),
                    isOpen: widget.entry.hasChildren
                        ? widget.entry.isExpanded
                        : null,
                    onPressed: widget.entry.hasChildren ? widget.onTap : null,
                  ),
                  Expanded(
                    child: widget.entry.node.builder(context),
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
