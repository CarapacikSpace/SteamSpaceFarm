import 'package:flutter/widgets.dart';
import 'package:ssf_flutter/src/feature/settings/data/settings_repository.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/logging/app_logger.dart';
import 'package:ssf_flutter/src/utils/serial_task_queue.dart';

class const SettingsScope({
  required final IAppSettingsRepository repository,
  required final AppSettings initialSettings,
  required final Widget child,
  super.key,
}) extends StatefulWidget {
  static SettingsScopeState of(BuildContext context, {bool listen = true}) {
    final _SettingsInherited? scope = listen
        ? context.dependOnInheritedWidgetOfExactType<_SettingsInherited>()
        : context.getInheritedWidgetOfExactType<_SettingsInherited>();
    assert(scope != null, 'SettingsScope is missing');
    return scope!.state;
  }

  @override
  SettingsScopeState createState() => SettingsScopeState();
}

class SettingsScopeState() extends State<SettingsScope> {
  final _queue = SerialTaskQueue();
  late AppSettings _settings = widget.initialSettings;
  AppSettings? _failedSettings;
  Object? _error;
  bool _saving = false;
  int _revision = 0;

  AppSettings get settings => _settings;

  AppSettings? get failedSettings => _failedSettings;

  Object? get error => _error;

  bool get isSaving => _saving;

  Future<bool> update(AppSettings Function(AppSettings) transform) async {
    var saved = false;
    await _queue.run(() async {
      if (!mounted) {
        return;
      }
      final AppSettings next = transform(_settings);
      if (next == _settings && _error == null) {
        saved = true;
        return;
      }
      _saving = true;
      _error = null;
      _changed();
      try {
        await widget.repository.setAppSettings(next);
        _settings = next;
        _failedSettings = null;
        saved = true;
        AppLogger.info('Saved', name: 'Settings');
      } on Object catch (error, stack) {
        _error = error;
        _failedSettings = next;
        AppLogger.error('Settings save failed', error, stack);
      } finally {
        _saving = false;
        _changed();
      }
    });
    return saved;
  }

  Future<bool> retry() => update((current) => _failedSettings ?? current);

  void _changed() {
    if (mounted) {
      setState(() => _revision++);
    }
  }

  @override
  Widget build(BuildContext context) => _SettingsInherited(state: this, revision: _revision, child: widget.child);
}

class const _SettingsInherited({
  required final SettingsScopeState state,
  required final int revision,
  required super.child,
}) extends InheritedWidget {
  @override
  bool updateShouldNotify(_SettingsInherited oldWidget) => revision != oldWidget.revision;
}
