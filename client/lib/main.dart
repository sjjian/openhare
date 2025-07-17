import 'package:client/repositories/repo.dart';
import 'package:client/screens/app.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  await initObjectbox();

  await ConnectionFactory.init();

  runApp(ProviderScope(child: App()));

  doWhenWindowReady(() {
    const initialSize = Size(1400, 1000);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}
