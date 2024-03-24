import 'package:client/models/connection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class SqlResultTable extends StatefulWidget {
  final SQLResultModel result;

  const SqlResultTable({super.key, required this.result});

  @override
  State<SqlResultTable> createState() => _SqlResultTableState();
}

class _SqlResultTableState extends State<SqlResultTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result.state == SQLResultState.done) {
      return PlutoGrid(
        columns: widget.result.columns!,
        rows: widget.result.rows!,
      );
    } else if (widget.result.state == SQLResultState.error) {
      return Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Text('${widget.result.error}'));
    } else {
      return Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: const Center(
            child: SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(),
            ),
          ));
    }
  }
}
