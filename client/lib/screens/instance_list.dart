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
        shape: RoundedRectangleBorder(
          //<-- SEE HERE
          side: BorderSide(
            strokeAlign: BorderSide.strokeAlignOutside,
            // color: Colors.greenAccent,
          ),
        ),
        child: ListTile(
          titleAlignment: ListTileTitleAlignment.center,
          title:
              Expanded(child: Text("test1", overflow: TextOverflow.ellipsis)),
          subtitle: Expanded(
              child:
                  Text("10.186.62.16:3306", overflow: TextOverflow.ellipsis)),
          leading: Image.asset("assets/icons/mysql_icon.png"),
        ));
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
