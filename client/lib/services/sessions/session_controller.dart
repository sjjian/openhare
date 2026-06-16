// 报存与session 有关的所有controller, 没想好怎么处理他们，感觉用riverpod 不太好。先自己处理吧

import 'package:client/models/sessions.dart';
import 'package:client/repositories/sessions/sessions.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/chat_list_view.dart';
import 'package:client/widgets/data_grid.dart';
import 'package:client/widgets/split_view.dart';
import 'package:client/widgets/sql_highlight.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/scroll.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/widgets/mention_text.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_controller.g.dart';

class SessionController {
  // split
  final SplitViewController multiSplitViewCtrl;
  final SplitViewController metaDataSplitViewCtrl;
  final SplitViewController metadataTreeSplitViewCtrl;

  // sql editor
  final CodeLineEditingController sqlEditorController;
  final CodeScrollController sqlEditorScrollController;

  // ai chat
  final MentionTextEditingController chatInputController;
  final TextEditingController aiChatSearchTextController;
  final TextEditingController aiChatModelSearchTextController;
  final ChatScrollController chatScrollController;

  // drawer
  final KeepOffestScrollController metadataTreeScrollController;

  SessionController({
    required this.multiSplitViewCtrl,
    required this.metaDataSplitViewCtrl,
    required this.metadataTreeSplitViewCtrl,
    required this.aiChatSearchTextController,
    required this.aiChatModelSearchTextController,
    required this.chatInputController,
    required this.chatScrollController,
    required this.sqlEditorController,
    required this.sqlEditorScrollController,
    required this.metadataTreeScrollController,
  });

  static Map<SessionId, SessionController> cache = {};

  static SessionController init(SessionId sessionId, DatabaseType dbType, String code) {
    if (cache.containsKey(sessionId)) {
      return cache[sessionId]!;
    }
    final sqlEditorController = CodeLineEditingController(
      spanBuilder: ({required codeLines, required context, required style}) {
        return getSQLHighlightTextSpan(dbType.dialectType, codeLines.asString(TextLineBreak.lf), defalutStyle: style);
      },
    );
    sqlEditorController.text = code;

    final controller = SessionController(
      multiSplitViewCtrl: SplitViewController(secondSize: 500, firstMinSize: 100, secondMinSize: 140),
      metaDataSplitViewCtrl: SplitViewController(secondSize: 400, firstMinSize: 140, secondMinSize: 360),
      metadataTreeSplitViewCtrl: SplitViewController(secondSize: 220, firstMinSize: 200, secondMinSize: 200),
      // sql editor
      sqlEditorController: sqlEditorController,
      sqlEditorScrollController: CodeScrollController(
        verticalScroller: KeepOffestScrollController(),
        horizontalScroller: KeepOffestScrollController(),
      ),
      // ai chat
      aiChatSearchTextController: TextEditingController(),
      aiChatModelSearchTextController: TextEditingController(),
      chatInputController: MentionTextEditingController(),
      chatScrollController: ChatScrollController(),

      // drawer
      metadataTreeScrollController: KeepOffestScrollController(),
    );
    cache[sessionId] = controller;
    return controller;
  }

  static SessionController? getSessionController(SessionId sessionId) {
    return cache[sessionId];
  }

  static void removeSessionController(SessionId sessionId) {
    if (cache.containsKey(sessionId)) {
      cache[sessionId]!.multiSplitViewCtrl.dispose();
      cache[sessionId]!.metaDataSplitViewCtrl.dispose();
      cache[sessionId]!.metadataTreeSplitViewCtrl.dispose();
      // sql editor
      cache[sessionId]!.sqlEditorScrollController.verticalScroller.dispose();
      cache[sessionId]!.sqlEditorScrollController.horizontalScroller.dispose();
      // ai chat
      cache[sessionId]!.aiChatSearchTextController.dispose();
      cache[sessionId]!.aiChatModelSearchTextController.dispose();
      cache[sessionId]!.chatInputController.dispose();
      cache[sessionId]!.chatScrollController.dispose();
      // drawer
      cache[sessionId]!.metadataTreeScrollController.dispose();
      // remove cache
      cache.remove(sessionId);
    }
  }
}

class SQLResultController {
  final DataGridController controller;

  /// 表格滚动控制器
  final KeepOffestLinkedScrollControllerGroup horizontalScrollGroup;
  final KeepOffestLinkedScrollControllerGroup verticalScrollGroup;

  SQLResultController({
    required this.controller,
    required this.horizontalScrollGroup,
    required this.verticalScrollGroup,
  });

  static Map<ResultId, SQLResultController> cache = {};

  // 使用init回调，如果存在则跳过初始化
  static SQLResultController sqlResultController(ResultId resultId, DataGridController Function() init) {
    if (cache.containsKey(resultId)) {
      return cache[resultId]!;
    }
    final controller = SQLResultController(
      controller: init(),
      horizontalScrollGroup: KeepOffestLinkedScrollControllerGroup(),
      verticalScrollGroup: KeepOffestLinkedScrollControllerGroup(),
    );
    cache[resultId] = controller;
    return controller;
  }

  static void removeSQLResultController(ResultId resultId) {
    if (cache.containsKey(resultId)) {
      cache[resultId]!.controller.dispose();
      cache.remove(resultId);
    }
  }
}

@Riverpod(keepAlive: true)
class SelectedSessionControllerNotifier extends _$SelectedSessionControllerNotifier {
  @override
  SessionController build() {
    SessionDetailModel? sessionDetailModel = ref.watch(selectedSessionDetailProvider);
    if (sessionDetailModel == null) {
      return SessionController.init(SessionId(value: 0), DatabaseType.mysql, "");
    }
    final code = ref.watch(sessionRepoProvider).getCode(sessionDetailModel.sessionId);
    return SessionController.init(
      sessionDetailModel.sessionId,
      sessionDetailModel.dbType ?? DatabaseType.mysql,
      code ?? "",
    );
  }
}
