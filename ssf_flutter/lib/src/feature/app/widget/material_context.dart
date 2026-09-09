import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/app/model/dependencies_container.dart';
import 'package:ssf_flutter/src/feature/app/widget/dependencies_scope.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_screen.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_scope.dart';
import 'package:ssf_flutter/src/localization/localization.dart';
import 'package:ssf_flutter/src/ui_kit/layout/media_query_override.dart';
import 'package:ssf_flutter/src/ui_kit/steam_theme.dart';

class const MaterialContext({required final GlobalKey<ScaffoldMessengerState> messengerKey, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DependenciesContainer dependencies = DependenciesScope.of(context);
    final AppSettings settings = SettingsScope.of(context).settings;
    return MaterialApp(
      title: 'SteamSpaceFarm',
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      localizationsDelegates: Localization.localizationDelegates,
      supportedLocales: Localization.supportedLocales,
      theme: buildSteamTheme(),
      home: CatalogScreen(
        appsRepository: dependencies.appsRepository,
        steamGameService: dependencies.steamGameService,
        settings: settings,
      ),
      builder: (context, child) => ScrollNotificationObserver(child: MediaQueryRootOverride(child: child!)),
    );
  }
}
