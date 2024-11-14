import 'package:client/core/connection/metadata.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

class SessionDrawer extends StatefulWidget {
  const SessionDrawer({Key? key}) : super(key: key);

  @override
  State<SessionDrawer> createState() => _SessionDrawerState();
}

class _SessionDrawerState extends State<SessionDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 600,
      shape: const Border(),
      elevation: 0,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                    height: 36,
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.menu))
                      ],
                    )),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: Consumer<SessionProvider>(
                        builder: (context, sessionProvider, _) {
                      if (sessionProvider.drawerPage == "tree") {
                        List<DataNode>? root = sessionProvider.getMetadataTree();
                        if (root == null) {
                          return const CircularProgressIndicator();
                        } else {
                          return DataTree(roots: root);
                        }
                      } else {
                        List<TableColumnMeta>? columns =
                            sessionProvider.getTableColumn();
                        if (columns == null) {
                          return const CircularProgressIndicator();
                        } else {
                          return SessionDrawerDetail(columns: columns);
                        }
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SessionDrawerDetail extends StatefulWidget {
  final List<TableColumnMeta> columns;

  const SessionDrawerDetail({Key? key, required this.columns})
      : super(key: key);

  @override
  State<SessionDrawerDetail> createState() => _SessionDrawerStateDetail();
}

class _SessionDrawerStateDetail extends State<SessionDrawerDetail> {
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
                'sqle',
                style: Theme.of(context).textTheme.titleMedium,
              )),
              BreadCrumbItem(
                  content: Text(
                'rules',
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
