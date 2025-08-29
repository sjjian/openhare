import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/instances.dart';
import 'package:client/services/instances/metadata.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:collection/collection.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/widgets/loading.dart';

class RootNode implements DataNode {
  final String name;

  final List<DataNode> _children = List.empty(growable: true);

  RootNode({this.name = ""});

  @override
  List<DataNode> get children {
    return _children;
  }

  @override
  Widget openIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeTiny,
      icon: HugeIcons.strokeRoundedFolder02,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeTiny,
      icon: HugeIcons.strokeRoundedFolder01,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }

  @override
  Widget builder(context, isOpen) {
    return Text(
      children.isNotEmpty ? "$name  [${_children.length}]" : name,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }
}

class DataValueNode extends RootNode {
  DataValueNode(String name) : super(name: name);

  @override
  Widget openIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeTiny,
      icon: HugeIcons.strokeRoundedTable,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeTiny,
      icon: HugeIcons.strokeRoundedTable,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  @override
  Widget builder(context, isOpen) {
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
      size: kIconSizeTiny,
      icon: HugeIcons.strokeRoundedDatabase,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeTiny,
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
      size: kIconSizeTiny,
      icon: HugeIcons.strokeRoundedTable,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      size: kIconSizeTiny,
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
    return DataTypeIcon(type: type);
  }

  @override
  Widget closeIcons(BuildContext context) {
    return DataTypeIcon(type: type);
  }
}

class SessionDrawerMetadata extends ConsumerWidget {
  const SessionDrawerMetadata({Key? key}) : super(key: key);

  DataNode buildDataNode(BuildContext context, MetaDataNode node) {
    return switch (node.type) {
      MetaType.database => RootNode(name: AppLocalizations.of(context)!.metadata_tree_database),
      MetaType.table => RootNode(name: AppLocalizations.of(context)!.metadata_tree_table),
      MetaType.column => RootNode(name: AppLocalizations.of(context)!.metadata_tree_column),
      MetaType.schema => RootNode(name: AppLocalizations.of(context)!.metadata_tree_schema),
      MetaType.instance => RootNode(name: AppLocalizations.of(context)!.metadata_tree_instance),
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

  DataNode buildMetadataTree(BuildContext context, DataNode parent, List<MetaDataNode>? nodes) {
    if (nodes == null) {
      return parent;
    }
    final groupedNodes = nodes.groupListsBy((node) => node.type);
    for (final type in groupedNodes.keys) {
      final dataNode = buildDataNode(context, groupedNodes[type]!.first);
      parent.children.add(dataNode);

      for (final node in groupedNodes[type]!) {
        final dataValueNode = buildDataValueNode(node);
        dataNode.children.add(dataValueNode);
        if (node.items != null && node.items!.isNotEmpty) {
          buildMetadataTree(context, dataValueNode, node.items!);
        }
      }
    }
    return parent;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    InstanceMetadataModel? model = ref.watch(sessionMetadataNotifierProvider);
    Widget body = const Align(
      alignment: Alignment.center,
      child: Loading.large(),
    );

    RootNode root = RootNode();
    List<MetaDataNode>? items;
    if (model == null) {
      items = [];
    } else if (model.metadata == null) {
      ref
          .read(instanceMetadataServicesProvider(model.instanceId).notifier)
          .refreshMetadata();
      items = [];
    } else {
      items = model.metadata;
    }

    final metadataController = TreeController<DataNode>(
      roots: buildMetadataTree(context, root, items).children,
      childrenProvider: (DataNode node) => node.children,
    );
    body = DataTree(controller: metadataController);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: body),
      ],
    );
  }
}
