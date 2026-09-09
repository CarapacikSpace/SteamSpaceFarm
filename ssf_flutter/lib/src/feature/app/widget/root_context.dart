import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/app/logic/composition_root.dart';
import 'package:ssf_flutter/src/feature/app/widget/dependencies_scope.dart';
import 'package:ssf_flutter/src/feature/app/widget/material_context.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/logging/app_logger.dart';
import 'package:ssf_flutter/src/ui_kit/overlay/steam_notice.dart';

class const RootContext({required final CompositionResult compositionResult, super.key}) extends StatefulWidget {
  @override
  State<RootContext> createState() => _RootContextState();
}

class _RootContextState() extends State<RootContext> {
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onExitRequested: _requestExit);
  }

  Future<AppExitResponse> _requestExit() async {
    try {
      await widget.compositionResult.dependencies.processManager.shutdown();
      return AppExitResponse.exit;
    } on Object catch (error, stack) {
      AppLogger.error('Could not stop all processes', error, stack);
      _messenger.currentState?.showSnackBar(steamNotice(GeneratedLocalizations.current.stopAllProcessesFailed));
      return AppExitResponse.cancel;
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    unawaited(
      widget.compositionResult.dependencies.processManager.shutdown().catchError((Object error, StackTrace stack) {
        AppLogger.error('Process cleanup failed', error, stack);
      }),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DependenciesScope(
    dependencies: widget.compositionResult.dependencies,
    child: MaterialContext(messengerKey: _messenger),
  );
}
