import 'dart:math';

import 'package:db_driver/src/db_driver_metadata.dart';

enum DataType {
  number,
  char,
  time,
  blob,
  json,
  dataSet,
  ;
}

abstract class BaseQueryColumn {
  String get name;
  DataType dataType();
}

abstract class BaseQueryValue {
  String? getString();
  List<int> getBytes();

  String? getSummary() {
    String? value = getString();
    if (value == null) {
      return null;
    }
    return value
        .substring(0, min(value.length, 50))
        .replaceAll('\r\n', '\n')
        .replaceAll("\r", "\n")
        .replaceAll("\n", " ");
  }
}

class QueryResultRow {
  List<BaseQueryColumn> columns;
  Map<String, int> index;
  List<BaseQueryValue> values;

  QueryResultRow(this.columns, this.values)
      : index = {for (var i = 0; i < columns.length; i++) columns[i].name: i};

  BaseQueryValue? getValue(String column) {
    int? colIndex = index[column];
    if (colIndex == null || colIndex >= values.length) return null;
    return values[colIndex];
  }

  BaseQueryColumn? getColumn(String column) {
    int? colIndex = index[column];
    if (colIndex == null || colIndex >= values.length) return null;
    return columns[colIndex];
  }

  String? getString(String column) {
    final v = getValue(column);
    if (v == null) {
      return null;
    }
    return v.getString();
  }
}

class BaseQueryResult {
  String queryId;
  List<BaseQueryColumn> columns;
  List<QueryResultRow> rows;
  BigInt affectedRows;

  BaseQueryResult(this.queryId, this.columns, this.rows, this.affectedRows);
}

abstract class BaseQueryStreamItem {
  const BaseQueryStreamItem();
}

class QueryStreamItemHeader extends BaseQueryStreamItem {
  final List<BaseQueryColumn> columns;
  final BigInt affectedRows;

  const QueryStreamItemHeader({
    required this.columns,
    required this.affectedRows,
  });
}

class QueryStreamItemRow extends BaseQueryStreamItem {
  final QueryResultRow row;

  const QueryStreamItemRow({required this.row});
}

abstract class BaseConnection {
  void Function(String)? onSchemaChangedCallback;

  BaseConnection();

  Future<void> ping();
  Future<BaseQueryResult> query(String sql, {int limit = 100});
  Stream<BaseQueryStreamItem> queryStream(String sql, {int limit = 100});
  Future<void> killQuery();
  Future<void> close();
  Future<List<MetaDataNode>> metadata();
  Future<List<String>> schemas();
  Future<String?> getCurrentSchema();
  Future<void> setCurrentSchema(String schema);

  void listen(
      {Function()? onCloseCallback,
      Function(String)? onSchemaChangedCallback}) {
    this.onSchemaChangedCallback = onSchemaChangedCallback;
  }

  void onSchemaChanged(String schema) => onSchemaChangedCallback?.call(schema);
}
