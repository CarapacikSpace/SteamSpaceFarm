import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:space_farm/src/settings/data/settings_repository.dart';
import 'package:space_farm/src/settings/model/app_settings.dart';

final class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsBloc({required IAppSettingsRepository appSettingsRepository, required AppSettingsState initialState})
    : _appSettingsRepository = appSettingsRepository,
      super(initialState) {
    on<AppSettingsEvent>(
      (event, emit) => switch (event) {
        final _UpdateAppSettingsEvent e => _updateAppSettings(e, emit),
      },
    );
  }

  final IAppSettingsRepository _appSettingsRepository;

  Future<void> _updateAppSettings(_UpdateAppSettingsEvent event, Emitter<AppSettingsState> emit) async {
    try {
      emit(_LoadingAppSettingsState(appSettings: state.appSettings));
      await _appSettingsRepository.setAppSettings(event.appSettings);
      emit(_IdleAppSettingsState(appSettings: event.appSettings));
    } on Object catch (error) {
      emit(_ErrorAppSettingsState(appSettings: event.appSettings, error: error));
    }
  }
}

@immutable
sealed class AppSettingsState {
  const AppSettingsState({this.appSettings});

  const factory AppSettingsState.idle({AppSettings? appSettings}) = _IdleAppSettingsState;

  const factory AppSettingsState.loading({AppSettings? appSettings}) = _LoadingAppSettingsState;

  const factory AppSettingsState.error({required Object error, AppSettings? appSettings}) = _ErrorAppSettingsState;

  final AppSettings? appSettings;
}

final class _IdleAppSettingsState extends AppSettingsState {
  const _IdleAppSettingsState({super.appSettings});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _IdleAppSettingsState && other.appSettings == appSettings;
  }

  @override
  int get hashCode => appSettings.hashCode;

  @override
  String toString() => 'SettingsState.idle(appSettings: $appSettings)';
}

final class _LoadingAppSettingsState extends AppSettingsState {
  const _LoadingAppSettingsState({super.appSettings});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _LoadingAppSettingsState && other.appSettings == appSettings;
  }

  @override
  int get hashCode => appSettings.hashCode;

  @override
  String toString() => 'SettingsState.loading(appSettings: $appSettings)';
}

final class _ErrorAppSettingsState extends AppSettingsState {
  const _ErrorAppSettingsState({required this.error, super.appSettings});

  final Object error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _ErrorAppSettingsState && other.appSettings == appSettings && other.error == error;
  }

  @override
  int get hashCode => Object.hash(appSettings, error);

  @override
  String toString() => 'SettingsState.error(appSettings: $appSettings, error: $error)';
}

sealed class AppSettingsEvent {
  const AppSettingsEvent();

  const factory AppSettingsEvent.updateAppSettings({required AppSettings appSettings}) = _UpdateAppSettingsEvent;
}

final class _UpdateAppSettingsEvent extends AppSettingsEvent {
  const _UpdateAppSettingsEvent({required this.appSettings});

  final AppSettings appSettings;

  @override
  String toString() => 'SettingsEvent.updateAppSettings(appSettings: $appSettings)';
}
