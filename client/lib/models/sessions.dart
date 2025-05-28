
import 'package:client/models/interface.dart';
import 'package:flutter/material.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:client/widgets/split_view.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:sql_parser/parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions.g.dart';

enum SQLConnectState { pending, connecting, connected, failed }

enum DrawerPage {
  metadataTree,
  sqlResult,
}

@Riverpod(keepAlive: true)
CurrentSessionDrawer sessionDrawerState(Ref ref, int sessionId) {
  return const CurrentSessionDrawer(
      drawerPage: DrawerPage.metadataTree,
      sqlResult: null,
      sqlColumn: null,
      showRecord: false,
      isRightPageOpen: true);
}

@Riverpod(keepAlive: true)
CurrentSessionSplitView sessionSplitViewState(Ref ref, int sessionId) {
  return CurrentSessionSplitView(
      multiSplitViewCtrl: SplitViewController(Area(), Area(min: 35, size: 500)),
      metaDataSplitViewCtrl:
          SplitViewController(Area(flex: 7, min: 3), Area(flex: 3, min: 3)));
}

@Riverpod(keepAlive: true)
CurrentSessionMetadata sessionMetadataState(Ref ref, int sessionId) {
  return const CurrentSessionMetadata();
}

@Riverpod(keepAlive: true)
CurrentSessionEditor sessionEditor(Ref ref, int sessionId) {
  return CurrentSessionEditor(code: CodeLineEditingController(
      spanBuilder: ({required codeLines, required context, required style}) {
    return TextSpan(
        children: Lexer(codeLines.asString(TextLineBreak.lf))
            .tokens()
            .map<TextSpan>((tok) => TextSpan(
                text: tok.content,
                style: style.merge(getStyle(tok.id) ?? style)))
            .toList());
  }));
}

// @Riverpod(keepAlive: true)
// SessionConnModel sessionConn(Ref ref, int sessionId) {
//   SessionStorage model = ref.watch(sessionRepoProvider).getSession(sessionId)!;
//   print("new session conn build: $sessionId");
//   return SessionConnModel(
//       model: model,
//       conn2: null,
//       state: SQLConnectState.pending,
//       queryState: SQLExecuteState.init,
//       currentSchema: null);
// }
