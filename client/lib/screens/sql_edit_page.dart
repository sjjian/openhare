import 'package:client/screens/code_edit.dart';
import 'package:client/screens/instance_list.dart';
import 'package:flutter/material.dart';
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
      const SizedBox(width: 200, child: InstanceList()),
      const VerticalDivider(
        width: 10,
        thickness: 0.5,
        color: Colors.black,
      ),
      Expanded(
          child: Column(
        children: [
          const CodeEditor(),
          Container(
              height: 40,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Row(children: [
                Icon(Icons.play_arrow_rounded, size: 36, color: Colors.green)
              ])),
          const Divider(
            height: 10,
            thickness: 0.5,
            color: Colors.black,
          ),
          const Expanded(
            child: SqlResultTable(),
          ),
          SizedBox(height: 30)
        ],
      )),
      SizedBox(width: 5),
    ]);
    // return const SqlResultTable();
  }
}

class SqlResultTable extends StatefulWidget {
  const SqlResultTable({super.key});
  @override
  State<SqlResultTable> createState() => _SqlResultTableState();
}

class _SqlResultTableState extends State<SqlResultTable> {
  List<PlutoColumn> columns = [
    /// Text Column definition
    PlutoColumn(
      title: 'text column',
      field: 'text_field',
      type: PlutoColumnType.text(),
    ),

    /// Number Column definition
    PlutoColumn(
      title: 'number column',
      field: 'number_field',
      type: PlutoColumnType.number(),
    ),

    /// Select Column definition
    PlutoColumn(
      title: 'select column',
      field: 'select_field',
      type: PlutoColumnType.select(['item1', 'item2', 'item3']),
    ),

    /// Datetime Column definition
    PlutoColumn(
      title: 'date column',
      field: 'date_field',
      type: PlutoColumnType.date(),
    ),

    /// Time Column definition
    PlutoColumn(
      title: 'time column',
      field: 'time_field',
      type: PlutoColumnType.time(),
    ),
  ];

  List<PlutoRow> rows = [
    PlutoRow(
      cells: {
        'text_field': PlutoCell(
            value:
                'Text cell value1Text cell value1Text cell value1Text cell value1Text cell value1Text cell value1Text cell value1Text cell value1Text cell value1Text cell value1Text cell value1Text cell value1Text cell value1Text cell value1'),
        'number_field': PlutoCell(value: 2021),
        'select_field': PlutoCell(value: 'item1'),
        'date_field': PlutoCell(value: '2020-08-06'),
        'time_field': PlutoCell(value: '12:30'),
      },
    ),
    PlutoRow(
      cells: {
        'text_field': PlutoCell(value: 'Text cell value2'),
        'number_field': PlutoCell(value: 2021),
        'select_field': PlutoCell(value: 'item2'),
        'date_field': PlutoCell(value: '2020-08-07'),
        'time_field': PlutoCell(value: '18:45'),
      },
    ),
    PlutoRow(
      cells: {
        'text_field': PlutoCell(value: 'Text cell value3'),
        'number_field': PlutoCell(value: 2022),
        'select_field': PlutoCell(value: 'item3'),
        'date_field': PlutoCell(value: '2020-08-08'),
        'time_field': PlutoCell(value: '23:59'),
      },
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return PlutoGrid(
      columns: columns,
      rows: rows,
    );
  }
}
