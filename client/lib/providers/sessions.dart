import 'package:client/models/interface.dart';
import 'package:client/services/sessions.dart';
import 'package:client/repositories/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:client/widgets/split_view.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:sql_parser/parser.dart';

part 'sessions.g.dart';

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


@Riverpod(keepAlive: true)
class SessionDrawerController extends _$SessionDrawerController {
  @override
  CurrentSessionDrawer build() {
    SelectedSessionId? sessionIdModel =
        ref.watch(selectedSessionIdControllerProvider);
    if (sessionIdModel == null) {
      return ref.watch(sessionDrawerStateProvider(0));
    }
    return ref.watch(sessionDrawerStateProvider(sessionIdModel.sessionId));
  }

  Future<void> loadMetadata() async {
    // CurrentSessionDrawer? session = ref.read(currentSessionDrawerProvider);
    // if (session == null || session is UnInitSession) {
    //   return;
    // }
    // if ((session as Session).metadata != null) {
    //   return;
    // }

    // if (session.connState != SQLConnectState.connected) {
    //   return;
    // }
    // session.metadata = await session.conn2!.metadata();
    // ref.invalidate(currentSessionDrawerProvider);
    return;
  }

  void showRightPage() {
    state = state.copyWith(isRightPageOpen: true);
  }

  void hideRightPage() {
    state = state.copyWith(isRightPageOpen: false);
  }

  void showSQLResult({BaseQueryValue? result, BaseQueryColumn? column}) {
    state = state.copyWith(
      drawerPage: DrawerPage.sqlResult,
      sqlColumn: column ?? state.sqlColumn,
      sqlResult: result ?? state.sqlResult,
    );
  }

  void goToTree() {
    state = state.copyWith(
      drawerPage: DrawerPage.metadataTree,
      sqlColumn: null,
      sqlResult: null,
    );
  }
}

@Riverpod(keepAlive: true)
class SessionSplitViewController extends _$SessionSplitViewController {
  @override
  CurrentSessionSplitView build() {
    SelectedSessionId? sessionIdModel =
        ref.watch(selectedSessionIdControllerProvider);
    if (sessionIdModel == null) {
      return ref.watch(sessionSplitViewStateProvider(0));
    }
    return ref.watch(sessionSplitViewStateProvider(sessionIdModel.sessionId));
  }
}

@Riverpod(keepAlive: true)
class SessionMetadataController extends _$SessionMetadataController {
  @override
  CurrentSessionMetadata build() {
    SelectedSessionId? sessionIdModel =
        ref.watch(selectedSessionIdControllerProvider);
    if (sessionIdModel == null) {
      return ref.watch(sessionMetadataStateProvider(0));
    }
    return ref.watch(sessionMetadataStateProvider(sessionIdModel.sessionId));
  }
}

@Riverpod(keepAlive: true)
class SessionEditorController extends _$SessionEditorController {
  @override
  CurrentSessionEditor build() {
    SelectedSessionId? sessionIdModel =
        ref.watch(selectedSessionIdControllerProvider);
    if (sessionIdModel == null) {
      return ref.watch(sessionEditorProvider(0));
    }
    return ref.watch(sessionEditorProvider(sessionIdModel.sessionId));
  }
}



@Riverpod(keepAlive: true)
class SelectedSessionIdController extends _$SelectedSessionIdController {
  @override
  SelectedSessionId? build() {
    int sessionId = ref.watch(sessionsServicesProvider.select((s) {
      print("notify sessionTabControllerProvider");
      if (s.sessions.selected() == null ||
          s.sessions.selected()!.instance.target == null) {
        return 0;
      }
      return s.sessions.selected()!.id;
    }));
    print("SelectedSessionIdController1 build: $sessionId");
    if (sessionId == 0) {
      return null;
    }
    print("SelectedSessionIdController2 build: $sessionId");
    SessionStorage? session =
        ref.read(sessionRepoProvider).getSession(sessionId);
    
    if (session == null || session.instance.target == null) {
      print("SelectedSessionIdController build 1: session is null or instance is null");
      return null;
    }
    print("SelectedSessionIdController build 2: $sessionId");
    return SelectedSessionId(
        sessionId: sessionId, instanceId: session.instance.target!.id);
  }
}


