import 'package:client/repositories/repo.dart';
import 'package:client/screens/app.dart';
import 'package:client/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

void main(List<String> args) async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  await bootLogger.init();
  log.i('flutter binding initialized, args=$args');

  // 加载字体，防止异步换入时字距跳变。
  try {
    GoogleFonts.config.allowRuntimeFetching = false;
    await GoogleFonts.pendingFonts([GoogleFonts.robotoMono(), GoogleFonts.notoSansSc()]);
    log.i('fonts preloaded');
  } catch (e, st) {
    log.e('fonts preload failed, falling back to system fonts', error: e, stackTrace: st);
  }

  try {
    log.i('single instance ensuring');
    await WindowsSingleInstance.ensureSingleInstance(
      args,
      "openhare",
      onSecondWindow: (args) {
        log.i('second instance signaled, args=$args');
      },
    );
    log.i('single instance ensured');

    log.i('objectbox initializing');
    await initObjectbox();
    log.i('objectbox initialized');

    log.i('window manager initializing');
    await windowManager.ensureInitialized();
    log.i('window manager initialized');

    log.i('app running');
    runApp(
      ProviderScope(
        retry: (retryCount, error) => null,
        child: App(),
      ),
    );

    doWhenWindowReady(() {
      log.i('window initializing');
      const initialSize = Size(1600, 1000);
      appWindow.minSize = const Size(950, 600);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
      log.i('window shown');
    });
  } catch (e, st) {
    log.e('startup failed', error: e, stackTrace: st);
    rethrow;
  }
}
