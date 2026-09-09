import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';

abstract final class Localization() {
  static const fallbackLocale = Locale('en');
  static const List<LocalizationsDelegate<dynamic>> localizationDelegates = [
    ...GlobalMaterialLocalizations.delegates,
    GeneratedLocalizations.delegate,
  ];

  static List<Locale> get supportedLocales => GeneratedLocalizations.delegate.supportedLocales;

  static Locale get deviceLocale => resolve(WidgetsBinding.instance.platformDispatcher.locale);

  static Locale resolve(Locale locale) => supportedLocales.firstWhere(
    (supported) => supported.languageCode == locale.languageCode,
    orElse: () => fallbackLocale,
  );
}
