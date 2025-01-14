import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:flutter/material.dart';

class SessionDrawerSqlResult extends StatelessWidget {
  final SessionDrawerController controller;

const SessionDrawerSqlResult({ Key? key, required this.controller }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Text(controller.sqlResult??"");
  }
}