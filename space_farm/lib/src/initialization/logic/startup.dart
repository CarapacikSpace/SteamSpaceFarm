import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:space_farm/src/initialization/logic/composition_root.dart';
import 'package:space_farm/src/initialization/widget/initialization_failed_app.dart';
import 'package:space_farm/src/initialization/widget/root_context.dart';
import 'package:window_manager/window_manager.dart';

Future<void> startup() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      Future<void> composeAndRun() async {
        try {
          final compositionResult = await composeDependencies();
          if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
            await windowManager.ensureInitialized();
            const windowOptions = WindowOptions(
              minimumSize: Size(450, 600),
              size: Size(1280, 760),
              center: true,
              skipTaskbar: false,
            );
            await windowManager.waitUntilReadyToShow(windowOptions, () async {
              await windowManager.show();
              await windowManager.focus();
            });
          }
          runApp(RootContext(compositionResult: compositionResult));
        } on Object catch (e, st) {
          log('Initialization failed', error: e, stackTrace: st);
          runApp(InitializationFailedApp(error: e, stackTrace: st, onRetryInitialization: composeAndRun));
        }
      }

      await composeAndRun();
    },
    (e, st) {
      log('E:', error: e, stackTrace: st);
    },
  );
}
