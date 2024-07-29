import 'package:pluto_grid/pluto_grid.dart';

enum SQLExecuteState { executing, done, error }

class SQLResultModel {
  int id;
  SQLExecuteState state = SQLExecuteState.executing;
  String query;
  Exception? error;
  List<PlutoColumn>? columns;
  List<PlutoRow>? rows;
  BigInt? effectRows;
  Duration? executeTime;

  SQLResultModel(this.id, this.query);

  void setDone(columns, rows, effectRows, executeTime) {
    state = SQLExecuteState.done;
    this.columns = columns;
    this.rows = rows;
    this.effectRows = effectRows;
    this.executeTime = executeTime;
  }

  void setError(error) {
    state = SQLExecuteState.error;
    this.error = error;
  }
}
