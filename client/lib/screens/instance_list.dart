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
          titleAlignment: ListTileTitleAlignment.center,
          title: const Text("test1", overflow: TextOverflow.ellipsis),
          subtitle:
              const Text("10.186.62.16:3306", overflow: TextOverflow.ellipsis),
          leading: Image.asset("assets/icons/mysql_icon.png"),
        ));

    // return Card(
    //   color: const Color.fromARGB(255, 240, 239, 239),
    //     shape: RoundedRectangleBorder(
    //       //<-- SEE HERE
    //       side: BorderSide(
    //         strokeAlign: BorderSide.strokeAlignOutside,
    //         color: Colors.white,
    //         // color: Colors.greenAccent,
    //       ),
    //     ),
    //     child: ListTile(
    //       titleAlignment: ListTileTitleAlignment.center,
    //       title:
    //           Expanded(child: Text("test1", overflow: TextOverflow.ellipsis)),
    //       subtitle: Expanded(
    //           child:
    //               Text("10.186.62.16:3306", overflow: TextOverflow.ellipsis)),
    //       leading: Image.asset("assets/icons/mysql_icon.png"),
    //     ));
    // return Card(
    //   // clipBehavior: Clip.none,
    //   // color: Colors.white,
    //   // borderOnForeground: false,
    //   // shadowColor: Colors.white,
    //   // width: 200,
    //   // height: 100,
    //   child: LayoutBuilder(builder: (context, contraints) {
    //     if (contraints.maxWidth < 40) {
    //       return Image.asset(
    //         "assets/icons/mysql_icon.png",
    //         width: 40,
    //         height: 40,
    //       );
    //       // return Text("123");
    //     } else {
    //       return ListTile(
    //         title: Text("test1"),
    //         subtitle:Text("10.186.62.16:3306"),
    //         leading: Image.asset("assets/icons/mysql_icon.png"),
    //       );
    //       // return Expanded(child: Row(
    //       //   children: [
    //       //     Image.asset(
    //       //       "assets/icons/mysql_icon.png",
    //       //       width: 40,
    //       //       height: 40,
    //       //     ),

    //       //     Column(children: [Text("test1"),Text("10.186.62.16:3306") ],)

    //       //   ],
    //       // ));
    //       // return Text("test1 : 10.186.62.16:3306");
    //     }
    //   }),
    // );
  }
}
