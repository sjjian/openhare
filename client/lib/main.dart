import 'package:client/screens/app.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:client/models/objectbox.dart';

void main() async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();
  await ObjectBox.create();
  
  runApp(const App());

  doWhenWindowReady(() {
    const initialSize = Size(1400, 1000);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}
