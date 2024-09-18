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
  @override
  Widget build(BuildContext context) {
    InstancesProvider instancesProvider =
        Provider.of<InstancesProvider>(context);
    return Expanded(
        child: Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "数据源列表",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              for (var inst in instancesProvider.st.instances!)
                TextButton(
                    onPressed: () {
                      SessionProvider sessionProvider =
                          Provider.of<SessionProvider>(context, listen: false);

                      SessionListProvider sessionListProvider =
                          Provider.of<SessionListProvider>(context,
                              listen: false);

                      if (sessionProvider.session == null) {
                        SessionModel session = SessionModel();
                        sessionListProvider.addSession(session);
                        sessionProvider.setConn(inst);
                        // 添加会话自动建立连接
                        sessionListProvider.connect(session);
                      } else {
                        sessionProvider.setConn(inst);
                        // todo: 添加会话自动建立连接
                        // sessionListProvider.connect(session);
                      }
                      sessionListProvider.refresh();
                    },
                    child: Text(inst.name))
            ],
          ),
        ],
      ),
    ));
  }
}
