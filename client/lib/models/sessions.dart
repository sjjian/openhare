import 'package:client/models/instances.dart';
import 'package:objectbox/objectbox.dart';


@Entity()
class SessionModel {
  @Id()
  int id;

  final instance = ToOne<InstanceModel>();

  String? text;

  String? currentSchema;

  SessionModel({
    this.id = 0,
    this.text,
    this.currentSchema,
  });
}