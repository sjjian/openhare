import 'package:client/models/sessions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import 'package:client/models/instances.dart';
import 'package:objectbox/objectbox.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:client/models/session_sql_result.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:client/widgets/split_view.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:sql_parser/parser.dart';

part 'interface.freezed.dart';

abstract class SessionRepo {
  ReorderSelectedList<BaseSession> getSessions();
  // session
  CurrentSession? currentSession(); 

  SessionStorage getSession(int sessionId);
  // void setCurrentSession(CurrentSession session);

  // // session drawer
  // CurrentSessionDrawer? getCurrentSessionDrawer();
  // set currentSessionDrawer(CurrentSessionDrawer drawer);
  // // session split view
  // CurrentSessionSplitView get currentSessionSplitView;
  // set currentSessionSplitView(CurrentSessionSplitView splitView);
  // // session sql result
  // CurrentSessionSQLResult get currentSessionSQLResult;
}

@freezed
abstract class SessionTabs  with _$SessionTabs {
    const factory SessionTabs({
    required String firstName,
    required String lastName,
    required int age,
  }) = _SessionTabs;

}

@freezed
abstract class SessionStatus  with _$SessionStatus {
    const factory SessionStatus({
    MetaDataNode? metadata,
    TreeController<DataNode>? metadataController,
  }) = _SessionStatus;
}

@freezed 
abstract class CurrentSession with _$CurrentSession {
  const factory CurrentSession({
    required SessionStorage model,
    BaseConnection? conn2,
    required SQLConnectState state,
    String? text,
    String? currentSchema,
  }) = _CurrentSession;
}

@freezed
abstract class SessionConn with _$SessionConn {
  const factory SessionConn({
    required SessionStorage model,
    BaseConnection? conn2,
    required SQLConnectState state,
    String? currentSchema,
  }) = _SessionConn;
}

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
    required CodeLineEditingController code,
    required bool isRightPageOpen,
  }) = _CurrentSessionSplitView;
}

@freezed
abstract class CurrentSessionSQLResult with _$CurrentSessionSQLResult {
  const factory CurrentSessionSQLResult({
    required ReorderSelectedList<SQLResultModel> sqlResults,
    required SQLExecuteState? queryState,
  }) = _CurrentSessionSQLResult;
}

