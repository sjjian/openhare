import 'package:mysql_client/mysql_client.dart';

enum MetaType { schema, table }

enum DataType {
  number,
  char,
  time,
  blob,
  json,
  dataSet,
}

class SchemaMeta {
  String name;
  List<TableMeta> tables = List.empty(growable: true);

  SchemaMeta(this.name);

  void addTable(TableMeta table) {
    tables.add(table);
  }
}

class TableMeta {
  String name;
  List<TableColumnMeta>? columns;
  List<TableKeyMeta>? keys;

  TableMeta(this.name);

  List<TableKeyMeta>? getKeysByColumn(String tartgetColumn) {
    if (keys == null) {
      return null;
    }
    List<TableKeyMeta> includeKeys = List.empty(growable: true);
    for (final key in keys!) {
      for (final column in key.columns) {
        if (tartgetColumn == column) {
          includeKeys.add(key);
        }
      }
    }
    return includeKeys;
  }

  static bool initialized(TableMeta? tableMeta) {
    return tableMeta != null &&
        tableMeta.columns != null &&
        tableMeta.keys != null;
  }
}

class TableColumnMeta {
  String name;
  DataType dataType; // varchar
  String columnType; // varchar(255)
  String isNull;
  String? key;
  String? defaultValue;
  String? characterSetName;
  String? collationName;
  String? comment;
  String? extra;

  TableColumnMeta({
    required this.name,
    required this.dataType,
    required this.columnType,
    this.defaultValue,
    required this.isNull,
    this.key,
    this.characterSetName,
    this.collationName,
    this.comment,
    this.extra,
  });
  /*
  COLUMN_NAME, COLUMN_DEFAULT, IS_NULLABLE, DATA_TYPE, CHARACTER_SET_NAME, COLLATION_NAME, COLUMN_TYPE, COLUMN_KEY, COLUMN_COMMENT, EXTRA
  */

  TableColumnMeta.loadFromRow(ResultSetRow row)
      : name = row.colByName("COLUMN_NAME")!,
        dataType = TableColumnMeta.getDataType(row.colByName("DATA_TYPE")!),
        columnType = row.colByName("COLUMN_TYPE")!,
        isNull = row.colByName("IS_NULLABLE")!,
        defaultValue = row.colByName("COLUMN_DEFAULT"),
        key = row.colByName("COLUMN_KEY"),
        comment = row.colByName("COLUMN_COMMENT"),
        characterSetName = row.colByName("CHARACTER_SET_NAME"),
        collationName = row.colByName("COLLATION_NAME"),
        extra = row.colByName("Extra");

  static List<String> getDataTableColumn() {
    return ["COLUMN_NAME", "DATA_TYPE", "Null", "Key", "Default", "Extra"];
  }

  static DataType getDataType(String dataType) {
    return switch (dataType) {
      "int" ||
      "bigint" ||
      "smallint" ||
      "tinyint" ||
      "decimal" ||
      "double" ||
      "float" =>
        DataType.number,
      "char" || "varchar" => DataType.char,
      "datetime" || "time" || "timestamp" => DataType.time,
      "text" ||
      "blob" ||
      "longblob" ||
      "longtext" ||
      "mediumblob" ||
      "mediumtext" =>
        DataType.blob,
      "json" => DataType.json,
      "set" || "enum" => DataType.dataSet,
      _ => DataType.blob,
    };
  }

  String getColumnType() {
    return switch (dataType) {
      DataType.dataSet => columnType.split("(").first,
      _ => columnType
    };
  }
}

class TableKeyMeta {
  String name;
  List<String> columns;

  TableKeyMeta(this.name, this.columns);

  TableKeyMeta.loadFromRow(ResultSetRow row)
      : name = row.colByName("INDEX_NAME")!,
        columns = row.colByName("COLUMNS")!.split(";");
}
