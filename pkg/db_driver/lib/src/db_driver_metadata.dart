import 'dart:convert';

import 'package:db_driver/db_driver.dart';

enum MetaType {
  instance,
  database,
  schema,
  table,
  column;

  @override
  String toString() => name;
}

class MetaDataNode {
  MetaType type;
  String value;
  /// `null` 或 `[]` 表示无子节点。
  List<MetaDataNode>? items;
  final Map<MetaDataPropType, MetaDataProp> props = {};
  MetaDataNode(this.type, this.value, {this.items});

  void visitor(bool Function(MetaDataNode node, MetaDataNode? parent) callback,
      [MetaDataNode? parent]) {
    bool shouldContinue = callback(this, parent);
    if (!shouldContinue) return; // 如果回调返回 false，则终止当前分支

    if (items != null) {
      for (var item in items!) {
        item.visitor(callback, this);
      }
    }
  }

  MetaDataNode withProp(MetaDataPropType name, Object value) {
    props[name] = MetaDataProp(name, value);
    return this;
  }

  T? getProp<T>(MetaDataPropType name) {
    return props[name]?.value as T?;
  }

  List<MetaDataNode> getChildren(MetaType type) {
    if (items == null) {
      return [];
    }
    return [
      for (final node in items!)
        if (node.type == type) node,
    ];
  }

  MetaDataNode? getNode(MetaType type, String value) {
    MetaDataNode? node;
    visitor((n, parent) {
      if (n.type == type && n.value == value) {
        node = n;
        return false;
      }
      return true;
    });
    return node;
  }

  MetaDataNode? getNodeByDatabaseRef(DatabaseRef ref) {
    switch (ref) {
      case SchemaMode(:final database, :final schema):
        return getNode(MetaType.database, database)
            ?.getNode(MetaType.schema, schema);
      case DatabaseMode():
        return getNode(MetaType.database, ref.databaseName());
    }
  }

  /// 按路径定位表节点。
  MetaDataNode? findRelation({
    required String database,
    String? schema,
    required String name,
    required MetaType type,
  }) {
    final db = getNode(MetaType.database, database);
    if (db == null) return null;
    final MetaDataNode? container;
    if (schema != null && schema.isNotEmpty) {
      container = db.getNode(MetaType.schema, schema);
    } else {
      container = db;
    }
    return container?.getNode(type, name);
  }

  @override
  String toString() {
    return jsonEncode({
      "type": type.toString(),
      "value": value,
      "props": props.map(
        (key, value) => MapEntry(key.name, value.value.toString()),
      ),
      "children": items?.map((e) => e.toString()).toList(),
    });
  }
}

enum MetaDataPropType {
  dataType,
  /// 原始 SQL 类型名（展示用，如 varchar / integer）
  dataTypeName,
  indexType;

  @override
  String toString() => name;
}

class MetaDataProp {
  MetaDataPropType name;
  Object value;

  MetaDataProp(this.name, this.value);
}

MetaDataNode? getNodeByDatabaseRef(List<MetaDataNode> nodes, DatabaseRef ref) {
  return MetaDataNode(MetaType.instance, "", items: nodes)
      .getNodeByDatabaseRef(ref);
}
