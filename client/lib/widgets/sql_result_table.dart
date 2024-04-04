import 'package:client/models/sql_result.dart';
import 'package:client/providers/sessions.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class SqlResultTable extends StatefulWidget {
  const SqlResultTable({super.key});

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
    return Consumer<SessionProvider>(builder: (context, sessionProvider, _) {
      final result = sessionProvider.getCurrentSQLResult();
      if (result == null) {
        return Container(
            alignment: Alignment.topLeft,
            color: Colors.white,
            child: const Text('no data'));
      }
      if (result.state == SQLExecuteState.done) {
        return PlutoGrid(
          key: ValueKey(result.id),
          configuration: const PlutoGridConfiguration(
            localeText: PlutoGridLocaleText.china(),
            style: PlutoGridStyleConfig(
                rowHeight: 30,
                columnHeight: 36,
                gridBorderColor: Colors.white,
                enableGridBorderShadow: true),
          ),
          columns: result.columns!,
          rows: result.rows!,
        );
      } else if (result.state == SQLExecuteState.error) {
        return Container(
            alignment: Alignment.topLeft,
            color: Colors.white,
            child: Text('${result.error}'));
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
    });
  }
}
