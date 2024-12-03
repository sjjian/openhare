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
    SessionProvider sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);
    sessionProvider.loadMetadata();

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
        Widget body = const Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(),
          ),
        );
        if (widget.controller.page == "tree") {
          List<SchemaMeta>? meta = sessionProvider.getMetadata();
          if (meta != null) {
            body = DataTree(roots: buildMetadataTree(meta));
          }
        } else {
          TableMeta? tableMeta = sessionProvider.getTableMeta(
              widget.controller.currentSchema!,
              widget.controller.currentTable!);
          if (TableMeta.initialized(tableMeta)) {
            body = SessionMetadataDetail(
              tableMeta: tableMeta!,
              schema: widget.controller.currentSchema!,
              table: widget.controller.currentTable!,
              controller: widget.controller,
            );
          }
        }
        return Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
  final TableMeta tableMeta;
  final MetadataController controller;

  const SessionMetadataDetail(
      {Key? key,
      required this.schema,
      required this.table,
      required this.tableMeta,
      required this.controller})
      : super(key: key);

  @override
  State<SessionMetadataDetail> createState() => _SessionDrawerStateDetail();
}

class _SessionDrawerStateDetail extends State<SessionMetadataDetail> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      for (final column in widget.tableMeta.columns!)
        SessionMetadataColumn(
          column: column,
          keys: widget.tableMeta.getKeysByColumn(column.name),
        ),
    ]);
  }
}

class SessionMetadataColumn extends StatefulWidget {
  final TableColumnMeta column;
  final List<TableKeyMeta>? keys;

  const SessionMetadataColumn(
      {Key? key, required this.column, required this.keys})
      : super(key: key);

  @override
  State<SessionMetadataColumn> createState() => _SessionMetadataColumnState();
}

class _SessionMetadataColumnState extends State<SessionMetadataColumn> {
  bool isEnter = false;
  bool unfold = false;

  List<Widget> getTypeTags(TableColumnMeta column) {
    List<Widget> tags = List.empty(growable: true);
    tags.add(Chip(label: Text(widget.column.columnType)));
    if (widget.column.isNull == "YES") {
      tags.add(const Chip(label: Text("NOT NULL")));
    } else {
      tags.add(const Chip(label: Text("NULL")));
    }
    if (widget.column.key == "PRI") {
      tags.add(const Chip(label: Text("PK")));
    } else if (widget.column.key != "") {
      tags.add(Chip(label: Text(widget.column.key!)));
    }
    return tags;
  }

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
        onTap: () {
          setState(() {
            unfold = !unfold;
          });
        },
        child: Card(
          child: Column(
            children: [
              ListTile(
                leading: switch (widget.column.getDataType()) {
                  DataType.number => const Icon(
                      Icons.onetwothree,
                      color: Colors.teal,
                    ),
                  DataType.char => const Icon(
                      Icons.abc,
                      color: Colors.blueAccent,
                    ),
                  DataType.time => const Icon(
                      Icons.access_time,
                      color: Colors.deepPurple,
                    ),
                  DataType.blob => const Icon(
                      Icons.insert_drive_file_outlined,
                      color: Colors.black87,
                    ),
                  DataType.json => const Icon(
                      Icons.data_object,
                      color: Colors.orangeAccent,
                    ),
                  _ => const Icon(Icons.question_mark)
                },
                title: Row(
                  children: [
                    Text(widget.column.name),
                    const Expanded(child: Spacer()),
                    if (widget.column.key != "") const Icon(Icons.key)
                  ],
                ),
                trailing: unfold
                    ? Icon(Icons.unfold_less,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)
                    : Icon(Icons.unfold_more,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              if (unfold)
                Container(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SessionMetadataInfo(
                        name: "type",
                        child: Row(
                          children: [
                            for (final tag in getTypeTags(widget.column))
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: tag,
                              ),
                          ],
                        ),
                      ),
                      SessionMetadataInfo(
                          name: "default",
                          child: Text(widget.column.defaultValue ?? "null")),
                      if (widget.column.characterSetName != null)
                        SessionMetadataInfo(
                            name: "character set",
                            child: Text(
                                "${widget.column.characterSetName} | ${widget.column.collationName}")),
                      if (widget.column.extra != null &&
                          widget.column.extra!.isNotEmpty)
                        SessionMetadataInfo(
                            name: "extra", child: Text(widget.column.extra!)),
                      if (widget.column.comment != null &&
                          widget.column.comment!.isNotEmpty)
                        SessionMetadataInfo(
                            name: "comment",
                            child: Text(widget.column.comment!)),
                      if (widget.keys!.isNotEmpty)
                        SessionMetadataInfo(
                          name: "keys",
                          child: Column(
                            children: [
                              for (final key in widget.keys!)
                                Tooltip(
                                  message: key.columns.join(","),
                                  child: Text(key.name),
                                )
                            ],
                          ),
                        ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
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
