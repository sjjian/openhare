import 'package:client/core/connection/metadata.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

class SessionDrawerMetadata extends StatelessWidget {
  final SessionDrawerController controller;

  const SessionDrawerMetadata({Key? key, required this.controller})
      : super(key: key);

  // @override
  List<DataNode> buildMetadataTree(List<SchemaMeta> metadata) {
    List<DataNode> root = List<DataNode>.empty(growable: true);
    for (var schema in metadata) {
      DataNode schemaNode = DataNode(
        value: schema.name,
        type: "schema",
        builder: (context, node) {
          return Text(
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
                  controller.openTable(schema.name, table.name);
                },
                child: Text(
                  node.value,
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
    return Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
      Widget body = const Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(),
        ),
      );

      List<SchemaMeta>? meta = sessionProvider.getMetadata();
      if (meta != null) {
        body = DataTree(roots: buildMetadataTree(meta));
      }

      return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SessionMetadataTitle(controller: controller),
            const Divider(
              endIndent: 10,
            ),
            Expanded(child: body),
          ]);
    });
  }
}

class SessionDrawerMetadataDetail extends StatelessWidget {
  final SessionDrawerController controller;

  const SessionDrawerMetadataDetail({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
      Widget body = const Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(),
        ),
      );
      TableMeta? tableMeta = sessionProvider.getTableMeta(
          controller.currentSchema!, controller.currentTable!);
      if (TableMeta.initialized(tableMeta)) {
        body = ListView(children: [
          for (final column in tableMeta!.columns!)
            SessionMetadataColumn(
              column: column,
              keys: tableMeta.getKeysByColumn(column.name),
            ),
        ]);
      }
      return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SessionMetadataTitle(controller: controller),
            const Divider(
              endIndent: 10,
            ),
            Expanded(child: body),
          ]);
    });
  }
}

class SessionMetadataTitle extends StatefulWidget {
  final SessionDrawerController controller;
  const SessionMetadataTitle({Key? key, required this.controller})
      : super(key: key);

  @override
  State<SessionMetadataTitle> createState() => _SessionMetadataTitleState();
}

class _SessionMetadataTitleState extends State<SessionMetadataTitle> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth - 40 - 24 - 24;
          return BreadCrumb(
            items: <BreadCrumbItem>[
              BreadCrumbItem(
                  content: IconButton(
                      onPressed: () {
                        widget.controller.goToTree();
                      },
                      icon: const Icon(Icons.home))),
              if (widget.controller.page != DrawerPage.metadataTree)
                BreadCrumbItem(
                    content: Container(
                  constraints: BoxConstraints(maxWidth: width / 2),
                  child: Text(
                    widget.controller.currentSchema!,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
              if (widget.controller.page != DrawerPage.metadataTree)
                BreadCrumbItem(
                    content: Expanded(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: width / 2),
                    child: Text(
                      widget.controller.currentTable!,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )),
            ],
            divider: const Icon(Icons.chevron_right),
          );
        },
      ),
    );
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
    tags.add(Chip(
        label: Tooltip(
            message: widget.column.columnType,
            child: Text(widget.column.getColumnType()))));
    if (widget.column.isNull == "YES") {
      tags.add(const Chip(label: Text("NOT NULL")));
    } else {
      tags.add(const Chip(label: Text("NULL")));
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
                leading: DataTypeIcon(type: widget.column.dataType),
                title: Row(
                  children: [
                    Expanded(
                        child: Text(
                      widget.column.name,
                      overflow: TextOverflow.ellipsis,
                    )),
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
