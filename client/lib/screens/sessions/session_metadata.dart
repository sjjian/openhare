import 'package:client/core/connection/metadata.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

class MetadataController extends ChangeNotifier {
  String page = "tree";
  String? currentSchema;
  String? currentTable;

  MetadataController();

  void goToTree() {
    page = "tree";
    notifyListeners();
  }

  void openTable(String schema, String table) {
    page = "table";
    currentSchema = schema;
    currentTable = table;
    notifyListeners();
  }
}

class SessionMetadata extends StatefulWidget {
  final MetadataController controller;

  const SessionMetadata({Key? key, required this.controller}) : super(key: key);

  @override
  State<SessionMetadata> createState() => _SessionMetadataState();
}

class _SessionMetadataState extends State<SessionMetadata> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  List<DataNode> buildMetadataTree(List<SchemaMeta> metadata) {
    List<DataNode> root = List<DataNode>.empty(growable: true);
    for (var schema in metadata) {
      DataNode schemaNode = DataNode(
        value: schema.name,
        type: "schema",
        builder: (context, node) {
          return Text(
            selectionColor: Theme.of(context).colorScheme.primary,
            node.children.isNotEmpty
                ? "${node.value}  [${node.children.length}]"
                : node.value,
            overflow: TextOverflow.ellipsis,
          );
        },
      );
      root.add(schemaNode);
      for (var table in schema.tables) {
        schemaNode.addChildren(
          DataNode(
            value: table.name,
            type: "table",
            builder: (context, node) {
              return InkWell(
                onTap: () {
                  SessionProvider sessionProvider =
                      Provider.of<SessionProvider>(context, listen: false);
                  sessionProvider.loadTableMeta(schema.name, table.name);
                  widget.controller.openTable(schema.name, table.name);
                },
                child: Text(
                  node.value,
                  selectionColor: Theme.of(context).colorScheme.primary,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        );
      }
    }
    return root;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        if (widget.controller.page == "tree") {
          List<SchemaMeta>? meta = sessionProvider.getMetadata();
          if (meta == null) {
            return const CircularProgressIndicator();
          } else {
            return DataTree(roots: buildMetadataTree(meta));
          }
        } else {
          List<TableColumnMeta>? columns = sessionProvider.getTableMeta(
              widget.controller.currentSchema!,
              widget.controller.currentTable!);
          if (columns == null) {
            return const CircularProgressIndicator();
          } else {
            return SessionMetadataDetail(
              columns: columns,
              schema: widget.controller.currentSchema!,
              table: widget.controller.currentTable!,
            );
          }
        }
      }),
    );
  }
}

class SessionMetadataDetail extends StatefulWidget {
  final String schema;
  final String table;
  final List<TableColumnMeta> columns;

  const SessionMetadataDetail(
      {Key? key,
      required this.schema,
      required this.table,
      required this.columns})
      : super(key: key);

  @override
  State<SessionMetadataDetail> createState() => _SessionDrawerStateDetail();
}

class _SessionDrawerStateDetail extends State<SessionMetadataDetail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BreadCrumb(
            items: <BreadCrumbItem>[
              BreadCrumbItem(
                  content: Text(
                widget.schema,
                style: Theme.of(context).textTheme.titleMedium,
              )),
              BreadCrumbItem(
                  content: Text(
                widget.table,
                style: Theme.of(context).textTheme.titleMedium,
              )),
              BreadCrumbItem(
                  content: Text(
                '列信息',
                style: Theme.of(context).textTheme.titleMedium,
              )),
            ],
            divider: const Icon(Icons.chevron_right),
          ),
          const Divider(
            endIndent: 10,
          ),
          DataTable(columns: [
            for (final column in TableColumnMeta.getDataTableColumn())
              DataColumn(label: Text(column)),
          ], rows: [
            for (final column in widget.columns)
              DataRow(cells: [
                DataCell(Text(column.name)),
                DataCell(Text(column.type)),
                DataCell(Text(column.isNull)),
                DataCell(Text(column.key ?? "")),
                DataCell(Text(column.defaultValue ?? "")),
                DataCell(Text(column.extra ?? "")),
              ]),
          ]),
        ],
      ),
    );
  }
}
