import 'package:client/models/sql_result.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:client/widgets/split_view.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:common/parser.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/models/instances.dart';

class SessionsModel {
  ReorderSelectedList<SessionModel> data = ReorderSelectedList();
}

enum SQLConnectState { pending, connecting, connected, failed }

enum DrawerPage {
  metadataTree,
  sqlResult,
}

class SessionModel {
  InstanceModel? instance;
  BaseConnection? conn2;
  SQLConnectState connState = SQLConnectState.pending;
  void Function()? _onClose;
  void Function(String)? _onSchemaChanged;
  String? currentSchema;

  SQLExecuteState? queryState;

  MetaDataNode? metadata;

  TreeController<DataNode>? metadataController;

  ReorderSelectedList<SQLResultModel> sqlResults = ReorderSelectedList();

  final SplitViewController multiSplitViewCtrl =
      SplitViewController(Area(), Area(min: 35, size: 500));

  final SplitViewController metaDataSplitViewCtrl =
      SplitViewController(Area(flex: 7, min: 3), Area(flex: 3, min: 3));

  CodeLineEditingController code = CodeLineEditingController(
      spanBuilder: ({required codeLines, required context, required style}) {
    return TextSpan(
        children: Lexer(codeLines.asString(TextLineBreak.lf))
            .tokens()
            .map<TextSpan>((tok) => TextSpan(
                text: tok.content,
                style: style.merge(getStyle(tok.id) ?? style)))
            .toList());
  });

  // session drawer
  DrawerPage drawerPage = DrawerPage.metadataTree;

  BaseQueryValue? sqlResult;
  BaseQueryColumn? sqlColumn;

  //
  bool showRecord = true;
  bool isRightPageOpen = true;

  SessionModel();

  int genSQLResultId() {
    return sqlResults.isEmpty
        ? 0
        : sqlResults.fold(
                0,
                (previousId, element) =>
                    previousId < element.id ? element.id : previousId) +
            1;
  }

  Future<void> connect() async {
    try {
      conn2 = await ConnectionFactory.open(
          type: DatabaseType.mysql,
          meta: ConnectMeta(
              addr: instance!.addr,
              port: instance!.port,
              user: instance!.user,
              password: instance!.password,
              database: currentSchema),
          onCloseCallback: onConnClose,
          onSchemaChangedCallback: onSchemaChanged);
      connState = SQLConnectState.connected;
    } catch (e) {
      print("conn error: ${e}");
      connState = SQLConnectState.failed;
    }
  }

  Future<void> close() async {
    if (conn2 == null || connState != SQLConnectState.connected) {
      return;
    }
    try {
      conn2!.close();
      connState = SQLConnectState.pending;
      // conn = null;
    } catch (e) {
      // todo: handler error;
    }
  }

  void onConnClose() {
    connState = SQLConnectState.pending;
    _onClose?.call();
  }

  void onSchemaChanged(String schema) {
    currentSchema = schema;
    _onSchemaChanged?.call(schema);
  }

  void listenCallBack(
      void Function() onClose, void Function(String) onSchemaChanged) {
    _onClose = onClose;
    _onSchemaChanged = onSchemaChanged;
  }

  void unListenCallBack() {
    _onClose = null;
    _onSchemaChanged = null;
  }
}
