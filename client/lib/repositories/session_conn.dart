import 'package:client/models/instances.dart';
import 'package:client/models/session_conn.dart';
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
  SessionConnModel getConn(ConnId connId) {
    return SessionConnModel(
        connId: connId,
        instanceId: conns[connId.value]?.model.id ?? const InstanceId(value: 0),
        currentSchema: conns[connId.value]?.currentSchema ?? "",
        canQuery: conns[connId.value]?.canQuery() ?? false);
  }

  @override
  SessionConnModel createConn(InstanceModel model, {String? currentSchema}) {
    SessionConn conn = SessionConn(model: model, currentSchema: currentSchema);
    final id = getConnId();
    conns[id] = conn;
    return SessionConnModel(
        connId: ConnId(value: id),
        instanceId: model.id,
        currentSchema: currentSchema ?? "",
        canQuery: conn.canQuery());
  }

  @override
  void removeConn(ConnId connId) {
    conns.remove(connId.value);
  }

  @override
  Future<void> connect(
    ConnId connId, {
    Function()? onCloseCallback,
    Function(String)? onSchemaChangedCallback,
  }) {
    return conns[connId.value]!.connect(
      onCloseCallback: onCloseCallback,
      onSchemaChangedCallback: onSchemaChangedCallback,
    );
  }

  @override
  Future<void> close(ConnId connId) {
    return conns[connId.value]!.close();
  }

  @override
  Future<void> setCurrentSchema(ConnId connId, String schema) {
    return conns[connId.value]!.setCurrentSchema(schema);
  }

  @override
  Future<List<String>> getSchemas(ConnId connId) {
    return conns[connId.value]!.getSchemas();
  }

  @override
  Future<MetaDataNode> getMetadata(ConnId connId) {
    return conns[connId.value]!.metadata();
  }

  @override
  Future<BaseQueryResult?> query(ConnId connId, String query) {
    return conns[connId.value]!.query(query);
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

  Future<void> connect(
      {Function()? onCloseCallback,
      Function(String)? onSchemaChangedCallback}) async {
    try {
      conn2 = await ConnectionFactory.open(
        type: model.dbType,
        meta: model.connectValue,
        schema: currentSchema,
        onCloseCallback: () {
          state = SQLConnectState.pending;
          onCloseCallback?.call();
        },
        onSchemaChangedCallback: (schema) {
          currentSchema = schema;
          onSchemaChangedCallback?.call(schema);
        },
      );
      state = SQLConnectState.connected;
    } catch (e, s) {
      print("conn error: ${e}; ${s}");
      state = SQLConnectState.failed;
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
