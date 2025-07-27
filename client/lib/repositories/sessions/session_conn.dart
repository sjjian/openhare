import 'dart:async';

import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
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
      state: conns[connId.value]?.state ?? SQLConnectState.disconnected,
    );
  }

  @override
  SessionConnModel createConn(InstanceModel model, {String? currentSchema}) {
    SessionConn conn = SessionConn(model: model, currentSchema: currentSchema);
    final id = getConnId();
    conns[id] = conn;
    return SessionConnModel(
      connId: ConnId(value: id),
      instanceId: model.id,
      state: conn.state,
    );
  }

  @override
  void removeConn(ConnId connId) {
    conns.remove(connId.value);
  }

  @override
  Future<void> connect(
    ConnId connId, {
    Function()? onStateChangedCallback,
    Function(String)? onSchemaChangedCallback,
  }) {
    return conns[connId.value]!.connect(
      onStateChangedCallback: onStateChangedCallback,
      onSchemaChangedCallback: onSchemaChangedCallback,
    );
  }

  @override
  Future<void> close(ConnId connId) {
    return conns[connId.value]!.close();
  }

  @override
  Future<void> setCurrentSchema(ConnId connId, String schema) async {
    await conns[connId.value]!.setCurrentSchema(schema);
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

  @override
  Future<void> killQuery(ConnId connId) {
    return conns[connId.value]!.killQuery();
  }
}

class SessionConn {
  final InstanceModel model;
  BaseConnection? conn2;
  SQLConnectState state = SQLConnectState.disconnected;
  String? currentSchema;
  Timer? _timer;
  Function()? _onStateChangedCallback;

  SessionConn({
    required this.model,
    this.currentSchema,
  });

  void _setState(SQLConnectState state) {
    this.state = state;
    _onStateChangedCallback?.call();
  }

  Future<void> connect(
      {Function()? onStateChangedCallback,
      Function(String)? onSchemaChangedCallback}) async {
    try {
      if (conn2 != null) {
        await conn2!.close();
      }
      _setState(SQLConnectState.connecting);
      conn2 = await ConnectionFactory.open(
        type: model.dbType,
        meta: model.connectValue,
        schema: currentSchema,
        onSchemaChangedCallback: (schema) {
          currentSchema = schema;
          onSchemaChangedCallback?.call(schema);
        },
      );
      _onStateChangedCallback = onStateChangedCallback;
      _setState(SQLConnectState.connected);
      startHealthCheck();
    } catch (e, s) {
      print("conn error: ${e}; ${s}");
      _setState(SQLConnectState.failed);
    }
  }

  // 后台循环ping进行探活，每隔5秒，如果探活失败则调用 onCloseCallback，并关闭连接
  void startHealthCheck() {
    // 然后每隔5秒检查一次
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkConnection();
    });
  }

  void stopHealthCheck() {
    _timer?.cancel();
  }

  Future<void> _checkConnection() async {
    try {
      if (conn2 == null || state != SQLConnectState.connected) {
        return;
      }
      await conn2!.ping();
      print("Connection $hashCode is alive");
    } catch (e) {
      print("Connection $hashCode check failed: $e");

      _setState(SQLConnectState.unHealth);
      try {
        _onStateChangedCallback?.call();
      } catch (callbackError) {
        print("调用 onCloseCallback 时出错: $callbackError");
      }
    }
  }

  Future<void> close() async {
    if (conn2 == null || state != SQLConnectState.connected) {
      return;
    }
    try {
      stopHealthCheck();
      conn2!.close();
      state = SQLConnectState.disconnected;
      _onStateChangedCallback?.call();
    } catch (e) {
      // todo: handler error;
    }
  }

  bool canQuery() {
    return (conn2 != null && state == SQLConnectState.connected);
  }

  Future<BaseQueryResult?> query(String query) async {
    try {
      _setState(SQLConnectState.executing);
      BaseQueryResult queryResult = await conn2!.query(query);
      return queryResult;
    } catch (e) {
      rethrow;
    } finally {
      _setState(SQLConnectState.connected);
    }
  }

  Future<void> killQuery() async {
    try {
      await conn2!.killQuery();
    } catch (e) {
      print("Failed to kill query: $e");
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
