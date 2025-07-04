import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_drawer_metadata.dart';
import 'package:client/screens/sessions/session_drawer_sql_result.dart';
import 'package:client/services/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_drawer_body.g.dart';

@Riverpod(keepAlive: true)
SessionDrawerModel sessionDrawerState(Ref ref, SessionId sessionId) {
  return const SessionDrawerModel(
      drawerPage: DrawerPage.metadataTree,
      sqlResult: null,
      sqlColumn: null,
      showRecord: false,
      isRightPageOpen: true);
}

@Riverpod(keepAlive: true)
class SessionDrawerController extends _$SessionDrawerController {
  @override
  SessionDrawerModel build() {
    SessionModel? sessionIdModel =
        ref.watch(selectedSessionIdServicesProvider);
    if (sessionIdModel == null) {
      return ref.watch(sessionDrawerStateProvider(const SessionId(value: 0)));
    }
    return ref.watch(sessionDrawerStateProvider(sessionIdModel.sessionId));
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

class SessionDrawerBody extends ConsumerWidget {
  const SessionDrawerBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionDrawer = ref.watch(sessionDrawerControllerProvider);
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerLow, // session drawer 背景色
      child: Column(
        children: [
          const SessionDrawerBar(),
          Expanded(
            child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: switch (sessionDrawer.drawerPage) {
                  DrawerPage.sqlResult => const SessionDrawerSqlResult(),
                  _ => const SessionDrawerMetadata(),
                }),
          ),
        ],
      ),
    );
  }
}

class SessionDrawerBar extends ConsumerWidget {
  final double height;

  const SessionDrawerBar({Key? key, this.height = 36}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionDrawer = ref.watch(sessionDrawerControllerProvider);
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainer, // session drawer bar 背景色
      constraints: BoxConstraints(maxHeight: height),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                ref.read(sessionDrawerControllerProvider.notifier).goToTree();
              },
              icon: (sessionDrawer.drawerPage == DrawerPage.metadataTree)
                  ? Icon(
                      Icons.account_tree_rounded,
                      color:
                          Theme.of(context).colorScheme.primary, // metadata 按钮色
                    )
                  : const Icon(Icons.account_tree_outlined)),
          IconButton(
              onPressed: () {
                ref.read(sessionDrawerControllerProvider.notifier).showSQLResult();
              },
              icon: (sessionDrawer.drawerPage == DrawerPage.sqlResult)
                  ? Icon(
                      Icons.article_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .primary, // sql result 按钮色
                    )
                  : const Icon(Icons.article_outlined)),
          const Spacer(),
          IconButton(
            onPressed: () {
              sessionDrawer.isRightPageOpen
                  ? ref.read(sessionDrawerControllerProvider.notifier).hideRightPage()
                  : ref.read(sessionDrawerControllerProvider.notifier).showRightPage();
            },
            icon: sessionDrawer.isRightPageOpen
                ? const Icon(Icons.format_indent_increase)
                : const Icon(Icons.format_indent_decrease),
          )
        ],
      ),
    );
  }
}
