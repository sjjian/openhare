import 'dart:convert';

import 'package:db_driver/db_driver.dart';
import 'package:test/test.dart';

void main() {
  group('visitor', () {
    test('先序遍历根与子孙并传入正确的 parent', () {
      final col = MetaDataNode(MetaType.column, 'id');
      final tbl = MetaDataNode(MetaType.table, 't1', items: [col]);
      final root = MetaDataNode(MetaType.instance, 'inst', items: [tbl]);

      final pairs = <List<MetaDataNode?>>[];
      root.visitor((node, parent) {
        pairs.add([node, parent]);
        return true;
      });

      expect(pairs.length, 3);
      expect(pairs[0][0], root);
      expect(pairs[0][1], isNull);
      expect(pairs[1][0], tbl);
      expect(pairs[1][1], root);
      expect(pairs[2][0], col);
      expect(pairs[2][1], tbl);
    });

    test('回调返回 false 时不再深入当前节点的子树', () {
      final leaf = MetaDataNode(MetaType.column, 'c');
      final inner = MetaDataNode(MetaType.table, 'skip_me', items: [leaf]);
      final root = MetaDataNode(MetaType.instance, 'i', items: [inner]);

      final visited = <String>[];
      root.visitor((node, parent) {
        visited.add(node.value);
        if (node.value == 'skip_me') {
          return false;
        }
        return true;
      });

      expect(visited, ['i', 'skip_me']);
      expect(visited, isNot(contains('c')));
    });
  });

  group('withProp', () {
    test('链式写入并按键读取', () {
      final n = MetaDataNode(MetaType.column, 'x')
          .withProp(MetaDataPropType.dataType, 'int')
          .withProp(MetaDataPropType.indexType, 'btree');

      expect(n.getProp<String>(MetaDataPropType.dataType), 'int');
      expect(n.getProp<String>(MetaDataPropType.indexType), 'btree');
    });

    test('getProp 不存在的键返回 null', () {
      final n = MetaDataNode(MetaType.column, 'x');
      expect(n.getProp<Object>(MetaDataPropType.dataType), isNull);
    });
  });

  group('getChildren', () {
    test('items 为 null 时返回空列表', () {
      final n = MetaDataNode(MetaType.instance, 'x');
      expect(n.getChildren(MetaType.table), isEmpty);
    });

    test('返回当前节点下 type 匹配的直接子节点（含其 items，不展开）', () {
      final tblItems = [
        MetaDataNode(MetaType.column, 'a'),
        MetaDataNode(MetaType.column, 'b'),
      ];
      final tableNode =
          MetaDataNode(MetaType.table, 't_container', items: tblItems);
      final dbChild =
          MetaDataNode(MetaType.database, 'db1', items: [tableNode]);

      final tables = dbChild.getChildren(MetaType.table);
      expect(tables, [same(tableNode)]);
      expect(tables.single.items, tblItems);
    });

    test('多个同类型直接子节点按顺序全部返回', () {
      final t1 = MetaDataNode(MetaType.table, 't1');
      final t2 = MetaDataNode(MetaType.table, 't2');
      final dbChild = MetaDataNode(MetaType.database, 'db1', items: [t1, t2]);

      expect(dbChild.getChildren(MetaType.table), [same(t1), same(t2)]);
    });

    test('类型不匹配的直接子项不产生条目', () {
      final root = MetaDataNode(MetaType.instance, 'i', items: [
        MetaDataNode(MetaType.database, 'd', items: []),
      ]);
      expect(root.getChildren(MetaType.table), isEmpty);
    });
  });

  group('getNode', () {
    test('按 type + value 找到节点', () {
      final target = MetaDataNode(MetaType.schema, 'public');
      final tree = MetaDataNode(MetaType.instance, '', items: [
        MetaDataNode(MetaType.database, 'db', items: [target]),
      ]);

      expect(tree.getNode(MetaType.schema, 'public'), same(target));
    });

    test('无匹配返回 null', () {
      final tree = MetaDataNode(MetaType.instance, '', items: [
        MetaDataNode(MetaType.database, 'db', items: []),
      ]);
      expect(tree.getNode(MetaType.schema, 'nope'), isNull);
    });

    test('同一父节点下多个子节点时按 value 命中其中之一', () {
      final want = MetaDataNode(MetaType.schema, 'public');
      final tree = MetaDataNode(MetaType.instance, '', items: [
        MetaDataNode(MetaType.database, 'db', items: [
          MetaDataNode(MetaType.schema, 'pg_catalog'),
          want,
          MetaDataNode(MetaType.schema, 'information_schema'),
        ]),
      ]);

      expect(tree.getNode(MetaType.schema, 'public'), same(want));
    });

    test('instance 下多个 database 兄弟时各自可命中', () {
      final dbA = MetaDataNode(MetaType.database, 'db_a');
      final dbB = MetaDataNode(MetaType.database, 'db_b', items: [
        MetaDataNode(MetaType.schema, 's1'),
      ]);
      final tree = MetaDataNode(MetaType.instance, '', items: [dbA, dbB]);

      expect(tree.getNode(MetaType.database, 'db_a'), same(dbA));
      expect(tree.getNode(MetaType.database, 'db_b'), same(dbB));
      expect(tree.getNode(MetaType.schema, 's1'), same(dbB.items!.single));
    });
  });

  group('getNodeByDatabaseRef', () {
    test('DatabaseMode：实例方法定位 database 节点', () {
      final db = MetaDataNode(MetaType.database, 'mydb');
      final tree = MetaDataNode(MetaType.instance, '', items: [db]);

      expect(
        tree.getNodeByDatabaseRef(DatabaseMode(database: 'mydb')),
        same(db),
      );
    });

    test('SchemaMode：实例方法 database 下定位 schema 节点', () {
      final sch = MetaDataNode(MetaType.schema, 'pub');
      final db = MetaDataNode(MetaType.database, 'mydb', items: [sch]);
      final tree = MetaDataNode(MetaType.instance, '', items: [db]);

      expect(
        tree.getNodeByDatabaseRef(
          SchemaMode(database: 'mydb', schema: 'pub'),
        ),
        same(sch),
      );
    });

    test('路径缺失返回 null', () {
      final db = MetaDataNode(MetaType.database, 'mydb', items: []);
      final tree = MetaDataNode(MetaType.instance, '', items: [db]);

      expect(
        tree.getNodeByDatabaseRef(
          SchemaMode(database: 'other', schema: 'x'),
        ),
        isNull,
      );
      expect(
        tree.getNodeByDatabaseRef(
          SchemaMode(database: 'mydb', schema: 'missing'),
        ),
        isNull,
      );
    });

    test('顶层 List 重载：在多个节点中解析 DatabaseRef', () {
      final sch = MetaDataNode(MetaType.schema, 's1');
      final db = MetaDataNode(MetaType.database, 'db1', items: [sch]);
      final roots = [db];

      expect(
        getNodeByDatabaseRef(roots, SchemaMode(database: 'db1', schema: 's1')),
        same(sch),
      );
    });

    test('DatabaseMode：database 下直挂 table 时可列出表（ClickHouse / MySQL）', () {
      final users = MetaDataNode(MetaType.table, 'users');
      final queryLog = MetaDataNode(MetaType.table, 'query_log');
      final db = MetaDataNode(MetaType.database, 'system', items: [users, queryLog]);
      final node = getNodeByDatabaseRef([db], DatabaseMode(database: 'system'));
      expect(node, same(db));
      expect(node!.getChildren(MetaType.table).map((e) => e.value), ['users', 'query_log']);
    });
  });

  group('toString', () {
    test('输出可解析的 JSON 且包含 type、value、props、children', () {
      final child = MetaDataNode(MetaType.column, 'id')
          .withProp(MetaDataPropType.dataType, 'bigint');
      final n = MetaDataNode(MetaType.table, 'users', items: [child])
          .withProp(MetaDataPropType.indexType, 'hash');

      final decoded = jsonDecode(n.toString()) as Map<String, dynamic>;
      expect(decoded['type'], 'table');
      expect(decoded['value'], 'users');
      expect(decoded['props'], {'indexType': 'hash'});
      expect(decoded['children'], isA<List<dynamic>>());
      expect((decoded['children'] as List).length, 1);
    });
  });
}
