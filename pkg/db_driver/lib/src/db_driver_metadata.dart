enum MetaType { instance, database, schema, table, column }

class MetaDataNode {
  MetaType type;
  String value;
  List<MetaDataNode>? items;
  List<MetaDataProp>? props;
  MetaDataNode(this.type, this.value, {this.items, this.props});

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
}

class MetaDataProp {
  String name;
  String value;

  MetaDataProp(this.name, this.value);
}

class MetaDataTree {}
