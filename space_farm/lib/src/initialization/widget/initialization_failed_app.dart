import 'package:flutter/material.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';

class InitializationFailedApp extends StatefulWidget {
  const InitializationFailedApp({required this.error, required this.stackTrace, this.onRetryInitialization, super.key});

  final Object error;

  final StackTrace stackTrace;

  final Future<void> Function()? onRetryInitialization;

  @override
  State<InitializationFailedApp> createState() => _InitializationFailedAppState();
}

class _InitializationFailedAppState extends State<InitializationFailedApp> {
  final _inProgress = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _inProgress.dispose();
    super.dispose();
  }

  Future<void> _retryInitialization() async {
    _inProgress.value = true;
    await widget.onRetryInitialization?.call();
    _inProgress.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.l10n.initializationFailed, style: typography.headlineMedium),
                  if (widget.onRetryInitialization != null)
                    IconButton(icon: const Icon(Icons.refresh), onPressed: _retryInitialization),
                ],
              ),
              const SizedBox(height: 16),
              Text('${widget.error}', style: typography.bodyLarge?.copyWith(color: colorScheme.error)),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('${widget.stackTrace}', style: typography.bodyLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
