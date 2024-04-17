class InstanceModel {
  String name;
  String? desc;
  String addr;
  int port;
  String user;
  String password;

  InstanceModel(
      {required this.name,
      this.desc,
      required this.addr,
      required this.port,
      required this.user,
      required this.password});
}

final instances = List<InstanceModel>.empty(growable: true);