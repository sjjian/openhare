import 'package:client/core/connection/sql.dart';
import 'package:client/models/instances.dart';
import 'package:client/providers/instances.dart';
import 'package:client/providers/sessions.dart';
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
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      width: 300,
      child: Align(
        child: ListView(
          children: [
            for (var inst in instances.instancesModel)
              TextButton(
                  onPressed: () {
                    SessionProvider session =
                        Provider.of<SessionProvider>(context, listen: false);
                    session.setConn(SQLConnection(inst)); //todo: 统一inst和conn meta
                  },
                  child: Text(inst.name))
          ],
        ),
      ),
    );
  }
}
