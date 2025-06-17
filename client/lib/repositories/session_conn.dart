import 'package:client/models/session_conn.dart';
import 'package:client/repositories/instances.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'session_conn.g.dart';

class SessionConnRepoImpl extends SessionConnRepo {
  static int connId = 0;
  Map<int, SessionConn> conns = {};
  SessionConnRepoImpl();

  static int getConnId() {
    return connId++;
  }

  @override
  SessionConnModel getConn(int connId) {
    return SessionConnModel(
        connId: connId,
        currentSchema: conns[connId]?.currentSchema ?? "",
        canQuery: conns[connId]?.canQuery() ?? false);
  }

  @override
  SessionConnModel createConn(InstanceModel model,
      {String? currentSchema}) {
    SessionConn conn = SessionConn(model: model, currentSchema: currentSchema);
    final id = getConnId();
    conns[id] = conn;
    return SessionConnModel(
        connId: id,
        currentSchema: currentSchema ?? "",
        canQuery: conn.canQuery());
  }

  @override
  void removeConn(int connId) {
    conns.remove(connId);
  }

  @override
  Future<void> connect(int connId) {
    return conns[connId]!.connect();
  }

  @override
  Future<void> close(int connId) {
    return conns[connId]!.close();
  }

  @override
  Future<void> onSchemaChanged(int connId, String schema) {
    return conns[connId]!.onSchemaChanged(schema);
  }

  @override
  Future<void> setCurrentSchema(int connId, String schema) {
    return conns[connId]!.setCurrentSchema(schema);
  }

  @override
  Future<List<String>> getSchemas(int connId) {
    return conns[connId]!.getSchemas();
  }

  @override
  Future<MetaDataNode> getMetadata(int connId) {
    return conns[connId]!.metadata();
  }

  @override
  Future<BaseQueryResult?> query(int connId, String query) {
    return conns[connId]!.query(query);
  }
}

enum SQLConnectState { pending, connecting, connected, failed }

enum SQLExecuteState { init, executing, done, error }

class SessionConn {
  final InstanceModel model;
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
      conn2 = await ConnectionFactory.open(
        type: model.dbType,
        meta: model.connectValue,
        schema: currentSchema,
        // onCloseCallback: state.onConnClose,
        // onSchemaChangedCallback: state.onSchemaChanged,
      );
      state = SQLConnectState.connected;
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

  Future<MetaDataNode> metadata() async {
    return await conn2!.metadata();
  }
}

@Riverpod(keepAlive: true)
SessionConnRepo sessionConnRepo(Ref ref) {
  return SessionConnRepoImpl();
}
