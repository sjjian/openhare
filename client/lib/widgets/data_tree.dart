import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:hugeicons/hugeicons.dart';

class DataNode {
  final String value;
  final String type;
  late List<DataNode> children;

  DataNode({
    required this.value,
    required this.type,
  }) {
    children = List.empty(growable: true);
  }

  IconData openIcons() {
    if (type == "schema") {
      return HugeIcons.strokeRoundedDatabase;
    } else if (type == "table") {
      return HugeIcons.strokeRoundedTable;
    } else {
      return HugeIcons.strokeRoundedDatabase;
    }
  }

  IconData closeIcons() {
    return HugeIcons.strokeRoundedDatabase;
  }

  void addChildren(DataNode node) {
    children.add(node);
  }
}

class DataTree extends StatefulWidget {
  final List<DataNode> roots;

  const DataTree({Key? key, required this.roots}) : super(key: key);

  @override
  State<DataTree> createState() => _DataTreeState();
}

class _DataTreeState extends State<DataTree> {
  @override
  Widget build(BuildContext context) {
    late final TreeController<DataNode> treeController;
    treeController = TreeController<DataNode>(
      roots: widget.roots,
      childrenProvider: (DataNode node) => node.children,
    );
    return TreeView<DataNode>(
      treeController: treeController,
      nodeBuilder: (BuildContext context, TreeEntry<DataNode> entry) {
        return MyTreeTile(
          key: ValueKey(entry.node),
          entry: entry,
          onTap: () => treeController.toggleExpansion(entry.node),
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
          color: isEnter? Theme.of(context).colorScheme.surfaceContainerLow : null,
          child: TreeIndentation(
            entry: widget.entry,
            guide: const IndentGuide.connectingLines(indent: 32),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                children: [
                  FolderButton(
                    openedIcon: HugeIcon(
                      icon: widget.entry.node.openIcons(),
                      color: Theme.of(context).iconTheme.color ?? Colors.black87,
                    ),
                    closedIcon: HugeIcon(
                      icon: widget.entry.node.closeIcons(),
                      color: Theme.of(context).iconTheme.color ?? Colors.black87,
                    ),
                    icon: HugeIcon(
                      icon: widget.entry.node.openIcons(),
                      color: Theme.of(context).iconTheme.color ?? Colors.black87,
                    ),
                    isOpen:
                        widget.entry.hasChildren ? widget.entry.isExpanded : null,
                    onPressed: widget.entry.hasChildren ? widget.onTap : null,
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: InkWell(
                      onTap: () {
                        print("text press");
                      },
                      child: Text(
                        selectionColor: Theme.of(context).colorScheme.primary,
                        widget.entry.hasChildren? "${widget.entry.node.value}  [${widget.entry.node.children.length}]": widget.entry.node.value,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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