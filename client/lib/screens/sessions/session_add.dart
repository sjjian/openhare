import 'package:client/screens/page_skeleton.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/screens/instances/instance_tables.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/paginated_bar.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddSession extends HookConsumerWidget {
  const AddSession({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(instancesNotifierProvider);
    final searchTextController = TextEditingController(text: model.key);

    return BodyPageSkeleton(
      header: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.recently_used_db_instance,
            style: Theme.of(context).textTheme.titleLarge,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                  width: 200,
                  child: Text(AppLocalizations.of(context)!.db_instance_name)),
              Container(
                  padding: const EdgeInsets.only(
                    left: 12,
                  ), // 与下面的TextButton的padding对齐
                  child:
                      Text(AppLocalizations.of(context)!.recently_used_schema))
            ],
          ),
          const SizedBox(height: kSpacingSmall),
          for (var inst in ref
              .read(instancesServicesProvider.notifier)
              .activeInstances()) // todo
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      Image.asset(
                        connectionMetaMap[inst.dbType]!.logoAssertPath,
                        height: 24,
                      ),
                      LinkButton(
                          onPressed: () {
                            ref
                                .read(sessionsServicesProvider.notifier)
                                .addSession(inst);
                          },
                          text: inst.connectValue.name),
                    ],
                  ),
                ),
                for (final schema in inst.activeSchemas.toList())
                  LinkButton(
                    text: schema,
                    onPressed: () {
                      ref
                          .read(sessionsServicesProvider.notifier)
                          .addSession(inst, schema: schema);
                    },
                  )
              ],
            ),
          const SizedBox(height: kSpacingMedium),
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.db_instance,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                            ref
                                .read(instancesNotifierProvider.notifier)
                                .changePage(value,
                                    pageNumber: model.currentPage,
                                    pageSize: model.pageSize);
                          },
                          trailing: const [Icon(Icons.search)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpacingSmall),
          const Divider(
            thickness: kDividerThickness,
            height: kDividerSize,
          ),
          const SizedBox(height: kSpacingMedium),
          Row(
            children: [
              SizedBox(
                  width: 200,
                  child: Text(AppLocalizations.of(context)!.db_instance_name)),
              Container(
                  width: 200,
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(AppLocalizations.of(context)!.db_instance_host)),
              Container(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(AppLocalizations.of(context)!.db_instance_desc)),
            ],
          ),
          const SizedBox(height: kSpacingSmall),
          for (var inst in model.instances) //todo
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      Image.asset(
                        connectionMetaMap[inst.dbType]!.logoAssertPath,
                        height: kIconSizeMedium,
                      ),
                      LinkButton(
                        text: inst.connectValue.name,
                        onPressed: () {
                          ref
                              .read(sessionsServicesProvider.notifier)
                              .addSession(inst);
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  width: 200,
                  child: Row(
                    children: [
                      Text(
                          "${inst.connectValue.host}:${inst.connectValue.port}",
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  width: 200,
                  child: Row(
                    children: [
                      Text(inst.connectValue.desc),
                    ],
                  ),
                ),
              ],
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
