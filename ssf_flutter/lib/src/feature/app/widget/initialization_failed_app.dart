import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/localization/localization.dart';
import 'package:ssf_flutter/src/localization/localization_context.dart';
import 'package:ssf_flutter/src/ui_kit/steam_theme.dart';

class const InitializationFailedApp({
  required final Object error,
  required final StackTrace stackTrace,
  final Future<void> Function()? onRetryInitialization,
  super.key,
}) extends StatefulWidget {
  @override
  State<InitializationFailedApp> createState() => _InitializationFailedAppState();
}

class _InitializationFailedAppState() extends State<InitializationFailedApp> {
  bool _busy = false;

  Future<void> _retry() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onRetryInitialization?.call();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: Localization.deviceLocale,
    localizationsDelegates: Localization.localizationDelegates,
    supportedLocales: Localization.supportedLocales,
    theme: buildSteamTheme(),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.initializationFailed, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(context.l10n.initializationFailureHint),
                const SizedBox(height: 16),
                if (widget.onRetryInitialization != null)
                  FilledButton.icon(
                    onPressed: _busy ? null : _retry,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.retry),
                  ),
                if (_busy) const LinearProgressIndicator(),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: Text(context.l10n.technicalDetails),
                  children: [
                    SelectableText(
                      '${widget.error.runtimeType}\n${widget.stackTrace.toString().split('\n').take(8).join('\n')}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
