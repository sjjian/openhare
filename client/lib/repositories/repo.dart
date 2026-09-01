import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

import 'objectbox.g.dart';

part 'repo.g.dart';

late ObjectBox _objectbox;
ObjectBox get defaultObjectBox => _objectbox;

Future<void> initObjectbox() async {
  _objectbox = await ObjectBox.create();
}

class ObjectBox {
  /// The Store of this app.
  final Store store;

  ObjectBox(this.store);

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final appSupportDir = await getApplicationSupportDirectory();
    final storePath = p.join(appSupportDir.path, "data");
    debugPrint("load store from: $storePath");
    final store = await openStore(directory: storePath);
    return ObjectBox(store);
  }
}

@Riverpod(keepAlive: true)
ObjectBox objectbox(Ref ref) {
  return _objectbox;
}
