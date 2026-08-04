import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/services/sessions/session_metadata.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sql_parser/parser.dart';
import 'package:sql_complete/sql_complete.dart';

part 'session_sql_editor.g.dart';

@Riverpod(keepAlive: true)
class SelectedSessionSQLEditorNotifier extends _$SelectedSessionSQLEditorNotifier {
  @override
  SessionSQLEditorModel build() {
    SessionDetailModel? sessionDetailModel = ref.watch(selectedSessionDetailProvider);
    if (sessionDetailModel == null) {
      return const SessionSQLEditorModel(sessionId: SessionId(value: 0));
    }
    if (sessionDetailModel.instanceId != null) {
      AsyncValue<InstanceMetadataModel>? sessionMeta = ref.watch(
        selectedSessionMetadataProvider,
      );
      return SessionSQLEditorModel(
        sessionId: sessionDetailModel.sessionId,
        currentSchema: sessionDetailModel.currentSchema,
        dbType: sessionDetailModel.dbType,
        metadata: sessionMeta?.when(
          data: (data) => data.metadata,
          error: (error, trace) => null,
          loading: () => null,
        ),
      );
    }

    return SessionSQLEditorModel(
      sessionId: sessionDetailModel.sessionId,
      currentSchema: sessionDetailModel.currentSchema,
      dbType: sessionDetailModel.dbType,
    );
  }
}

@Riverpod(keepAlive: true)
class SessionSqlCompletion extends _$SessionSqlCompletion {
  SqlCompleteCatalog _catalog = SqlCompleteCatalog.empty;
  DialectType _dialect = DialectType.mysql;

  SqlCompleteCatalog get catalog => _catalog;
  DialectType get dialect => _dialect;

  @override
  SessionSQLCompletionModel build() {
    final model = ref.watch(selectedSessionSQLEditorProvider);
    _dialect = model.dbType?.dialectType ?? DialectType.mysql;
    final roots = _objectRoots(model.metadata, model.currentSchema);
    _catalog = _buildCatalog(roots, _dialect);
    return SessionSQLCompletionModel(objectProps: _buildObjectProps(roots));
  }
}

List<MetaDataNode> _objectRoots(
  List<MetaDataNode>? metadata,
  DatabaseRef? currentSchema,
) {
  if (metadata == null) return const [];
  if (currentSchema == null) return metadata;
  final node = getNodeByDatabaseRef(metadata, currentSchema);
  if (node == null) return metadata;
  // schema/database 节点：用其子节点作为遍历根，避免把库名本身当唯一对象。
  final children = node.items;
  if (children != null && children.isNotEmpty) return children;
  return [node];
}

SqlCompleteCatalog _buildCatalog(List<MetaDataNode> roots, DialectType dialect) {
  final keywordEntries = [
    for (final k in keywords(dialect)) SqlCompleteCatalogEntry(text: k, kind: SqlCompleteKind.keyword),
  ];
  if (roots.isEmpty) {
    return SqlCompleteCatalog(keywords: keywordEntries);
  }

  final objects = <SqlCompleteCatalogEntry>[];
  // related 键统一小写，查找时 exact match，避免 t1 / t1_1 前缀误绑。
  final related = <String, List<SqlCompleteCatalogEntry>>{};
  for (final root in roots) {
    root.visitor((node, parent) {
      // 根节点本身若是 database/schema 容器，仍收录其子对象；节点自身也进 objects。
      final kind = switch (node.type) {
        MetaType.instance || MetaType.database || MetaType.schema =>
          SqlCompleteKind.database,
        MetaType.table => SqlCompleteKind.table,
        MetaType.column => SqlCompleteKind.column,
      };
      final entry = SqlCompleteCatalogEntry(
        text: node.value,
        kind: kind,
      );
      objects.add(entry);
      if (parent != null && parent.value.isNotEmpty) {
        related.putIfAbsent(parent.value.toLowerCase(), () => []).add(entry);
      }
      return true;
    });
  }
  return SqlCompleteCatalog(
    keywords: keywordEntries,
    objects: objects,
    related: related,
  );
}

Map<String, Map<MetaDataPropType, MetaDataProp>> _buildObjectProps(
  List<MetaDataNode> roots,
) {
  if (roots.isEmpty) return const {};

  final bareCounts = <String, int>{};
  for (final root in roots) {
    root.visitor((node, parent) {
      if (node.props.isNotEmpty) {
        bareCounts.update(node.value, (v) => v + 1, ifAbsent: () => 1);
      }
      return true;
    });
  }
  final out = <String, Map<MetaDataPropType, MetaDataProp>>{};
  for (final root in roots) {
    root.visitor((node, parent) {
      if (node.props.isEmpty) return true;
      final props = Map<MetaDataPropType, MetaDataProp>.of(node.props);
      if (parent != null && parent.value.isNotEmpty) {
        out['${parent.value}.${node.value}'] = props;
      }
      if (bareCounts[node.value] == 1) {
        out[node.value] = props;
      }
      return true;
    });
  }
  return out;
}
