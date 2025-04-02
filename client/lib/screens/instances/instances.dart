import 'package:client/providers/instances.dart';
import 'package:client/screens/instances/instance_add.dart';
import 'package:client/screens/instances/instance_update.dart';
import 'package:client/screens/instances/instance_tables.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InstancesPage extends StatelessWidget {
  const InstancesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    InstancesProvider instancesProvider =
        Provider.of<InstancesProvider>(context);

    return PageSkeleton(
      key: const Key("instances"),
      topBar: (instancesProvider.page != "instances")
          ? Row(
              children: [
                IconButton(
                    onPressed: () => {instancesProvider.goPage("instances")},
                    icon: const Icon(Icons.arrow_back))
              ],
            )
          : null,
      child: switch (instancesProvider.page) {
        "instances" => const InstanceTable(),
        "update_instance" =>
          UpdateInstancePage(instance: instancesProvider.willUpdatedInstance!),
        _ => const AddInstancePage(),
      },
    );
  }
}
