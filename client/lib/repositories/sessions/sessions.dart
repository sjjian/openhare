import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/repositories/instances/instances.dart';
import 'package:objectbox/objectbox.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/repositories/repo.dart';
import 'package:client/utils/reorder_list.dart';

part 'sessions.g.dart';

@Entity()
class SessionStorage {
  @Id()
  int id;

  final instance = ToOne<InstanceStorage>();

  String? text;

  String? currentSchema;

  SessionStorage({
    this.id = 0,
    this.text,
    this.currentSchema,
  });
}

class SessionRepoImpl extends SessionRepo {
  final ObjectBox ob;
  final Box<SessionStorage> _sessionBox;
  ReorderSelectedList<SessionStorage>? _sessionCache;

  final Map<int, ConnId> _connIdMap = {};

  SessionRepoImpl(this.ob) : _sessionBox = ob.store.box();

  void _refreshSessionCache() {
    _sessionCache = ReorderSelectedList(data: _sessionBox.getAll());
  }

  ReorderSelectedList<SessionStorage> get _sessions {
    if (_sessionCache == null) {
      _refreshSessionCache();
    }
    return _sessionCache!;
  }

  SessionModel toModel(SessionStorage session) {
    return SessionModel(
      sessionId: SessionId(value: session.id),
      instanceId: session.instance.target != null
          ? InstanceId(value: session.instance.target!.id)
          : null,
      instanceName: session.instance.target?.name,
      currentSchema: session.currentSchema,
      dbType: session.instance.target?.dbType,
      connId: _connIdMap[session.id],
    );
  }

  @override
  SessionModel? getSession(SessionId sessionId) {
    final session = _sessionBox.get(sessionId.value);
    return session != null ? toModel(session) : null;
  }

  @override
  Future<SessionModel> newSession() async {
    final session = await _sessionBox.putAndGetAsync(SessionStorage());
    _sessions.add(session);
    return SessionModel(sessionId: SessionId(value: session.id));
  }

  @override
  Future<void> updateSession(SessionId sessionId,
      {InstanceModel? instance, String? currentSchema}) async {
    final session = _sessions
        .firstWhere((s) => s.id == sessionId.value); //todo: handler null

    if (instance != null) {
      session.instance.target = InstanceStorage.fromModel(instance);
    }
    if (currentSchema != null) {
      session.currentSchema = currentSchema;
    }
    await _sessionBox.putAsync(session);
  }

  @override
  void setConnId(SessionId sessionId, ConnId connId) {
    _connIdMap[sessionId.value] = connId;
  }

  @override
  void unsetConnId(SessionId sessionId) {
    _connIdMap.remove(sessionId.value);
  }

  @override
  Future<void> deleteSession(SessionId sessionId) async {
    _sessions.removeAt(
        _sessions.indexWhere((session) => session.id == sessionId.value));
    await _sessionBox.removeAsync(sessionId.value);
  }

  @override
  SessionListModel getSessions() {
    final selected = _sessions.selected();
    return SessionListModel(
      sessions: _sessions.map((s) {
        return toModel(s);
      }).toList(),
      selectedSession: selected != null ? toModel(selected) : null,
    );
  }

  @override
  void selectSessionByIndex(int index) {
    if (_sessions.select(index)) {}
  }

  @override
  void reorderSession(int oldIndex, int newIndex) {
    _sessions.reorder(oldIndex, newIndex);
  }
}

@Riverpod(keepAlive: true)
SessionRepo sessionRepo(Ref ref) {
  ObjectBox ob = ref.watch(objectboxProvider);
  return SessionRepoImpl(ob);
}
