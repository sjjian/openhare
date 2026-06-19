import 'dart:async';

import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'session_conn.g.dart';

class SessionConnRepoImpl extends SessionConnRepo {
  static int connId = 0;
  Map<int, SessionConn> conns = {};
  SessionConnRepoImpl();

  static int getConnId() {
    return connId++;
  }

  @override
  SessionConnListModel getConns() {
    return SessionConnListModel(
      conns: conns.map(
        (key, value) => MapEntry(
          ConnId(value: key),
          SessionConnModel(
            connId: ConnId(value: key),
            state: value.state,
            errorMsg: value.errorMsg,
          ),
        ),
      ),
    );
  }

  @override
  SessionConnModel getConn(ConnId connId) {
    return SessionConnModel(
      connId: connId,
      state: conns[connId.value]?.state ?? SQLConnectState.disconnected,
    );
  }

  @override
  SessionConnModel createConn(InstanceModel model, {DatabaseRef? currentSchema}) {
    SessionConn conn = SessionConn(
      model: model,
      currentSchema: currentSchema,
    );
    final id = getConnId();
    conns[id] = conn;
    return SessionConnModel(
      connId: ConnId(value: id),
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
    Function(DatabaseRef)? onSchemaChangedCallback,
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
  Future<void> setCurrentSchema(ConnId connId, DatabaseRef schema) async {
    await conns[connId.value]!.setCurrentSchema(schema);
  }

  @override
  Future<BaseQueryResult?> query(ConnId connId, String query, {int? limit}) {
    return conns[connId.value]!.query(query, limit: limit);
  }

  @override
  Stream<BaseQueryStreamItem> queryStream(ConnId connId, String query) {
    return conns[connId.value]!.queryStream(query);
  }

  @override
  Future<void> killQuery(ConnId connId) async {
    final conn = conns[connId.value];
    if (conn == null) {
      return;
    }
    if (conn.state != SQLConnectState.executing) {
      return;
    }
    return conn.killQuery();
  }

  @override
  bool supportsKillQuery(ConnId connId) {
    return conns[connId.value]?.supportsKillQuery ?? false;
  }
}

class SessionConn {
  final InstanceModel model;
  BaseConnection? conn2;
  SQLConnectState state = SQLConnectState.disconnected;
  String? errorMsg;
  DatabaseRef? currentSchema;
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

  Future<void> connect({
    Function()? onStateChangedCallback,
    Function(DatabaseRef)? onSchemaChangedCallback,
  }) async {
    try {
      _onStateChangedCallback = onStateChangedCallback;
      if (conn2 != null) {
        await conn2!.close();
      }
      _setState(SQLConnectState.connecting);
      conn2 = await ConnectionWrapper.open(
        type: model.dbType,
        meta: model.connectValue,
        schema: currentSchema,
        onSchemaChangedCallback: (schema) {
          currentSchema = schema;
          onSchemaChangedCallback?.call(schema);
        },
      );
      _setState(SQLConnectState.connected);
      startHealthCheck();
    } catch (e) {
      errorMsg = e.toString();
      _setState(SQLConnectState.failed);
      rethrow;
    }
  }

  // 后台循环ping进行探活，每隔5秒，如果探活失败则调用 onCloseCallback，并关闭连接
  void startHealthCheck() {
    // 然后每隔60秒检查一次, todo: 可配置
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
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
      debugPrint("Connection $hashCode is alive");
    } catch (e) {
      debugPrint("Connection $hashCode check failed: $e");

      _setState(SQLConnectState.unHealth);
      try {
        _onStateChangedCallback?.call();
      } catch (callbackError) {
        debugPrint("调用 onCloseCallback 时出错: $callbackError");
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

  Future<BaseQueryResult?> query(String query, {int? limit}) async {
    try {
      _setState(SQLConnectState.executing);
      BaseQueryResult queryResult = await conn2!.query(query, limit: limit);
      return queryResult;
    } catch (e) {
      rethrow;
    } finally {
      _setState(SQLConnectState.connected);
    }
  }

  Stream<BaseQueryStreamItem> queryStream(String query) async* {
    try {
      _setState(SQLConnectState.executing);
      await for (final item in conn2!.queryStream(query)) {
        yield item;
      }
    } finally {
      _setState(SQLConnectState.connected);
    }
  }

  Future<void> killQuery() async {
    try {
      await conn2!.killQuery();
    } catch (e) {
      debugPrint("Failed to kill query: $e");
    }
  }

  bool get supportsKillQuery => conn2?.supportsKillQuery ?? false;

  Future<void> setCurrentSchema(DatabaseRef schema) async {
    await conn2!.setCurrentSchema(schema);
    currentSchema = await conn2!.getCurrentSchema() ?? schema;
  }

  Future<List<MetaDataNode>> metadata() async {
    return await conn2!.metadata();
  }

  Future<String> version() async {
    return await conn2!.version();
  }

  Future<List<DatabaseRef>> schemas() async {
    return await conn2!.schemas();
  }

  Future<DatabaseModeType> getDatabaseMode() async {
    return await conn2!.getDatabaseMode();
  }
}

@Riverpod(keepAlive: true)
SessionConnRepo sessionConnRepo(Ref ref) {
  return SessionConnRepoImpl();
}
