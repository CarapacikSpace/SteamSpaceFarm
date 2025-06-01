import 'package:flutter/material.dart';
import 'package:space_farm/src/common/constant/localization/localization.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';
import 'package:space_farm/src/common/resources/theme.dart' as t;
import 'package:space_farm/src/settings/widget/settings_scope.dart';
import 'package:space_farm/src/time_boost/screen/time_boost_screen.dart';

class MaterialContext extends StatelessWidget {
  const MaterialContext({super.key});

  static final _globalKey = GlobalKey(debugLabel: 'MaterialContext');

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final settings = SettingsScope.settingsOf(context);

    final theme = t.theme;
    return MaterialApp(
      theme: theme,
      locale: settings.locale,
      localizationsDelegates: Localization.localizationDelegates,
      supportedLocales: Localization.supportedLocales,
      onGenerateTitle: (context) => context.l10n.appTitle,
      home: const TimeBoostScreen(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        key: _globalKey,
        data: mediaQueryData.copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
    );
  }
}
