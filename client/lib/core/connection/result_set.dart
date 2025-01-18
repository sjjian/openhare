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
    return getValue(column)?.asString();
  }

  ResultSetValue? getValue(String column) {
    for (final c in cells) {
      if (c.column.name == column) return c.value;
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

  ResultSetValue? getValue(String colunm, int line) {
    return rows[line].getValue(colunm);
  }
}
