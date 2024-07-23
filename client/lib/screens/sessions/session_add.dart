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
    InstancesProvider instancesProvider =
        Provider.of<InstancesProvider>(context);
    return Container(
      padding: const EdgeInsets.all(10),
      width: 1000,
      child: Row(
        children: [
          const Expanded(child: Spacer()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "最近使用",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                  width: 900,
                  // height: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      for (var inst in instancesProvider.st.instances!)
                        TextButton(
                            onPressed: () {
                              SessionProvider session =
                                  Provider.of<SessionProvider>(context,
                                      listen: false);
                              session.setConn(
                                  SQLConnection(inst)); //todo: 统一inst和conn meta
                            },
                            child: Text(inst.name))
                    ],
                  )),
              const SizedBox(
                height: 20,
              ),
              Text(
                "数据源列表",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                  width: 900,
                  // height: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      for (var inst in instancesProvider.st.instances!)
                        TextButton(
                            onPressed: () {
                              SessionProvider session =
                                  Provider.of<SessionProvider>(context,
                                      listen: false);
                              session.setConn(
                                  SQLConnection(inst)); //todo: 统一inst和conn meta
                            },
                            child: Text(inst.name))
                    ],
                  )
                  )
            ],
          ),
          const Expanded(child: Spacer()),
        ],
      ),
      // child: ,
    );
  }
}
