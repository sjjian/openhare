import 'package:client/repositories/instances.dart';
import 'package:objectbox/objectbox.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/repositories/repo.dart';

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

class SessionRepo {
  final ObjectBox ob;
  final Box<SessionStorage> _sessionBox;

  SessionRepo(this.ob) : _sessionBox = ob.store.box();

  SessionStorage? getSession(int id) {
    return _sessionBox.get(id);
  }

  Future<void> addSession(SessionStorage session) =>
      _sessionBox.putAsync(session);

  Future<void> updateSession(SessionStorage target) async {
    _sessionBox.putAsync(target);
  }

  Future<void> deleteSession(SessionStorage session) =>
      _sessionBox.removeAsync(session.id);

  List<SessionStorage> getSessions() {
    return _sessionBox.getAll();
  }
}

@Riverpod(keepAlive: true)
SessionRepo sessionRepo(Ref ref) {
  ObjectBox ob = ref.watch(objectboxProvider);
  return SessionRepo(ob);
}
