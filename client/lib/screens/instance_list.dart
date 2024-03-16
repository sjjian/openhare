import 'package:flutter/material.dart';

class InstanceList extends StatefulWidget {
  const InstanceList({Key? key}) : super(key: key);

  @override
  _InstanceListState createState() => _InstanceListState();
}

class _InstanceListState extends State<InstanceList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(children: <Widget>[
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
        const InstanceInfo(),
      ]),
    );
  }
}

class InstanceInfo extends StatefulWidget {
  const InstanceInfo({Key? key}) : super(key: key);

  @override
  _InstanceInfoState createState() => _InstanceInfoState();
}

class _InstanceInfoState extends State<InstanceInfo> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      // width: 200,
      // height: 100,
      child: LayoutBuilder(builder: (context, contraints) {
        if (contraints.maxWidth < 40) {
          return Text("123");
        } else {
          return Text("10.186.62.16:3306");
        }
      }),
    );
  }
}
