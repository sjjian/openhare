enum MetaType {instance, database, schema, table, column }

class MetaDataNode {
  MetaType type;
  String value;
  List<MetaDataNode>? items;
  List<MetaDataProp>? props;
  MetaDataNode(this.type, this.value, {this.items, this.props});
}

class MetaDataProp {
  String name;
  String value;

  MetaDataProp(this.name, this.value);
}

class MetaDataTree {}
