import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';

class Storage {
  List<InstanceModel> instances;
  List<SessionModel> sessions;

  Storage(this.instances, this.sessions);
}
