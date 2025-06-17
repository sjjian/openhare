import 'package:client/models/instance_metadata.dart';
import 'package:client/models/sessions.dart';
import 'package:client/services/instances/metadata.dart';
import 'package:client/services/sessions.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_drawer_metadata.g.dart';

@Riverpod(keepAlive: true)
class SessionMetadataNotifier extends _$SessionMetadataNotifier {
  @override
  InstanceMetadataModel? build() {
    SessionModel? sessionIdModel = ref.watch(selectedSessionIdServicesProvider);
    if (sessionIdModel == null) {
      return null;
    }
    return ref
        .watch(instanceMetadataServicesProvider(sessionIdModel.instanceId!));
  }
}

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
      icon: HugeIcons.strokeRoundedDatabase,
      color: Theme.of(context).iconTheme.color ?? Colors.black87,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedDatabase,
      color: Theme.of(context).iconTheme.color ?? Colors.black87,
    );
  }

  @override
  Widget builder(context) {
    return Text(
      children.isNotEmpty ? "$name  [${_children.length}]" : name,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class SchemaNode extends RootNode {
  SchemaNode(String name) : super(name: name);

  @override
  Widget openIcons(BuildContext context) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedDatabase,
      color: Theme.of(context).iconTheme.color ?? Colors.black87,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedDatabase,
      color: Theme.of(context).iconTheme.color ?? Colors.black87,
    );
  }
}

class TableNode extends RootNode {
  TableNode(String name) : super(name: name);

  @override
  Widget openIcons(BuildContext context) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedTable,
      color: Theme.of(context).iconTheme.color ?? Colors.black87,
    );
  }

  @override
  Widget closeIcons(BuildContext context) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedTable,
      color: Theme.of(context).iconTheme.color ?? Colors.black87,
    );
  }
}

class ColumnNode extends RootNode {
  DataType type;
  ColumnNode(String name, this.type) : super(name: name);

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

  DataNode buildDataNode(MetaDataNode node) {
    return switch (node.type) {
      MetaType.database => SchemaNode(node.value),
      MetaType.table => TableNode(node.value),
      MetaType.column =>
        ColumnNode(node.value, node.getProp(MetaDataPropType.dataType)),
      _ => SchemaNode(node.value)
    };
  }

  DataNode buildMetadataTree(DataNode parent, List<MetaDataNode>? nodes) {
    if (nodes == null) {
      return parent;
    }
    for (var node in nodes) {
      final dataNode = buildDataNode(node);
      parent.children.add(dataNode);
      if (node.items != null && node.items!.isNotEmpty) {
        buildMetadataTree(dataNode, node.items!);
      }
    }
    return parent;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(sessionMetadataNotifierProvider);

    Widget body = const Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(),
      ),
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
      items = [model.metadata!];
    }

    final metadataController = TreeController<DataNode>(
      roots: buildMetadataTree(root, items).children,
      childrenProvider: (DataNode node) => node.children,
    );
    body = DataTree(controller: metadataController);

    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SessionMetadataTitle(),
          // const Divider(
          //   endIndent: 10,
          // ),
          Expanded(child: body),
        ]);
  }
}

class SessionMetadataInfo extends StatelessWidget {
  final String name;
  final Widget? child;
  const SessionMetadataInfo({Key? key, required this.name, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              name,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            )),
        Container(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
          child: child ?? const Text("null"),
        )
      ],
    );
  }
}
