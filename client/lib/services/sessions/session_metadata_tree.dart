import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/services/instances/metadata.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/utils/state_value.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_metadata_tree.g.dart';

@Riverpod(keepAlive: true)
class SessionMetadataServices extends _$SessionMetadataServices {
  @override
  SessionMetadataTreeModel? build(SessionId sessionId) {
    SessionModel? sessionModel =
        ref.read(sessionsServicesProvider.notifier).getSession(sessionId);
    if (sessionModel == null || sessionModel.instanceId == null) {
      return null;
    }

    InstanceMetadataModel? metadataModel =
        ref.watch(instanceMetadataServicesProvider(sessionModel.instanceId!));

    // 如果 metadataModel 为空，则刷新
    if (metadataModel == null) {
      ref
          .read(instanceMetadataServicesProvider(sessionModel.instanceId!)
              .notifier)
          .refreshMetadata();

      return null;
    }

    return metadataModel.metadata.match(
      (value) {
        List<MetaDataNode> items = value;
        RootNode root = RootNode();
        final metadataController = TreeController<DataNode>(
          roots: buildMetadataTree(root, items).children,
          childrenProvider: (DataNode node) => node.children,
        );

        root.visitor((node) {
          // 默认打开 SchemaNode
          if (node is SchemaNode) {
            metadataController.setExpansionState(node, true);
          }
          // 默认打开 currentSchema 对应的节点
          if (node is SchemaValueNode &&
              node.name == sessionModel.currentSchema) {
            metadataController.setExpansionState(node, true);
          }
          // 默认打开所有table 节点
          if (node is TableNode) {
            metadataController.setExpansionState(node, true);
          }
          // 默认打开所有column 节点
          if (node is ColumnNode) {
            metadataController.setExpansionState(node, true);
          }
          return true;
        });
        return SessionMetadataTreeModel(
          sessionId: sessionId,
          metadataTreeCtrl: StateValue.done(metadataController),
        );
      },
      (error) {
        return SessionMetadataTreeModel(
          sessionId: sessionId,
          metadataTreeCtrl: StateValue.error(error),
        );
      },
      () {
        return SessionMetadataTreeModel(
          sessionId: sessionId,
          metadataTreeCtrl: const StateValue.running(),
        );
      },
    );
  }

  Future<void> refresh() async {
    final model =
        ref.read(sessionsServicesProvider.notifier).getSession(sessionId);
    if (model == null || model.instanceId == null) {
      return;
    }
    ref
        .read(instanceMetadataServicesProvider(model.instanceId!).notifier)
        .refreshMetadata();
  }
}

@Riverpod(keepAlive: true)
class SessionMetadataNotifier extends _$SessionMetadataNotifier {
  @override
  SessionMetadataTreeModel? build() {
    SessionModel? sessionModel = ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null || sessionModel.instanceId == null) {
      return null;
    }
    return ref.watch(sessionMetadataServicesProvider(sessionModel.sessionId));
  }
}
