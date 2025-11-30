import 'package:client/repositories/repo.dart';
import 'package:client/screens/app.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

void main(List<String> args) async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  // 确保应用只运行一个实例
  await WindowsSingleInstance.ensureSingleInstance(
    args,
    "openhare",
    onSecondWindow: (args) {},
  );

  await initObjectbox();

  await ConnectionFactory.init();

  await windowManager.ensureInitialized();

  runApp(ProviderScope(child: App()));

  doWhenWindowReady(() {
    const initialSize = Size(1400, 1000);
    appWindow.minSize = const Size(950, 600);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}
