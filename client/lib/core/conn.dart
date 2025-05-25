import 'package:db_driver/db_driver.dart';
import 'package:client/repositories/sessions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'conn.g.dart';

// @riverpod
// class SessionConnController extends _$SessionConnController {
//   @override
//   SessionConn build(int sessionId) {
//     SessionConn conn = ref.watch(sessionConnProvider(sessionId));
//     print("session conn controller: $sessionId, hash: ${conn.hashCode}");
//     return conn;
//   }

//   Future<void> connect() async {
//     if (state.state!= SQLConnectState.pending) {
//       return;
//     }
//     try {
//       print("conn session id: ${state.model.id}");
//       final conn = await ConnectionFactory.open(
//         type: state.model.instance.target!.dbType,
//         meta: state.model.instance.target!.connectValue,
//         schema: state.model.currentSchema,
//         // onCloseCallback: state.onConnClose,
//         // onSchemaChangedCallback: state.onSchemaChanged,
//       );
//       state = state.copyWith(conn2: conn, state: SQLConnectState.connected);
//     } catch (e, s) {
//       print("conn error: ${e}; ${s}");
//       state = state.copyWith(conn2: null, state: SQLConnectState.failed);
//     }
//   }

//   Future<void> close() async {
//     print("close session id: ${state.model.id}");
//     if (state.conn2 == null || state.state != SQLConnectState.connected) {
//       return;
//     }
//     try {
//       state.conn2!.close();
//       state = state.copyWith(conn2: null, state: SQLConnectState.pending);
//     } catch (e) {
//       // todo: handler error;
//     }
//   }

//   bool canQuery() {
//     return (state.queryState != SQLExecuteState.executing &&
//         state.state == SQLConnectState.connected);
//   }

//   // Future<SQLResultModel?> query(String query, bool newResult) async {
//   //   if (state.state != SQLConnectState.connected) {
//   //     return null;
//   //   }
//   //   SQLResultModel result = ;

//   //   SQLResultModel? cur = session.sqlResults.selected();
//   //   if (newResult || cur == null) {
//   //     result = SQLResultModel(session.genSQLResultId(), query);
//   //     session.sqlResults.add(result);
//   //   } else {
//   //     result = SQLResultModel(cur.id, query);
//   //     session.sqlResults.replace(cur, result);
//   //   }

//   //   // session.showRecord = false; // 如果执行query创建了新的tab则跳转过去
//   //   // session.queryState = SQLExecuteState.executing;
//   //   // notifyListeners();

//   //   try {
//   //     DateTime start = DateTime.now();
//   //     BaseQueryResult queryResult = await state.conn2!.query(query);
//   //     List<QueryResultRow> rows = queryResult.rows;
//   //     DateTime end = DateTime.now();
//   //     result.setDone(queryResult.columns, rows, end.difference(start),
//   //         queryResult.affectedRows.toInt());
//   //     // state = state.copyWith(
//   //     //     state: SQLExecuteState.done);
//   //     // session.queryState = SQLExecuteState.done;
//   //   } catch (e) {
//   //     result.setError(e.toString());
//   //     // session.queryState = SQLExecuteState.error;
//   //   } finally {
//   //     // notifyListeners();
//   //   }
//   //   return result;
//   // }

//   Future<void> onSchemaChanged(String schema) async {
//     ObjectBox ob = ref.read(objectboxProvider);
//     await ob.addInstanceActiveSchema(state.model.instance.target!, schema);
//     state = state.copyWith(currentSchema: schema);
//   }

//   Future<void> setCurrentSchema(String schema) async {
//     await state.conn2!.setCurrentSchema(schema);
//     state = state.copyWith(currentSchema: schema);
//   }

//   Future<List<String>> getSchemas() async {
//     List<String> schemas = await state.conn2!.schemas();
//     return schemas;
//   }
// }

class ConnManager {
  Map<int, SessionConn> conns = {};
  ConnManager();

  SessionConn? getConn(int sessionId) {
    return conns[sessionId];
  }

  SessionConn createConn(SessionStorage model, {String? currentSchema}) {
    SessionConn conn = SessionConn(model: model, currentSchema: currentSchema);
    conns[model.id] = conn;
    return conn;
  }

  void removeConn(int sessionId) {
    conns.remove(sessionId);
  }
}

enum SQLConnectState { pending, connecting, connected, failed }

enum SQLExecuteState { init, executing, done, error }

class SessionConn {
  final SessionStorage model;
  BaseConnection? conn2;
  SQLConnectState state = SQLConnectState.pending;
  SQLExecuteState queryState = SQLExecuteState.init;
  String? currentSchema;

  SessionConn({
    required this.model,
    this.currentSchema,
  });

  Future<void> connect() async {
    try {
      print("conn session id: ${model.id}");
      conn2 = await ConnectionFactory.open(
        type: model.instance.target!.dbType,
        meta: model.instance.target!.connectValue,
        schema: model.currentSchema,
        // onCloseCallback: state.onConnClose,
        // onSchemaChangedCallback: state.onSchemaChanged,
      );
      //  = state.copyWith(conn2: conn, state: SQLConnectState.connected);
    } catch (e, s) {
      print("conn error: ${e}; ${s}");
      state = SQLConnectState.failed;
      // state = state.copyWith(conn2: null, state: SQLConnectState.failed);
    }
  }

  Future<void> close() async {
    if (conn2 == null || state != SQLConnectState.connected) {
      return;
    }
    try {
      conn2!.close();
      state = SQLConnectState.pending;
    } catch (e) {
      // todo: handler error;
    }
  }

  bool canQuery() {
    return (queryState != SQLExecuteState.executing &&
        state == SQLConnectState.connected);
  }

  Future<BaseQueryResult?> query(String query) async {
    try {
      queryState = SQLExecuteState.executing;
      BaseQueryResult queryResult = await conn2!.query(query);
      return queryResult;
    } catch (e) {
      rethrow;
    } finally {
      queryState = SQLExecuteState.init;
    }
  }

  Future<void> onSchemaChanged(String schema) async {
    // ObjectBox ob = ref.read(objectboxProvider);
    // await ob.addInstanceActiveSchema(state.model.instance.target!, schema);
    // state = state.copyWith(currentSchema: schema);
    currentSchema = schema;
  }

  Future<void> setCurrentSchema(String schema) async {
    await conn2!.setCurrentSchema(schema);
    currentSchema = schema;
  }

  Future<List<String>> getSchemas() async {
    List<String> schemas = await conn2!.schemas();
    return schemas;
  }
}

@Riverpod(keepAlive: true)
ConnManager connManager(Ref ref, int sessionId) {
  return ConnManager();
}

@Riverpod(keepAlive: true)
SessionConn sessionConn(Ref ref, int sessionId) {
  ConnManager connManager = ref.watch(connManagerProvider(sessionId));
  SessionStorage model = ref.watch(sessionRepoProvider).getSession(sessionId)!;
  SessionConn? conn = connManager.getConn(sessionId);
  conn ??= connManager.createConn(model);
  return conn;
}
