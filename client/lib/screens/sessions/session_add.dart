import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
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
  void addSession(BuildContext context, InstanceModel inst, {String? schema}) {
    SessionProvider sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);

    SessionListProvider sessionListProvider =
        Provider.of<SessionListProvider>(context, listen: false);

    if (sessionProvider.session == null) {
      SessionModel session = SessionModel();
      sessionListProvider.addSession(session);
      sessionProvider.setConn(inst, schema: schema);
      // 添加会话自动建立连接
      sessionListProvider.connect(session);
    } else {
      sessionProvider.setConn(inst, schema: schema);
      // 添加会话自动建立连接
      sessionProvider.connect();
    }
    sessionListProvider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    InstancesProvider instancesProvider =
        Provider.of<InstancesProvider>(context);
    return Expanded(
        child: Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(40, 20, 0, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "数据源列表",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
              for (var inst in instancesProvider.instances())
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          addSession(context, inst);
                        },
                        child: Text(inst.name)),
                    const VerticalDivider(
                      width: 5,
                    ),
                    for (final schema in inst.activeSchemas.toList())
                      TextButton(
                        onPressed: () {
                          addSession(context, inst, schema: schema);
                        },
                        child: Text(schema),
                      )
                  ],
                )
            ],
          ),
        ],
      ),
    ));
  }
}
