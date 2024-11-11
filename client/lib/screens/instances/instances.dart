import 'package:client/screens/instances/instance_tables.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:flutter/material.dart';

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
