import 'package:client/providers/sessions.dart';
import 'package:client/screens/sessions/session_metadata.dart';
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
    SessionProvider sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);
    return Drawer(
      // width: 400,
      shape: const Border(),
      elevation: 0,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: sessionProvider.initialized()
                      ? SessionMetadata(
                          controller: sessionProvider
                              .session!.metadataController, //todo
                        )
                      : const Spacer(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
