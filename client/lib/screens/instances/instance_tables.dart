import 'package:client/models/instances.dart';
import 'package:client/screens/instances/instance_update.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/paginated_bar.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/l10n/app_localizations.dart';

class InstancesPage extends StatelessWidget {
  const InstancesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PageSkeleton(
      key: Key("instances"),
      child: InstanceTable(),
    );
  }
}

class InstanceTable extends ConsumerStatefulWidget {
  const InstanceTable({super.key});

  @override
  ConsumerState<InstanceTable> createState() => _InstanceTableState();
}

class _InstanceTableState extends ConsumerState<InstanceTable> {
  DataRow buildDataRow(InstanceModel instance) {
    return DataRow(cells: [
      DataCell(Row(
        children: [
          Image.asset(
            connectionMetaMap[instance.dbType]!.logoAssertPath,
            width: kIconSizeMedium,
            height: kIconSizeMedium,
          ),
          Padding(
            padding: const EdgeInsets.only(left: kSpacingSmall),
            child: Text(instance.connectValue.name),
          )
        ],
      )),
      DataCell(Text(instance.connectValue.desc)),
      DataCell(Text(instance.connectValue.host)),
      DataCell(Text("${instance.connectValue.port}")),
      DataCell(Text(instance.connectValue.user)),
      DataCell(Row(
        children: [
          RectangleIconButton.small(
            icon: Icons.edit,
            onPressed: () {
              updateInstanceController.tryUpdateInstance(instance);
              GoRouter.of(context).go('/instances/update');
            },
          ),
          RectangleIconButton.small(
            icon: Icons.delete,
            onPressed: () async {
              await ref
                  .read(instancesServicesProvider.notifier)
                  .deleteInstance(instance.id);

              ref.read(instancesNotifierProvider.notifier).refresh();
            },
          ),
          RectangleIconButton.small(
            icon: Icons.more_vert_outlined,
            onPressed: () {},
          )
        ],
      ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final column = [
      DataColumn(label: Text(AppLocalizations.of(context)!.db_instance_name)),
      DataColumn(label: Text(AppLocalizations.of(context)!.db_instance_desc)),
      DataColumn(label: Text(AppLocalizations.of(context)!.db_instance_host)),
      DataColumn(label: Text(AppLocalizations.of(context)!.db_instance_port)),
      DataColumn(label: Text(AppLocalizations.of(context)!.db_instance_user)),
      DataColumn(label: Text(AppLocalizations.of(context)!.db_instance_op))
    ];

    final model = ref.watch(instancesNotifierProvider);

    final searchTextController = TextEditingController(text: model.key);
    return BodyPageSkeleton(
      bottomSpaceSize: kSpacingSmall,
      header: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.db_instance,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: kIconSizeLarge,
                height: kIconSizeLarge,
                child: FloatingActionButton.small(
                  elevation: 2,
                  onPressed: () => GoRouter.of(context).go('/instances/add'),
                  child: const Icon(Icons.add),
                ),
              ),
              const SizedBox(width: kSpacingSmall),
              SearchBarTheme(
                data: const SearchBarThemeData(
                    elevation: WidgetStatePropertyAll(0),
                    constraints: BoxConstraints(
                      minHeight: kIconSizeLarge,
                      maxWidth: 200,
                    )),
                child: SearchBar(
                  controller: searchTextController,
                  onChanged: (value) {
                    ref.read(instancesNotifierProvider.notifier).changePage(
                        value,
                        pageNumber: model.currentPage,
                        pageSize: model.pageSize);
                  },
                  trailing: const [Icon(Icons.search)],
                ),
              ),
            ],
          ))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  checkboxHorizontalMargin: 0,
                  horizontalMargin: 0,
                  columnSpacing: 0,
                  dividerThickness: kDividerThickness,
                  showBottomBorder: true,
                  columns: column,
                  rows: model.instances.map((instance) {
                    return buildDataRow(instance);
                  }).toList(),
                  sortAscending: false,
                  showCheckboxColumn: true,
                ),
              ),
            ),
          ),
          TablePaginatedBar(
            count: model.count,
            pageSize: model.pageSize,
            pageNumber: model.currentPage,
            onChange: (pageNumber) {
              ref.read(instancesNotifierProvider.notifier).changePage(
                  searchTextController.text,
                  pageNumber: pageNumber,
                  pageSize: model.pageSize);
            },
          ),
        ],
      ),
    );
  }
}
