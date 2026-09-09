import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:ssf_flutter/src/feature/app/logic/composition_root.dart';
import 'package:ssf_flutter/src/feature/app/widget/initialization_failed_app.dart';
import 'package:ssf_flutter/src/feature/app/widget/root_context.dart';
import 'package:ssf_flutter/src/logging/app_logger.dart';

Future<void> startup() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) =>
        AppLogger.error('Flutter', details.exception, details.stack ?? StackTrace.current);
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      AppLogger.error('Platform', error, stack);
      return true;
    };
    Future<void> composeAndRun() async {
      try {
        final CompositionResult result = await composeDependencies();
        runApp(RootContext(compositionResult: result));
      } on Object catch (error, stack) {
        AppLogger.error('Initialization failed', error, stack);
        runApp(InitializationFailedApp(error: error, stackTrace: stack, onRetryInitialization: composeAndRun));
      }
    }

    await composeAndRun();
  }, (error, stack) => AppLogger.error('Unhandled error', error, stack));
}
