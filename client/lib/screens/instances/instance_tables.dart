import 'package:client/models/instances.dart';
import 'package:client/screens/instances/instance_update.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/paginated_bar.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/l10n/app_localizations.dart';

part 'instance_tables.g.dart';

@Riverpod(keepAlive: true)
class InstancesNotifier extends _$InstancesNotifier {
  @override
  PaginationInstanceListModel build() {
    return ref
        .read(instancesServicesProvider.notifier)
        .instances("", pageNumber: 1, pageSize: 10);
  }

  void changePage(String key, {int? pageNumber = 1, int? pageSize = 10}) {
    state = ref
        .read(instancesServicesProvider.notifier)
        .instances(key, pageNumber: pageNumber, pageSize: pageSize);
  }

  void refresh() {
    state = ref.read(instancesServicesProvider.notifier).instances(state.key,
        pageNumber: state.currentPage, pageSize: state.pageSize);
  }
}

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
          Image.asset(connectionMetaMap[instance.dbType]!.logoAssertPath),
          Padding(
            padding: const EdgeInsets.only(left: 20),
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
          IconButton(
            onPressed: () {
              updateInstanceController.tryUpdateInstance(instance);
              GoRouter.of(context).go('/instances/update');
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              await ref
                  .read(instancesServicesProvider.notifier)
                  .deleteInstance(instance.id);

              ref.read(instancesNotifierProvider.notifier).refresh();
            },
            icon: const Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_outlined),
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
