import 'package:client/screens/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/test.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    title: "Flea SQL",
    // size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(ChangeNotifierProvider(
      create: (_) => PageNotifier(), child: const FleaSQLApp()));
}
