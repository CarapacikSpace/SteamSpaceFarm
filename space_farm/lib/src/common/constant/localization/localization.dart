import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:space_farm/src/common/constant/localization/generated/l10n.dart';

final class Localization {
  const Localization._({required this.locale});

  static const _delegate = GeneratedLocalizations.delegate;

  static List<Locale> get supportedLocales => _delegate.supportedLocales;

  static List<LocalizationsDelegate<void>> get localizationDelegates => [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    _delegate,
  ];

  static Localization? get current => _current;

  static Localization? _current;

  final Locale locale;

  static Locale computeDefaultLocale() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;

    if (_delegate.isSupported(locale)) {
      return locale;
    }

    return const Locale('en');
  }

  static GeneratedLocalizations of(BuildContext context) => GeneratedLocalizations.of(context);
}
