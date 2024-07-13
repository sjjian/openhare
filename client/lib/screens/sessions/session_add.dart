import 'package:client/providers/instances.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddSession extends StatefulWidget {
  const AddSession({Key? key}) : super(key: key);

  @override
  State<AddSession> createState() => _AddSessionState();
}

class _AddSessionState extends State<AddSession> {
  @override
  Widget build(BuildContext context) {
    InstancesProvider instances = Provider.of<InstancesProvider>(context);
    return Container(
      child: Align(
        child: ListView(children: [
          for (var inst in instances.instancesModel)
            Text(inst.name)
        ],),
      ),
    );
  }
}
