import 'package:client/providers/sessions.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionDrawer extends StatefulWidget {
  const SessionDrawer({Key? key}) : super(key: key);

  @override
  State<SessionDrawer> createState() => _SessionDrawerState();
}

class _SessionDrawerState extends State<SessionDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 400,
      shape: const Border(),
      elevation: 0,
      child: Column(
        children: [
          Container(
              height: 36,
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.menu))
                ],
              )),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              child: Consumer<SessionProvider>(
                  builder: (context, sessionProvider, _) {
                List<DataNode>? root = sessionProvider.getMetadata();
                if (root == null) {
                  return const CircularProgressIndicator();
                } else {
                  return DataTree(roots: root);
                  // return SessionDrawerDetail();
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class SessionDrawerDetail extends StatefulWidget {
  const SessionDrawerDetail({Key? key}) : super(key: key);

  @override
  State<SessionDrawerDetail> createState() => _SessionDrawerStateDetail();
}

class _SessionDrawerStateDetail extends State<SessionDrawerDetail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("/sqle/rules", style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.start,),
          ListTile(
            title: Text("test"),
          ),
          ListTile(
            title: Text("test"),
          ),
          ListTile(
            title: Text("test"),
          ),
        ],
      ),
    );
  }
}
