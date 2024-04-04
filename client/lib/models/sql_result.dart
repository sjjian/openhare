import 'package:pluto_grid/pluto_grid.dart';

enum SQLExecuteState { executing, done, error }

class SQLResultModel {
  int id;
  SQLExecuteState state = SQLExecuteState.executing;
  String query;
  Exception? error;
  List<PlutoColumn>? columns;
  List<PlutoRow>? rows;

  SQLResultModel(this.id, this.query);

  void setDone(columns, rows) {
    state = SQLExecuteState.done;
    this.columns = columns;
    this.rows = rows;
  }

  void setError(error) {
    state = SQLExecuteState.error;
    this.error = error;
  }
}