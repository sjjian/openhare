import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'objectbox.g.dart';

part 'repo.g.dart';

late ObjectBox _objectbox;

Future<void> initObjectbox() async {
  _objectbox = await ObjectBox.create();
}

class ObjectBox {
  /// The Store of this app.
  final Store store;

  ObjectBox(this.store);

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    print("load store from: ${p.join(docsDir.path, "openhare")}");
    final store = await openStore(
        directory: p.join(docsDir.path, "openhare"),
        macosApplicationGroup: "openhare.store");
    return ObjectBox(store);
  }

}

@Riverpod(keepAlive: true)
ObjectBox objectbox(Ref ref) {
  return _objectbox;
}
