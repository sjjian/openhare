import 'package:flutter/material.dart';

class InstanceList extends StatefulWidget {
  const InstanceList({Key? key}) : super(key: key);

  @override
  _InstanceListState createState() => _InstanceListState();
}

class _InstanceListState extends State<InstanceList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView(children: const <Widget>[
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
      InstanceInfo(),
    ]));
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
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.2), //边框颜色
            width: 1, //边框宽度
          ), // 边色与边宽度
          color: Colors.white, // 底色
          boxShadow: [
            BoxShadow(
              blurRadius: 1, //阴影范围
              spreadRadius: 0.1, //阴影浓度
              color: Colors.grey.withOpacity(0.2), //阴影颜色
            ),
          ],
          // borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          titleAlignment: ListTileTitleAlignment.center,
          title: const Text("test1", overflow: TextOverflow.ellipsis),
          subtitle:
              const Text("10.186.62.16:3306", overflow: TextOverflow.ellipsis),
          leading: Image.asset("assets/icons/mysql_icon.png"),
          trailing: Icon(Icons.more_vert_outlined),
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
        ));
  }
}
