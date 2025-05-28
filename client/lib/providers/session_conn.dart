import 'package:client/core/conn.dart';
import 'package:client/models/interface.dart';
import 'package:client/providers/sessions.dart';
import 'package:client/repositories/repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_conn.g.dart';

@Riverpod(keepAlive: true)
class SessionConnController extends _$SessionConnController {
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

@Riverpod(keepAlive: true)
class SelectedSessionConnController extends _$SelectedSessionConnController {
  @override
  SessionConnModel? build() {
    SelectedSessionId sessionIdModel = ref.watch(selectedSessionIdControllerProvider)!;
    SessionConnModel? model = ref.watch(sessionConnControllerProvider(sessionIdModel.sessionId));
    return model;
  }
}