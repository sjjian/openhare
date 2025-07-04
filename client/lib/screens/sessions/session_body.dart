import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:client/screens/sessions/session_operation_bar.dart';
import 'package:client/screens/sessions/session_sql_editor.dart';
import 'package:client/screens/sessions/session_sql_results.dart';
import 'package:client/services/sessions.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/split_view.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_body.g.dart';

@Riverpod(keepAlive: true)
SessionSplitViewModel sessionSplitViewState(Ref ref, SessionId sessionId) {
  return SessionSplitViewModel(
      multiSplitViewCtrl: SplitViewController(Area(), Area(min: 35, size: 500)),
      metaDataSplitViewCtrl:
          SplitViewController(Area(flex: 7, min: 3), Area(flex: 3, min: 3)));
}

@Riverpod(keepAlive: true)
class SessionSplitViewController extends _$SessionSplitViewController {
  @override
  SessionSplitViewModel build() {
    SessionModel? sessionIdModel =
        ref.watch(selectedSessionIdServicesProvider);
    if (sessionIdModel == null) {
      return ref.watch(sessionSplitViewStateProvider(const SessionId(value: 0))); // todo: 空值处理
    }
    return ref.watch(sessionSplitViewStateProvider(sessionIdModel.sessionId));
  }
}

class SessionBodyPage extends ConsumerWidget {
  const SessionBodyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionEditor = ref.watch(sessionEditorControllerProvider);
    final sessionSplitView = ref.watch(sessionSplitViewControllerProvider);
    final sessionDrawer = ref.watch(sessionDrawerControllerProvider);

    final Widget left = Column(
      children: [
        SessionOpBar(codeController: sessionEditor.code),
        Expanded(
          child: SplitView(
            controller: sessionSplitView.multiSplitViewCtrl,
            axis: Axis.vertical,
            first: SQLEditor(
                key: ValueKey(sessionEditor.code),
                codeController: sessionEditor.code),
            second: const SqlResultTables(),
          ),
        ),
      ],
    );
    return Container(
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: sessionDrawer.isRightPageOpen
          ? SplitView(
              axis: Axis.horizontal,
              controller: sessionSplitView.metaDataSplitViewCtrl,
              first: left,
              second: const SessionDrawerBody(),
            )
          : left,
    );
  }
}
