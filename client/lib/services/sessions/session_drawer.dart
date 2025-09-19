import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_drawer.g.dart';

@Riverpod(keepAlive: true)
class SessionDrawerServices extends _$SessionDrawerServices {
  @override
  SessionDrawerModel build(SessionId sessionId) {
    return SessionDrawerModel(
        sessionId: sessionId,
        drawerPage: DrawerPage.metadataTree,
        sqlResult: null,
        sqlColumn: null,
        showRecord: false,
        isRightPageOpen: true);
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
    state = state.copyWith(drawerPage: DrawerPage.metadataTree);
  }

  void showChat() {
    state = state.copyWith(drawerPage: DrawerPage.aiChat);
  }
}

@Riverpod(keepAlive: true)
class SessionDrawerNotifier extends _$SessionDrawerNotifier {
  @override
  SessionDrawerModel build() {
    SessionModel? sessionModel = ref.watch(selectedSessionNotifierProvider);
    if (sessionModel == null) {
      return ref
          .watch(sessionDrawerServicesProvider(const SessionId(value: 0)));
    }
    return ref.watch(sessionDrawerServicesProvider(sessionModel.sessionId));
  }
}
