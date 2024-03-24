import 'package:client/models/connection.dart';
import 'package:client/screens/code_edit.dart';
import 'package:client/screens/instance_list.dart';
import 'package:client/widgets/split_view.dart';
import 'package:client/widgets/sql_result_table.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

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
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                InstanceList()
              ],
            ),
            ChangeNotifierProvider(
                create: (_) => SessionModel(),
                child: const Column(
                  children: [
                    SizedBox(height: 30),
                    SplitView(axis: Axis.vertical, children: [
                      CodeEditor(),
                      SqlResultTables(),
                    ]),
                    SizedBox(height: 30)
                  ],
                ))
          ]),
      const SizedBox(width: 5),
    ]);
  }
}

class SqlResultTables extends StatefulWidget {
  const SqlResultTables({Key? key}) : super(key: key);

  @override
  _SqlResultTablesState createState() => _SqlResultTablesState();
}

class _SqlResultTablesState extends State<SqlResultTables> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SessionModel>(builder: (context, sessionModel, _) {
      final result = sessionModel.result;
      if (result == null) {
        return Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: const Text('no data'));
      } else {
        return SqlResultTable(result: result);
      }
    });
  }
}

// class SqlResultTable extends StatefulWidget {
//   const SqlResultTable({super.key});
//   @override
//   State<SqlResultTable> createState() => _SqlResultTableState();
// }

// class _SqlResultTableState extends State<SqlResultTable> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SessionModel>(
//       builder: (context, sessionModel, _) {
//         final result = sessionModel.result;
//         return SqlResultTable(result)
//         if (result?.state == SQLResultState.done) {
//           return PlutoGrid(
//             columns: result!.columns!,
//             rows: result.rows!,
//           );
//         } else if (result?.state == SQLResultState.error) {
//           return Container(
//               decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
//               child: Text('${result!.error}'));
//         } else {
//           return Container(
//               decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
//               child: const Center(
//                 child: SizedBox(
//                   height: 40,
//                   width: 40,
//                   child: CircularProgressIndicator(),
//                 ),
//               ));
//         }
//       },
//     );
//   }
// }
