import 'package:client/models/connection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class SqlResultTable extends StatefulWidget {
  final SQLResultModel? result;

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
    if (widget.result == null) {
      return Container(
          alignment: Alignment.topLeft,
          color: Colors.white,
          child: const Text('no data'));
    }
    if (widget.result!.state == SQLExecuteState.done) {
      return PlutoGrid(
        key: ValueKey(widget.result!.id),
        configuration: const PlutoGridConfiguration(
          localeText: PlutoGridLocaleText.china(),
          style: PlutoGridStyleConfig(
              rowHeight: 30,
              columnHeight: 36,
              gridBorderColor: Colors.white,
              enableGridBorderShadow: true),
        ),
        columns: widget.result!.columns!,
        rows: widget.result!.rows!,
      );
    } else if (widget.result!.state == SQLExecuteState.error) {
      return Container(
          alignment: Alignment.topLeft,
          color: Colors.white,
          child: Text('${widget.result!.error}'));
    } else {
      return Container(
          alignment: Alignment.topLeft,
          color: Colors.white,
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
