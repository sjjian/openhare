import 'package:mysql_client/mysql_client.dart';

enum MetaType { schema, table }

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

  TableMeta(this.name);
}

class TableColumnMeta {
  String name;
  String type;
  String isNull;
  String? key;
  String? defaultValue;
  String? extra;

  TableColumnMeta({
    required this.name,
    required this.type,
    required this.isNull,
    this.key,
    this.defaultValue,
    this.extra,
  });

  TableColumnMeta.loadFromRow(ResultSetRow row)
      : name = row.colByName("Field")!,
        type = row.colByName("Type")!,
        isNull = row.colByName("Null")!,
        key = row.colByName("Key"),
        defaultValue = row.colByName("Default"),
        extra = row.colByName("Extra");

  static List<String> getDataTableColumn() {
    return ["Field", "Type", "Null", "Key", "Default", "Extra"];
  }
}
