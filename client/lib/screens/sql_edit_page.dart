import 'package:client/models/connection.dart';
import 'package:client/screens/code_edit.dart';
import 'package:client/screens/instance_list.dart';
import 'package:client/widgets/split_view.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:pluto_grid/pluto_grid.dart';

class SQLEditPage extends StatefulWidget {
  const SQLEditPage({super.key});

  @override
  State<SQLEditPage> createState() => _SQLEditPageState();
}

class _SQLEditPageState extends State<SQLEditPage> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SplitView(
          controller: MultiSplitViewController(areas: [Area(size: 200)]),
          children: const [
            Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                InstanceList()
              ],
            ),
            Column(
              children: [
                SizedBox(height: 30),
                SplitView(axis: Axis.vertical, children: [
                  CodeEditor(),
                  SqlResultTable(),
                ]),
                SizedBox(height: 30)
              ],
            ),
          ]),
      const SizedBox(width: 5),
    ]);
  }
}

class SqlResultTable extends StatefulWidget {
  const SqlResultTable({super.key});
  @override
  State<SqlResultTable> createState() => _SqlResultTableState();
}

class _SqlResultTableState extends State<SqlResultTable> {
  late Future<SQLResultModel> result;

  @override
  void initState() {
    super.initState();
    result = ConnectionModel().query("select * from sqle.rules");
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contraints) {
      return FutureBuilder<SQLResultModel>(
          future: result,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return PlutoGrid(
                columns: snapshot.data!.columns,
                rows: snapshot.data!.rows,
              );
            } else if (snapshot.hasError) {
              return Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Text('${snapshot.error}'));
            }

            return Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey)),
                child: const Center(
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(),
                  ),
                ));
          });
    });
  }
}
