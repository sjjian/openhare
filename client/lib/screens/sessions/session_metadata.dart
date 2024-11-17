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
      width: 600,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        Widget body = const SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(),
        );
        if (widget.controller.page == "tree") {
          List<SchemaMeta>? meta = sessionProvider.getMetadata();
          if (meta != null) {
            body = DataTree(roots: buildMetadataTree(meta));
          }
        } else {
          List<TableColumnMeta>? columns = sessionProvider.getTableMeta(
              widget.controller.currentSchema!,
              widget.controller.currentTable!);
          if (columns != null) {
            body = SessionMetadataDetail(
              columns: columns,
              schema: widget.controller.currentSchema!,
              table: widget.controller.currentTable!,
              controller: widget.controller,
            );
          }
        }
        return Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SessionMetadataTitle(controller: widget.controller),
                  const Divider(
                    endIndent: 10,
                  ),
                  Expanded(child: body),
                ]),
          ),
        );
      }),
    );
  }
}

class SessionMetadataTitle extends StatelessWidget {
  final MetadataController controller;
  const SessionMetadataTitle({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33,
      child: Row(
        children: [
          BreadCrumb(
            items: <BreadCrumbItem>[
              BreadCrumbItem(
                  content: IconButton(
                      onPressed: () {
                        controller.goToTree();
                      },
                      icon: const Icon(Icons.home))),
              if (controller.page != "tree")
                BreadCrumbItem(
                    content: Text(
                  controller.currentSchema!,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                )),
              if (controller.page != "tree")
                BreadCrumbItem(
                    content: Text(
                  controller.currentTable!,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                )),
            ],
            divider: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class SessionMetadataDetail extends StatefulWidget {
  final String schema;
  final String table;
  final List<TableColumnMeta> columns;
  final MetadataController controller;

  const SessionMetadataDetail(
      {Key? key,
      required this.schema,
      required this.table,
      required this.columns,
      required this.controller})
      : super(key: key);

  @override
  State<SessionMetadataDetail> createState() => _SessionDrawerStateDetail();
}

class _SessionDrawerStateDetail extends State<SessionMetadataDetail> {
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(columns: [
          for (final column
              in TableColumnMeta.getDataTableColumn().sublist(0, 2))
            DataColumn(label: Text(column)),
        ], rows: [
          for (final column in widget.columns)
            DataRow(cells: [
              DataCell(Text(column.name)),
              DataCell(Text(column.type)),
              // DataCell(Text(column.isNull)),
              // DataCell(Text(column.key ?? "")),
              // DataCell(Text(column.defaultValue ?? "")),
              // DataCell(Text(column.extra ?? "")),
            ]),
        ]),
      ),
    );
  }
}
