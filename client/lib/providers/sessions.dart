import 'package:client/models/interface.dart';
import 'package:client/providers/model.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/models/sessions.dart';
import 'package:client/models/session_sql_result.dart';
import 'package:client/models/instances.dart';
import 'package:client/models/objectbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions.g.dart';

@riverpod
class SessionTabProvider extends _$SessionTabProvider {
  @override
  ReorderSelectedList<BaseSession> build() {
    return ref.watch(sessionRepoProvider).getSessions();
  }

  Future<void> connect(Session session) async {
    // todo
    for (final s in state) {
      if (s == session) {
        await session.connect();
        return;
      }
    }
  }

  Future<void> close(Session session) async {
    for (final s in state) {
      if (s == session) {
        await session.close();
        return;
      }
    }
  }

  void selectSessionByIndex(int index) {
    if (state.select(index)) {
      ref.invalidate(sessionRepoProvider);
    }
  }

  void reorderSession(int oldIndex, int newIndex) {
    state.reorder(oldIndex, newIndex);
    ref.invalidate(sessionRepoProvider);
  }

  void addSession(InstanceModel instance, {String? schema}) {
    print("addSession");
    Session session = Session(SessionStorage());
    session.model.instance.target = instance;
    session.model.currentSchema = schema;

    ObjectBox ob = ref.watch(objectboxProvider);
    // 记录使用的数据源
    ob.addActiveInstance(instance);
    if (schema != null) {
      ob.addInstanceActiveSchema(instance, schema);
    }
    state.replace(state.selected()!, session);

    ref.invalidateSelf();
    ref.invalidate(sessionRepoProvider);
    print("addSession refresh");
    connect(session);
  }

  void newSession() {
    final s = UnInitSession();
    state.add(s);
    ref.invalidate(sessionRepoProvider);
  }

  void deleteSessionByIndex(int index) {
    state.removeAt(index);
    ref.invalidate(sessionRepoProvider);
  }
}

@riverpod
class SessionConnController extends _$SessionConnController {
  @override
  SessionConn build() {
    CurrentSession? session = ref.watch(currentSessionProvider);
    return ref.watch(sessionConnProvider(session!.model.id))!;
  }
  // Future<void> connect() async {
  //   BaseSession? session = ref.watch(currentSessionProvider);
  //   if (session == null || session is UnInitSession) {
  //     return;
  //   }
  //   await state.connect();
  //   ref.invalidateSelf();
  // }
  
  Future<void> connect() async {
    try {
      final conn = await ConnectionFactory.open(
          type: state.model.instance.target!.dbType,
          meta: state.model.instance.target!.connectValue,
          schema: state.model.currentSchema,
          onCloseCallback: state.onConnClose,
          onSchemaChangedCallback: state.onSchemaChanged);
      // state.state = SQLConnectState.connected;
      state = state.copyWith(conn2: conn, state: SQLConnectState.connected);
    } catch (e, s) {
      print("conn error: ${e}; ${s}");
      // state.state = SQLConnectState.failed;
      state = state.copyWith(conn2: null, state: SQLConnectState.failed);
    }
  }

  Future<void> close() async {
    if (conn2 == null || connState != SQLConnectState.connected) {
      return;
    }
    try {
      conn2!.close();
      connState = SQLConnectState.pending;
      conn2 = null;
    } catch (e) {
      // todo: handler error;
    }
  }
}

@riverpod
class SessionController extends _$SessionController {
  @override
  CurrentSession build() {
    return ref.watch(currentSessionProvider)!;
  }

  // void update(Session? targetSession) {
  //   BaseSession? session = ref.watch(currentSessionProvider);
  //   if (session != null) {
  //     session!.unListenCallBack();
  //   }
  //   if (targetSession != null) {
  //     session!.listenCallBack(onConnClose, onSchemaChanged);
  //   }
  //   notifyListeners();
  // }

  // bool initialized() {
  //   return session != null && session!.model.instance.target != null;
  // }

  // Future<void> setConn(InstanceModel instance, {String? schema}) async {
  //   ObjectBox ob = await ref.watch(objectboxProvider);
  //   // 记录使用的数据源
  //   ob.addActiveInstance(instance);
  //   if (schema != null) {
  //     ob.addInstanceActiveSchema(instance, schema);
  //   }
  //   state =
  //   BaseSession? session = ref.watch(currentSessionProvider);
  //   // state as Session;
  //   // state = ;
  //   // state
  //   // state.model.instance.target = instance;
  //   // session!.model.currentSchema = schema;
  //   // notifyListeners();
  // }

  Future<void> connect() async {
    BaseSession? session = ref.watch(currentSessionProvider);
    if (session == null || session is UnInitSession) {
      return;
    }
    await state.connect();
    ref.invalidateSelf();
  }

  // void onConnClose() {
  //   notifyListeners();
  // }

  Future<void> onSchemaChanged(String schema) async {
    BaseSession? session = ref.watch(currentSessionProvider);
    ObjectBox ob = ref.read(objectboxProvider);
    await ob.addInstanceActiveSchema(
        (session as Session).model.instance.target!, schema);
    ref.invalidateSelf();
  }

  Future<void> query(String query, bool newResult) async {
    BaseSession? session = ref.watch(currentSessionProvider);
    if (session == null || session is UnInitSession) {
      return;
    }

    if ((session as Session).connState != SQLConnectState.connected) {
      return;
    }
    SQLResultModel result;

    SQLResultModel? cur = session.sqlResults.selected();
    if (newResult || cur == null) {
      result = SQLResultModel(session.genSQLResultId(), query);
      session.sqlResults.add(result);
    } else {
      result = SQLResultModel(cur.id, query);
      session.sqlResults.replace(cur, result);
    }

    session.showRecord = false; // 如果执行query创建了新的tab则跳转过去
    session.queryState = SQLExecuteState.executing;
    // notifyListeners();

    try {
      DateTime start = DateTime.now();
      BaseQueryResult queryResult = await session.conn2!.query(query);
      List<QueryResultRow> rows = queryResult.rows;
      DateTime end = DateTime.now();
      result.setDone(queryResult.columns, rows, end.difference(start),
          queryResult.affectedRows.toInt());
      session.queryState = SQLExecuteState.done;
    } catch (e) {
      result.setError(e.toString());
      session.queryState = SQLExecuteState.error;
    } finally {
      // notifyListeners();
    }
  }

  Future<void> setCurrentSchema(String schema) async {
    BaseSession? session = ref.watch(currentSessionProvider);
    if (session == null || session is UnInitSession) {
      return;
    }
    await (session as Session).conn2!.setCurrentSchema(schema);
    ref.invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class SessionDrawerController extends _$SessionDrawerController {
  @override
  CurrentSessionDrawer build() {
    CurrentSession? session = ref.watch(currentSessionProvider);
    return ref.watch(sessionDrawerStateProvider(session!.model.id))!;
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
