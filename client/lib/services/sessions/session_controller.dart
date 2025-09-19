// 报存与session 有关的所有controller, 没想好怎么处理他们，感觉用riverpod 不太好。先自己处理吧

import 'package:client/models/sessions.dart';
import 'package:client/widgets/split_view.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

class SessionController {
  // split
  final SplitViewController multiSplitViewCtrl;
  final SplitViewController metaDataSplitViewCtrl;

  // ai chat
  final TextEditingController chatInputController;
  final TextEditingController aiChatSearchTextController;
  final ScrollController aiChatScrollController;

  SessionController(
      {required this.multiSplitViewCtrl,
      required this.metaDataSplitViewCtrl,
      required this.aiChatSearchTextController,
      required this.chatInputController,
      required this.aiChatScrollController});

  static Map<SessionId, SessionController> cache = {};

  static SessionController sessionController(SessionId sessionId) {
    if (cache.containsKey(sessionId)) {
      return cache[sessionId]!;
    }
    final controller = SessionController(
      multiSplitViewCtrl:
          SplitViewController(Area(), Area(size: 500, min: 40)),
      metaDataSplitViewCtrl:
          SplitViewController(Area(), Area(size: 400, min: 360)),
      aiChatSearchTextController: TextEditingController(),
      chatInputController: TextEditingController(),
      aiChatScrollController: ScrollController(),
    );
    cache[sessionId] = controller;
    return controller;
  }

  static void removeSessionController(SessionId sessionId) {
    if (cache.containsKey(sessionId)) {
      cache[sessionId]!.multiSplitViewCtrl.dispose();
      cache[sessionId]!.metaDataSplitViewCtrl.dispose();
      cache[sessionId]!.aiChatSearchTextController.dispose();
      cache[sessionId]!.chatInputController.dispose();
      cache[sessionId]!.aiChatScrollController.dispose();
      cache.remove(sessionId);
    }
  }
}
