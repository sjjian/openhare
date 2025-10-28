// 报存与session 有关的所有controller, 没想好怎么处理他们，感觉用riverpod 不太好。先自己处理吧

import 'package:client/models/sessions.dart';
import 'package:client/widgets/data_grid.dart';
import 'package:client/widgets/split_view.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:client/widgets/scroll.dart';
import 'package:sql_editor/re_editor.dart';

class SessionController {
  // split
  final SplitViewController multiSplitViewCtrl;
  final SplitViewController metaDataSplitViewCtrl;

  // sql editor
  final CodeScrollController sqlEditorScrollController;

  // ai chat
  final TextEditingController chatInputController;
  final TextEditingController aiChatSearchTextController;
  final KeepOffestScrollController aiChatScrollController;

  // drawer
  final KeepOffestScrollController metadataTreeScrollController;

  SessionController({
    required this.multiSplitViewCtrl,
    required this.metaDataSplitViewCtrl,
    required this.aiChatSearchTextController,
    required this.chatInputController,
    required this.aiChatScrollController,
    required this.sqlEditorScrollController,
    required this.metadataTreeScrollController,
  });

  static Map<SessionId, SessionController> cache = {};

  static SessionController sessionController(SessionId sessionId) {
    if (cache.containsKey(sessionId)) {
      return cache[sessionId]!;
    }
    final controller = SessionController(
      multiSplitViewCtrl: SplitViewController(Area(), Area(size: 500, min: 40)),
      metaDataSplitViewCtrl:
          SplitViewController(Area(), Area(size: 400, min: 360)),
      // sql editor
      sqlEditorScrollController: CodeScrollController(
        verticalScroller: KeepOffestScrollController(),
        horizontalScroller: KeepOffestScrollController(),
      ),
      // ai chat
      aiChatSearchTextController: TextEditingController(),
      chatInputController: TextEditingController(),
      aiChatScrollController: KeepOffestScrollController(),

      // drawer
      metadataTreeScrollController: KeepOffestScrollController(),
    );
    cache[sessionId] = controller;
    return controller;
  }

  static void removeSessionController(SessionId sessionId) {
    if (cache.containsKey(sessionId)) {
      cache[sessionId]!.multiSplitViewCtrl.dispose();
      cache[sessionId]!.metaDataSplitViewCtrl.dispose();
      // sql editor
      cache[sessionId]!.sqlEditorScrollController.verticalScroller.dispose();
      cache[sessionId]!.sqlEditorScrollController.horizontalScroller.dispose();
      // ai chat
      cache[sessionId]!.aiChatSearchTextController.dispose();
      cache[sessionId]!.chatInputController.dispose();
      cache[sessionId]!.aiChatScrollController.dispose();
      cache.remove(sessionId);
      // drawer
      cache[sessionId]!.metadataTreeScrollController.dispose();
    }
  }
}

class SQLResultController {
  final DataGridController controller;

  /// 表格滚动控制器
  final KeepOffestLinkedScrollControllerGroup horizontalScrollGroup;
  final KeepOffestScrollController verticalController;

  SQLResultController({
    required this.controller,
    required this.horizontalScrollGroup,
    required this.verticalController,
  });

  static Map<ResultId, SQLResultController> cache = {};

  // 使用init回调，如果存在则跳过初始化
  static SQLResultController sqlResultController(
      ResultId resultId, DataGridController Function() init) {
    if (cache.containsKey(resultId)) {
      return cache[resultId]!;
    }
    final controller = SQLResultController(
      controller: init(),
      horizontalScrollGroup: KeepOffestLinkedScrollControllerGroup(),
      verticalController: KeepOffestScrollController(),
    );
    cache[resultId] = controller;
    return controller;
  }

  static void removeSQLResultController(ResultId resultId) {
    if (cache.containsKey(resultId)) {
      cache[resultId]!.controller.dispose();
      cache[resultId]!.verticalController.dispose();
      cache.remove(resultId);
    }
  }
}
