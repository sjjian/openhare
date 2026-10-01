import 'package:client/l10n/app_localizations.dart';
import 'package:client/widgets/const.dart';
import 'package:collection/collection.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:client/widgets/tooltip.dart';

abstract class DataNode {
  List<DataNode> get children;
  Widget builder(BuildContext context, bool isOpen);
  Widget closeIcons(BuildContext context);
  Widget openIcons(BuildContext context);
  void visitor(bool Function(DataNode node) callback);

  /// 节点或其子孙是否匹配搜索关键字（值节点按名称；分类夹看子孙）。
  bool matchesFilter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (this is DataValueNode) {
      if ((this as DataValueNode).name.toLowerCase().contains(q)) return true;
    }
    for (final child in children) {
      if (child.matchesFilter(q)) return true;
    }
    return false;
  }
}

DataNode buildDataNode(MetaDataNode node) {
  return switch (node.type) {
    MetaType.database => DatabaseNode(),
    MetaType.table => TableNode(),
    MetaType.schema => SchemaNode(),
    MetaType.instance => InstanceNode(),
    // 列不再挂到树上，只在详情区展示。
    MetaType.column => throw StateError('column is not a tree node'),
  };
}

DataNode buildDataValueNode(
  MetaDataNode node, {
  String? database,
  String? schema,
}) {
  // 列不再挂到树上，只在详情区展示。
  return switch (node.type) {
    MetaType.database => DatabaseValueNode(
        node.value,
        metaType: MetaType.database,
      ),
    MetaType.schema => SchemaValueNode(
        node.value,
        metaType: MetaType.schema,
        database: database,
      ),
    MetaType.table => TableValueNode(
        node.value,
        metaType: MetaType.table,
        database: database,
        schema: schema,
      ),
    MetaType.instance => DataValueNode(
        node.value,
        metaType: MetaType.instance,
      ),
    MetaType.column => throw StateError('column is not a tree node'),
  };
}

DataNode buildMetadataTree(
  DataNode parent,
  List<MetaDataNode>? nodes, {
  String? database,
  String? schema,
}) {
  if (nodes == null) {
    return parent;
  }
  final visible = [
    for (final n in nodes)
      if (n.type != MetaType.column) n,
  ];
  final groupedNodes = visible.groupListsBy((node) => node.type);
  for (final type in groupedNodes.keys) {
    final dataNode = buildDataNode(groupedNodes[type]!.first);
    parent.children.add(dataNode);

    for (final node in groupedNodes[type]!) {
      final nextDatabase = node.type == MetaType.database ? node.value : database;
      final nextSchema = node.type == MetaType.schema ? node.value : schema;

      final dataValueNode = buildDataValueNode(
        node,
        database: nextDatabase,
        schema: nextSchema,
      );
      dataNode.children.add(dataValueNode);
      // 表下的列不进树；其它容器（库/schema）继续递归
      if (node.type == MetaType.table) {
        continue;
      }
      if (node.items != null && node.items!.isNotEmpty) {
        buildMetadataTree(
          dataValueNode,
          node.items!,
          database: nextDatabase,
          schema: nextSchema,
        );
      }
    }
  }
  return parent;
}

/// 值节点不依赖父路径；分类夹带上父 key，避免不同库下两个「表」撞车。
String metadataNodeKey(DataNode node, [String parentKey = '']) {
  if (node is DataValueNode) {
    return 'v:${node.metaType.name}:${node.database ?? ''}:${node.schema ?? ''}:${node.name}';
  }
  return 'f:${node.runtimeType}:$parentKey';
}

/// 树展开状态；按节点 identity 记录，不依赖 fancy tree。
class DataTreeController extends ChangeNotifier {
  DataTreeController({
    required this.roots,
    List<DataNode> Function(DataNode node)? childrenProvider,
  }) : childrenProvider = childrenProvider ?? ((node) => node.children);

  List<DataNode> roots;
  final List<DataNode> Function(DataNode node) childrenProvider;
  final Set<DataNode> _expanded = {};

  List<DataNode> childrenOf(DataNode node) => childrenProvider(node);

  bool isExpanded(DataNode node) => _expanded.contains(node);

  void setExpansionState(DataNode node, bool expanded) {
    if (expanded) {
      _expanded.add(node);
    } else {
      _expanded.remove(node);
    }
  }

  void toggleExpansion(DataNode node) {
    setExpansionState(node, !isExpanded(node));
    notifyListeners();
  }

  void rebuild() => notifyListeners();

  void _walk(void Function(DataNode node, String key) visit) {
    void walk(DataNode node, String parentKey) {
      final key = metadataNodeKey(node, parentKey);
      visit(node, key);
      for (final child in childrenOf(node)) {
        walk(child, key);
      }
    }

    for (final root in roots) {
      walk(root, '');
    }
  }

  Set<String> expansionKeys() {
    final keys = <String>{};
    _walk((node, key) {
      if (_expanded.contains(node)) keys.add(key);
    });
    return keys;
  }

  void restoreExpansion(Set<String> keys) {
    _expanded.clear();
    _walk((node, key) {
      if (keys.contains(key)) _expanded.add(node);
    });
  }

  DataNode? findByKey(String key) {
    DataNode? found;
    _walk((node, nodeKey) {
      if (found == null && nodeKey == key) found = node;
    });
    return found;
  }
}

/// 展开所有匹配过滤条件的节点路径。
void expandFilterMatches(DataTreeController controller, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return;

  void walk(DataNode node, List<DataNode> ancestors) {
    final path = [...ancestors, node];
    if (node is DataValueNode && node.name.toLowerCase().contains(q)) {
      for (final a in ancestors) {
        controller.setExpansionState(a, true);
      }
    }
    for (final child in node.children) {
      walk(child, path);
    }
  }

  for (final root in controller.roots) {
    walk(root, const []);
  }
  controller.rebuild();
}

String dataTypeLabel(MetaDataNode column) {
  final raw = column.getProp<String>(MetaDataPropType.dataTypeName);
  if (raw != null && raw.isNotEmpty) return raw;
  final t = column.getProp<DataType>(MetaDataPropType.dataType);
  return t?.name ?? 'unknown';
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
      color: Theme.of(context).colorScheme.tertiary, // todo: 需要描述为什么用这个颜色
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

  @override
  bool matchesFilter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    for (final child in children) {
      if (child.matchesFilter(q)) return true;
    }
    return false;
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
    return TooltipText(
      text: children.isNotEmpty ? "$name  [${_children.length}]" : name,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class DatabaseNode extends FolderNode {
  DatabaseNode() : super();

  @override
  String _name(BuildContext context) => AppLocalizations.of(context)!.metadata_tree_database;
}

class TableNode extends FolderNode {
  TableNode() : super();

  @override
  String _name(BuildContext context) => AppLocalizations.of(context)!.metadata_tree_table;
}

class SchemaNode extends FolderNode {
  SchemaNode() : super();

  @override
  String _name(BuildContext context) => AppLocalizations.of(context)!.metadata_tree_schema;
}

class InstanceNode extends FolderNode {
  InstanceNode() : super();

  @override
  String _name(BuildContext context) => AppLocalizations.of(context)!.metadata_tree_instance;
}

class DataValueNode extends RootNode {
  final String name;
  final MetaType metaType;
  final String? database;
  final String? schema;

  DataValueNode(
    this.name, {
    required this.metaType,
    this.database,
    this.schema,
  });

  String get simpleName => name;

  String get qualifiedName {
    switch (metaType) {
      case MetaType.table:
        if (schema != null && schema!.isNotEmpty) return '$schema.$name';
        if (database != null && database!.isNotEmpty) return '$database.$name';
        return name;
      case MetaType.column:
        return name;
      case MetaType.schema:
        if (database != null && database!.isNotEmpty) return '$database.$name';
        return name;
      case MetaType.database:
      case MetaType.instance:
        return name;
    }
  }

  @override
  List<DataNode> get children {
    return _children;
  }

  @override
  bool matchesFilter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (name.toLowerCase().contains(q)) return true;
    for (final child in children) {
      if (child.matchesFilter(q)) return true;
    }
    return false;
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
    return TooltipText(
      text: name,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: isOpen ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class DatabaseValueNode extends DataValueNode {
  DatabaseValueNode(
    super.name, {
    super.metaType = MetaType.database,
    super.database,
    super.schema,
  });

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
      color: Colors.orangeAccent[100]!,
    );
  }
}

class SchemaValueNode extends DataValueNode {
  SchemaValueNode(
    super.name, {
    super.metaType = MetaType.schema,
    super.database,
    super.schema,
  });

  @override
  Widget openIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedFolder02,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeSmall,
      icon: HugeIcons.strokeRoundedFolder01,
      color: Colors.orangeAccent[100]!,
    );
  }
}

class TableValueNode extends DataValueNode {
  TableValueNode(
    super.name, {
    super.metaType = MetaType.table,
    super.database,
    super.schema,
  });

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
      color: Colors.green[200]!,
    );
  }
}

class DataTree extends StatefulWidget {
  final DataTreeController controller;
  final ScrollController? scrollController;
  final DataNode? selectedNode;
  final String filterQuery;
  final ValueChanged<DataNode>? onSelected;

  const DataTree({
    super.key,
    required this.controller,
    this.scrollController,
    this.selectedNode,
    this.filterQuery = '',
    this.onSelected,
  });

  @override
  State<DataTree> createState() => _DataTreeState();
}

class _DataTreeState extends State<DataTree> {
  static const double _rowHeight = 25;
  static const double _indentPerLevel = 4;

  DataTreeController? _filteredController;

  @override
  void initState() {
    super.initState();
    _syncFilterController();
  }

  @override
  void didUpdateWidget(covariant DataTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.filterQuery != widget.filterQuery) {
      _syncFilterController();
    }
  }

  @override
  void dispose() {
    _filteredController?.dispose();
    super.dispose();
  }

  void _syncFilterController() {
    _filteredController?.dispose();
    _filteredController = null;
    final q = widget.filterQuery.trim();
    if (q.isEmpty) return;
    _filteredController = DataTreeController(
      roots: widget.controller.roots.where((n) => n.matchesFilter(q)).toList(growable: false),
      childrenProvider: (DataNode node) =>
          node.children.where((c) => c.matchesFilter(q)).toList(growable: false),
    );
    expandFilterMatches(_filteredController!, q);
  }

  void _handleToggleExpand(DataTreeController controller, DataNode node) {
    controller.toggleExpansion(node);
  }

  Widget _rowFor(DataTreeController controller, DataNode node, int depth, {bool pinned = false}) {
    final children = controller.childrenOf(node);
    return _TreeRow(
      key: ValueKey(node),
      node: node,
      depth: depth,
      indentPerLevel: _indentPerLevel,
      height: _rowHeight,
      selected: identical(widget.selectedNode, node),
      expanded: controller.isExpanded(node),
      hasChildren: children.isNotEmpty,
      pinned: pinned,
      onToggleExpand: () => _handleToggleExpand(controller, node),
      onSelect: () {
        if (children.isNotEmpty) {
          _handleToggleExpand(controller, node);
        }
        widget.onSelected?.call(node);
      },
    );
  }

  List<Widget> _sliversFor(DataTreeController controller, List<DataNode> nodes, int depth) {
    final slivers = <Widget>[];
    final leaves = <DataNode>[];

    void flushLeaves() {
      if (leaves.isEmpty) return;
      final batch = List<DataNode>.of(leaves);
      leaves.clear();
      slivers.add(
        SliverFixedExtentList(
          itemExtent: _rowHeight,
          delegate: SliverChildBuilderDelegate(
            (context, index) => _rowFor(controller, batch[index], depth),
            childCount: batch.length,
            addAutomaticKeepAlives: false,
          ),
        ),
      );
    }

    for (final node in nodes) {
      final children = controller.childrenOf(node);
      if (controller.isExpanded(node) && children.isNotEmpty) {
        flushLeaves();
        slivers.add(
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTreeHeaderDelegate(
                  height: _rowHeight,
                  child: _rowFor(controller, node, depth, pinned: true),
                ),
              ),
              ..._sliversFor(controller, children, depth + 1),
            ],
          ),
        );
      } else {
        leaves.add(node);
      }
    }
    flushLeaves();
    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _filteredController ?? widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return CustomScrollView(
          controller: widget.scrollController,
          slivers: _sliversFor(controller, controller.roots, 0),
        );
      },
    );
  }
}

class _StickyTreeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _StickyTreeHeaderDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      elevation: overlapsContent ? 0.5 : 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTreeHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}

class _TreeRow extends StatefulWidget {
  final DataNode node;
  final int depth;
  final double indentPerLevel;
  final double height;
  final bool selected;
  final bool expanded;
  final bool hasChildren;
  final bool pinned;
  final VoidCallback onToggleExpand;
  final VoidCallback onSelect;

  const _TreeRow({
    super.key,
    required this.node,
    required this.depth,
    required this.indentPerLevel,
    required this.height,
    required this.selected,
    required this.expanded,
    required this.hasChildren,
    this.pinned = false,
    required this.onToggleExpand,
    required this.onSelect,
  });

  @override
  State<_TreeRow> createState() => _TreeRowState();
}

class _TreeRowState extends State<_TreeRow> {
  bool isEnter = false;

  bool get isOpen => widget.hasChildren && widget.expanded;

  bool get _showChevron => widget.hasChildren;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color? bg;
    if (widget.selected) {
      bg = colorScheme.primaryContainer;
    } else if (isEnter) {
      bg = colorScheme.surfaceContainer; // meta data detail 鼠标移入的颜色.
    } else if (widget.pinned) {
      bg = colorScheme.surfaceContainerLowest;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
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
      child: Material(
        color: bg ?? Colors.transparent,
        child: InkWell(
          onTap: widget.onSelect,
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Row(
              children: [
                SizedBox(width: widget.depth * widget.indentPerLevel),
                if (_showChevron)
                  InkWell(
                    onTap: widget.onToggleExpand,
                    child: SizedBox(
                      width: kIconSizeSmall,
                      height: widget.height,
                      child: widget.expanded
                          ? const Icon(Icons.expand_more, size: kIconSizeSmall)
                          : const Icon(Icons.chevron_right, size: kIconSizeSmall),
                    ),
                  )
                else
                  const SizedBox(width: kIconSizeSmall),
                (isOpen)
                    ? widget.node.openIcons(context)
                    : widget.node.closeIcons(context),
                const SizedBox(width: kSpacingTiny),
                Expanded(
                  child: widget.node.builder(context, isOpen || widget.selected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
