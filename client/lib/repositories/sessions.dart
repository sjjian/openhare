import 'package:client/models/sessions.dart';
import 'package:client/repositories/instances.dart';
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

  final instance = ToOne<InstanceModel>();

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

  @override
  SessionModel? getSession(int id) {
    final session = _sessionBox.get(id);
    return session != null
        ? SessionModel(
            sessionId: session.id,
            instanceId: session.instance.target?.id,
            instanceName: session.instance.target?.name,
            dbType: session.instance.target?.dbType,
          )
        : null;
  }

  @override
  Future<SessionModel> newSession() async {
    final session = SessionStorage();
    _sessions.add(session);
    final id = await _sessionBox.putAsync(session);
    return SessionModel(sessionId: id);
  }

  @override
  Future<void> updateSession(
      SessionModel model, InstanceModel instance, String currentSchema) async {
    final target = await _sessionBox.getAsync(model.sessionId);
    if (target == null) {
      return;
    }
    target.instance.target = instance;
    target.currentSchema = currentSchema;
    _sessionBox.putAsync(target);
  }

  @override
  Future<void> deleteSession(SessionModel model) async {
    _sessionCache!.removeWhere((session) => session.id == model.sessionId);
    _sessionBox.removeAsync(model.sessionId);
  }

  @override
  SessionListModel getSessions() {
    return SessionListModel(
      sessions: _sessions.map((s) {
        return SessionModel(
          sessionId: s.id,
          instanceId: s.instance.target?.id,
          instanceName: s.instance.target?.name,
          dbType: s.instance.target?.dbType,
        );
      }).toList(),
      selectedSession: _sessions.isNotEmpty
          ? SessionModel(
              sessionId: _sessions.selected()?.id ?? 0,
              instanceId: _sessions.selected()?.instance.target?.id,
              instanceName: _sessions.selected()?.instance.target?.name,
              dbType: _sessions.selected()?.instance.target?.dbType)
          : null,
    );
  }

  @override
  void selectSessionByIndex(int index) {
    if (_sessions.select(index)) {
      _refreshSessionCache();
    }
  }

  @override
  void reorderSession(int oldIndex, int newIndex) {
    _sessions.reorder(oldIndex, newIndex);
    _refreshSessionCache();
  }
}

@Riverpod(keepAlive: true)
SessionRepo sessionRepo(Ref ref) {
  ObjectBox ob = ref.watch(objectboxProvider);
  return SessionRepoImpl(ob);
}
