import 'package:client/l10n/app_localizations.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:collection/collection.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:hugeicons/hugeicons.dart';

abstract class DataNode {
  List<DataNode> get children;
  Widget builder(BuildContext context, bool isOpen);
  Widget closeIcons(BuildContext context);
  Widget openIcons(BuildContext context);
  void visitor(bool Function(DataNode node) callback);
}

DataNode buildDataNode(MetaDataNode node) {
  return switch (node.type) {
    MetaType.database => DatabaseNode(),
    MetaType.table => TableNode(),
    MetaType.column => ColumnNode(),
    MetaType.schema => SchemaNode(),
    MetaType.instance => InstanceNode(),
  };
}

DataNode buildDataValueNode(MetaDataNode node) {
  return switch (node.type) {
    MetaType.database => SchemaValueNode(node.value),
    MetaType.table => TableValueNode(node.value),
    MetaType.column =>
      ColumnValueNode(node.value, node.getProp(MetaDataPropType.dataType)),
    _ => SchemaValueNode(node.value)
  };
}

DataNode buildMetadataTree(DataNode parent, List<MetaDataNode>? nodes) {
  if (nodes == null) {
    return parent;
  }
  final groupedNodes = nodes.groupListsBy((node) => node.type);
  for (final type in groupedNodes.keys) {
    final dataNode = buildDataNode(groupedNodes[type]!.first);
    parent.children.add(dataNode);

    for (final node in groupedNodes[type]!) {
      final dataValueNode = buildDataValueNode(node);
      dataNode.children.add(dataValueNode);
      if (node.items != null && node.items!.isNotEmpty) {
        buildMetadataTree(dataValueNode, node.items!);
      }
    }
  }
  return parent;
}

class RootNode implements DataNode {
  final List<DataNode> _children = List.empty(growable: true);

  RootNode();

  @override
  List<DataNode> get children {
    return _children;
  }

  @override
  Widget openIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedFolder02,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedFolder01,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }

  @override
  Widget builder(context, isOpen) {
    return const Spacer();
  }

  @override
  void visitor(bool Function(DataNode node) callback) {
    callback(this);
    for (var node in children) {
      node.visitor(callback);
    }
  }
}

class FolderNode extends RootNode {
  FolderNode() : super();

  @override
  Widget openIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedFolder02,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedFolder01,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }

  String _name(BuildContext context) => "";

  @override
  Widget builder(BuildContext context, bool isOpen) {
    final name = _name(context);
    return Text(
      children.isNotEmpty ? "$name  [${_children.length}]" : name,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }
}

class DatabaseNode extends FolderNode {
  DatabaseNode() : super();

  @override
  String _name(BuildContext context) =>
      AppLocalizations.of(context)!.metadata_tree_database;
}

class TableNode extends FolderNode {
  TableNode() : super();

  @override
  String _name(BuildContext context) =>
      AppLocalizations.of(context)!.metadata_tree_table;
}

class ColumnNode extends FolderNode {
  ColumnNode() : super();

  @override
  String _name(BuildContext context) =>
      AppLocalizations.of(context)!.metadata_tree_column;
}

class SchemaNode extends FolderNode {
  SchemaNode() : super();

  @override
  String _name(BuildContext context) =>
      AppLocalizations.of(context)!.metadata_tree_schema;
}

class InstanceNode extends FolderNode {
  InstanceNode() : super();

  @override
  String _name(BuildContext context) =>
      AppLocalizations.of(context)!.metadata_tree_instance;
}

class DataValueNode extends RootNode {
  final String name;

  DataValueNode(this.name);

  @override
  List<DataNode> get children {
    return _children;
  }

  @override
  Widget openIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedTable,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedTable,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  @override
  Widget builder(BuildContext context, bool isOpen) {
    return Text(
      name,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isOpen
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurface),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class SchemaValueNode extends DataValueNode {
  SchemaValueNode(String name) : super(name);

  @override
  Widget openIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedDatabase,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedDatabase,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}

class TableValueNode extends DataValueNode {
  TableValueNode(String name) : super(name);

  @override
  Widget openIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedTable,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedTable,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}

class ColumnValueNode extends DataValueNode {
  DataType type;
  ColumnValueNode(String name, this.type) : super(name);

  @override
  Widget openIcons(BuildContext context) {
    return DataTypeIcon(type: type, size: kIconSizeSmall);
  }

  @override
  Widget closeIcons(BuildContext context) {
    return DataTypeIcon(type: type, size: kIconSizeSmall);
  }
}

class DataTree extends StatefulWidget {
  final TreeController<DataNode> controller;
  final ScrollController? scrollController;

  const DataTree({
    Key? key,
    required this.controller,
    this.scrollController,
  }) : super(key: key);

  @override
  State<DataTree> createState() => _DataTreeState();
}

class _DataTreeState extends State<DataTree> {
  @override
  Widget build(BuildContext context) {
    return TreeView<DataNode>(
      treeController: widget.controller,
      controller: widget.scrollController,
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
              indent: 10,
              thickness: 0.2,
              origin: 0.2,
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
