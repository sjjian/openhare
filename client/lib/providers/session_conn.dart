import 'package:client/core/conn.dart';
import 'package:client/models/interface.dart';
import 'package:client/repositories/repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_conn.g.dart';

@riverpod
class SessionConnController extends _$SessionConnController {
  @override
  SessionConnModel build(int sessionId) {
    SessionConn conn = ref.watch(sessionConnProvider(sessionId));
    print("session conn controller: $sessionId, hash: ${conn.hashCode}");
    return SessionConnModel(conn: conn);
  }

  Future<void> connect() async {
    await state.conn.connect();
    state = state.copyWith(conn: state.conn);
  }

  Future<void> close() async {
    await state.conn.close();
    state = state.copyWith(conn: state.conn);
    // print("close session id: ${state.model.id}");
    // if (state.conn2 == null || state.state != SQLConnectState.connected) {
    //   return;
    // }
    // try {
    //   state.conn2!.close();
    //   state = state.copyWith(conn2: null, state: SQLConnectState.pending);
    // } catch (e) {
    //   // todo: handler error;
    // }
  }

  // bool canQuery() {

  //   return (state.queryState != SQLExecuteState.executing &&
  //       state.state == SQLConnectState.connected);
  // }

  // Future<SQLResultModel?> query(String query, bool newResult) async {
  //   if (state.state != SQLConnectState.connected) {
  //     return null;
  //   }
  //   SQLResultModel result = ;

  //   SQLResultModel? cur = session.sqlResults.selected();
  //   if (newResult || cur == null) {
  //     result = SQLResultModel(session.genSQLResultId(), query);
  //     session.sqlResults.add(result);
  //   } else {
  //     result = SQLResultModel(cur.id, query);
  //     session.sqlResults.replace(cur, result);
  //   }

  //   // session.showRecord = false; // 如果执行query创建了新的tab则跳转过去
  //   // session.queryState = SQLExecuteState.executing;
  //   // notifyListeners();

  //   try {
  //     DateTime start = DateTime.now();
  //     BaseQueryResult queryResult = await state.conn2!.query(query);
  //     List<QueryResultRow> rows = queryResult.rows;
  //     DateTime end = DateTime.now();
  //     result.setDone(queryResult.columns, rows, end.difference(start),
  //         queryResult.affectedRows.toInt());
  //     // state = state.copyWith(
  //     //     state: SQLExecuteState.done);
  //     // session.queryState = SQLExecuteState.done;
  //   } catch (e) {
  //     result.setError(e.toString());
  //     // session.queryState = SQLExecuteState.error;
  //   } finally {
  //     // notifyListeners();
  //   }
  //   return result;
  // }

  Future<void> onSchemaChanged(String schema) async {
    ObjectBox ob = ref.read(objectboxProvider);
    await ob.addInstanceActiveSchema(state.conn.model.instance.target!, schema);
    state.conn.onSchemaChanged(schema);
    state = state.copyWith(conn: state.conn);
  }

  Future<void> setCurrentSchema(String schema) async {
    await state.conn.setCurrentSchema(schema);
    state = state.copyWith(conn: state.conn);
  }

  Future<List<String>> getSchemas() async {
    List<String> schemas = await state.conn.getSchemas();
    return schemas;
  }
}