import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_metadata.g.dart';

@Riverpod(keepAlive: true)
class SelectedSessionMetadataNotifier extends _$SelectedSessionMetadataNotifier {
  @override
  Future<InstanceMetadataModel> build() async {
    SessionModel? sessionModel = ref.watch(selectedSessionProvider);
    if (sessionModel == null || sessionModel.instanceId == null) {
      throw Exception("Session not found");
    }
    return await ref.read(instancesServicesProvider.notifier).getMetadata(sessionModel.instanceId!);
  }

  Future<void> refreshMetadata() async {
    SessionModel? sessionModel = ref.read(selectedSessionProvider);
    if (sessionModel == null || sessionModel.instanceId == null) {
      throw Exception("Session not found");
    }
    // 不先置 loading，避免刷新时树闪白；保留上一棵树直到新数据就绪。
    await ref.read(instancesServicesProvider.notifier).refreshMetadata(sessionModel.instanceId!);
    final metadata = await ref.read(instancesServicesProvider.notifier).getMetadata(sessionModel.instanceId!);
    state = AsyncValue.data(metadata);
  }

  MetaDataNode? findCachedRelation(DataValueNode node) {
    final current = state.asData?.value;
    if (current == null) return null;
    if (current.databaseMode == DatabaseModeType.singleMode) {
      for (final n in current.metadata) {
        if (n.type == node.metaType && n.value == node.name) return n;
      }
      return null;
    }
    final database = node.database;
    if (database == null || database.isEmpty) return null;
    return MetaDataNode(MetaType.instance, '', items: current.metadata).findRelation(
      database: database,
      schema: node.schema,
      name: node.name,
      type: node.metaType,
    );
  }

  List<String> relationColumnNames(DataValueNode node) {
    return [
      for (final n in findCachedRelation(node)?.items ?? const [])
        if (n.type == MetaType.column) n.value,
    ];
  }

  String? buildSelectSql(DataValueNode node) {
    final dbType = ref.read(selectedSessionDetailProvider)?.dbType;
    if (dbType == null || !ConnectionWrapper.supportsSelectSqlOf(dbType)) {
      return null;
    }
    return ConnectionWrapper.buildSelectSqlOf(
      dbType,
      name: node.name,
      database: node.database,
      schema: node.schema,
      columns: relationColumnNames(node),
    );
  }

  String? buildInsertSql(DataValueNode node) {
    final dbType = ref.read(selectedSessionDetailProvider)?.dbType;
    if (dbType == null || !ConnectionWrapper.supportsInsertSqlOf(dbType)) {
      return null;
    }
    return ConnectionWrapper.buildInsertSqlOf(
      dbType,
      name: node.name,
      database: node.database,
      schema: node.schema,
      columns: relationColumnNames(node),
    );
  }

  Future<void> viewRelationData(SessionId sessionId, DataValueNode node) async {
    final sql = buildSelectSql(node);
    if (sql == null) return;
    await ref.read(sQLResultsServicesProvider.notifier).queryAddResult(sessionId, sql);
  }
}

class _CachedMetadataTree {
  final SessionMetadataTreeModel model;
  final InstanceMetadataModel metadata;

  _CachedMetadataTree({required this.model, required this.metadata});
}

@Riverpod(keepAlive: true)
class SelectedMetadataTreeNodeNotifier extends _$SelectedMetadataTreeNodeNotifier {
  final Map<SessionId, String> _selectedKeys = {};

  @override
  DataNode? build() {
    ref.watch(sessionsServicesProvider);
    _prune();
    final session = ref.watch(selectedSessionProvider);
    if (session == null) return null;
    ref.watch(selectedSessionMetadataTreeProvider);
    final key = _selectedKeys[session.sessionId];
    if (key == null) return null;
    final tree = ref.read(selectedSessionMetadataTreeProvider).asData?.value;
    return tree?.metadataTreeCtrl.findByKey(key);
  }

  void select(DataNode? node) {
    final session = ref.read(selectedSessionProvider);
    if (session == null) return;
    if (node is DataValueNode) {
      _selectedKeys[session.sessionId] = metadataNodeKey(node);
    } else {
      _selectedKeys.remove(session.sessionId);
    }
    state = node;
  }

  void clear() {
    final session = ref.read(selectedSessionProvider);
    if (session != null) {
      _selectedKeys.remove(session.sessionId);
    }
    state = null;
  }

  void _prune() {
    final alive = {
      for (final s in ref.read(sessionsServicesProvider.notifier).getSessions().sessions) s.sessionId,
    };
    _selectedKeys.removeWhere((id, _) => !alive.contains(id));
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionMetadataTreeNotifier extends _$SelectedSessionMetadataTreeNotifier {
  final Map<SessionId, _CachedMetadataTree> _cache = {};

  @override
  Future<SessionMetadataTreeModel> build() async {
    ref.watch(sessionsServicesProvider);
    _prune();
    SessionModel? sessionModel = ref.watch(selectedSessionProvider);
    if (sessionModel == null || sessionModel.instanceId == null) {
      throw Exception("Session not found");
    }

    final metadataModel = await ref.watch(selectedSessionMetadataProvider.future);
    final sessionId = sessionModel.sessionId;
    final cached = _cache[sessionId];
    if (cached != null && identical(cached.metadata, metadataModel)) {
      return cached.model;
    }

    final keys = cached?.model.metadataTreeCtrl.expansionKeys();
    cached?.model.metadataTreeCtrl.dispose();
    final model = _buildTree(sessionModel, metadataModel, keys);
    _cache[sessionId] = _CachedMetadataTree(model: model, metadata: metadataModel);
    return model;
  }

  SessionMetadataTreeModel _buildTree(
    SessionModel sessionModel,
    InstanceMetadataModel metadataModel,
    Set<String>? expansionKeys,
  ) {
    final root = RootNode();
    final metadataController = DataTreeController(
      roots: buildMetadataTree(
        root,
        metadataModel.metadata,
      ).children,
      childrenProvider: (DataNode node) => node.children,
    );

    if (expansionKeys != null) {
      metadataController.restoreExpansion(expansionKeys);
    } else {
      root.visitor((node) {
        // 默认打开 database / schema 分类文件夹（与 buildDataNode 的 MetaType 对应）
        if (node is DatabaseNode || node is SchemaNode) {
          metadataController.setExpansionState(node, true);
        }
        if (node is DatabaseValueNode) {
          final cur = sessionModel.currentSchema;
          if (cur != null && cur.databaseName() == node.name) {
            metadataController.setExpansionState(node, true);
          }
        }
        if (node is SchemaValueNode) {
          final cur = sessionModel.currentSchema;
          if (cur != null && cur.schemaName() == node.name) {
            metadataController.setExpansionState(node, true);
          }
        }
        // 默认打开所有 table 分类夹
        if (node is TableNode) {
          metadataController.setExpansionState(node, true);
        }
        return true;
      });
    }
    return SessionMetadataTreeModel(
      sessionId: sessionModel.sessionId,
      metadataTreeCtrl: metadataController,
    );
  }

  void _prune() {
    final alive = {
      for (final s in ref.read(sessionsServicesProvider.notifier).getSessions().sessions) s.sessionId,
    };
    final stale = [
      for (final id in _cache.keys)
        if (!alive.contains(id)) id,
    ];
    for (final id in stale) {
      _cache.remove(id)?.model.metadataTreeCtrl.dispose();
    }
  }
}

// schema
@Riverpod(keepAlive: true)
class SelectedSessionSchemaNotifier extends _$SelectedSessionSchemaNotifier {
  @override
  Future<SelectedSessionSchemaModel> build() async {
    SessionModel? sessionModel = ref.watch(selectedSessionProvider);
    if (sessionModel == null || sessionModel.instanceId == null) {
      throw Exception("Session not found");
    }
    final metadataModel = await ref.watch(selectedSessionMetadataProvider.future);
    return SelectedSessionSchemaModel(
      sessionId: sessionModel.sessionId,
      databaseMode: metadataModel.databaseMode,
      schemas: metadataModel.schemas,
    );
  }
}
