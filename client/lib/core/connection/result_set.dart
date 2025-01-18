enum ValueType {
  number,
  bit,
  str,
  time,
  json,
}

abstract class ResultSetValue {
  ValueType type();
  String? asString();
  List<int> asByte();
  String? summary();
}

class ResultSetCell {
  ResultSetColumn column;
  ResultSetValue value;

  ResultSetCell(this.column, this.value);
}

class ResultSetRow {
  List<ResultSetCell> cells;

  ResultSetRow(this.cells);

  String? getString(String column) {
    for (final c in cells) {
      if (c.column.name == column) return c.value.asString();
    }
    return null;
  }
}

class ResultSetColumn {
  String name;
  ValueType type;
  ResultSetColumn(this.name, this.type);
}

class ResultSet {
  List<ResultSetColumn> columns;
  List<ResultSetRow> rows;
  int? affectedRows;

  ResultSet(this.columns, this.rows, this.affectedRows);

  String? getValue(String colunm, int line) {
    return rows[line].getString(colunm);
  }
}
