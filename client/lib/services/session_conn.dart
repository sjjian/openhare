import 'package:client/core/conn.dart';
import 'package:client/models/interface.dart';
import 'package:client/repositories/repo.dart';
import 'package:client/services/sessions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_conn.g.dart';

@Riverpod(keepAlive: true)
class SessionConnServices extends _$SessionConnServices {
  @override
  SessionConnModel build(int sessionId) {
    SessionConn conn = ref.watch(sessionConnProvider(sessionId));
    return SessionConnModel(conn: conn);
  }

  Future<void> connect() async {
    await state.conn.connect();
    state = state.copyWith(conn: state.conn);
  }

  Future<void> close() async {
    await state.conn.close();
    state = state.copyWith(conn: state.conn);
  }

  Future<void> onSchemaChanged(String schema) async {
    ObjectBox ob = ref.read(objectboxProvider);
    await ob.addInstanceActiveSchema(state.conn.model, schema);
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

@Riverpod(keepAlive: true)
class SelectedSessionConnController extends _$SelectedSessionConnController {
  @override
  SessionConnModel? build() {
    SelectedSessionId? sessionIdModel = ref.watch(selectedSessionIdServicesProvider);
    if (sessionIdModel == null) {
      return null;
    }
    SessionConnModel? model = ref.watch(sessionConnServicesProvider(sessionIdModel.sessionId));
    return model;
  }
}