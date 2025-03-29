enum MetaType { instance, database, schema, table, column }

class MetaDataNode {
  MetaType type;
  String value;
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

  MetaDataNode withProp(MetaDataPropType name, Object value){
    props[name] = MetaDataProp(name, value);
    return this;
  }

  T? getProp<T>(MetaDataPropType name) {
    return props[name]?.value as T?;
  }
}

enum MetaDataPropType { dataType, indexType }

class MetaDataProp {
  MetaDataPropType name;
  Object value;

  MetaDataProp(this.name, this.value);
}

