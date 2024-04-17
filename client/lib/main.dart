import 'package:client/providers/pages.dart';
import 'package:client/screens/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    title: "Flea SQL",
    size: Size(1400, 1000),
    center: true,
    // titleBarStyle: TitleBarStyle.hidden,
    // backgroundColor: Colors.transparent,
    backgroundColor: Colors.grey,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const FleaSQLApp());
}
