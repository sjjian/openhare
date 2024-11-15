import 'package:client/screens/sessions/session_metadata.dart';
import 'package:flutter/material.dart';

class SessionDrawer extends StatefulWidget {
  const SessionDrawer({Key? key}) : super(key: key);

  @override
  State<SessionDrawer> createState() => _SessionDrawerState();
}

class _SessionDrawerState extends State<SessionDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 600,
      shape: const Border(),
      elevation: 0,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                    height: 36,
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {}, icon: const Icon(Icons.menu))
                      ],
                    )),
                Expanded(
                  child: SessionMetadata(
                    controller: MetadataController(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
