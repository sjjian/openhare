import 'package:client/repositories/session_conn.dart';
import 'package:client/repositories/sessions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:client/repositories/session_sql_result.dart';
import 'package:db_driver/db_driver.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/widgets/split_view.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

part 'interface.freezed.dart';

enum SQLConnectState { pending, connecting, connected, failed }

enum DrawerPage {
  metadataTree,
  sqlResult,
}

// @freezed
// abstract class SessionConnModel with _$SessionConnModel {
//   const factory SessionConnModel({
//     required SessionConn conn,
//   }) = _SessionConnModel;
// }

@freezed
abstract class CurrentSessionDrawer with _$CurrentSessionDrawer {
  const factory CurrentSessionDrawer({
    required DrawerPage drawerPage,
    required BaseQueryValue? sqlResult,
    required BaseQueryColumn? sqlColumn,
    required bool showRecord,
    required bool isRightPageOpen,
  }) = _CurrentSessionDrawer;
}

@freezed
abstract class CurrentSessionSplitView with _$CurrentSessionSplitView {
  const factory CurrentSessionSplitView({
    required SplitViewController multiSplitViewCtrl,
    required SplitViewController metaDataSplitViewCtrl,
  }) = _CurrentSessionSplitView;
}

@freezed
abstract class CurrentSessionMetadata with _$CurrentSessionMetadata {
  const factory CurrentSessionMetadata({
    MetaDataNode? metadata,
    TreeController<DataNode>? metadataController,
  }) = _CurrentSessionMetadata;
}

@freezed
abstract class CurrentSessionEditor with _$CurrentSessionEditor {
  const factory CurrentSessionEditor({
    required CodeLineEditingController code,
  }) = _CurrentSessionEditor;
}

@freezed
abstract class SelectedSessionId with _$SelectedSessionId {
  const factory SelectedSessionId({
    required int sessionId,
    required int instanceId,
  }) = _SelectedSessionId;
}

@freezed
abstract class SessionTab with _$SessionTab {
  const factory SessionTab({
    required ReorderSelectedList<SessionStorage> sessions,
  }) = _SessionTab;
}

@freezed
abstract class SQLResultsModel with _$SQLResultsModel {
  const factory SQLResultsModel({
    required int sessionId,
    required ReorderSelectedList<SQLResult> sqlResults,
  }) = _SQLResultsModel;
}

@freezed
abstract class SQLResultModel with _$SQLResultModel {
  const factory SQLResultModel({
    required int sessionId,
    required SQLResult result,
  }) = _SQLResultModel;
}

@freezed
abstract class SessionStatusModel with _$SessionStatusModel {
  const factory SessionStatusModel({
    required int sessionId,
    required String instanceName,
    // sql result
    int? resultId,
    required SQLExecuteState state,
    Duration? executeTime,
    BigInt? affectedRows,
    String? query,
  }) = _SessionStatusModel;
}