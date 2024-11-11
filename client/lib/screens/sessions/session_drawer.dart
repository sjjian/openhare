import 'package:flutter/material.dart';

class SessionDrawer extends StatefulWidget {
  const SessionDrawer({ Key? key }) : super(key: key);

  @override
  State<SessionDrawer> createState() => _SessionDrawerState();
}

class _SessionDrawerState extends State<SessionDrawer> {
  @override
  Widget build(BuildContext context) {
    return const Drawer(
      shape:Border(),
      elevation: 0,
      child:  Align(alignment: Alignment.center,child: Text("test")),
    );
  }
}