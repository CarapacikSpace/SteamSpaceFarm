import 'package:flutter/material.dart';
import 'package:space_farm/src/apps/model/card_type.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/apps/widget/header_app_card.dart';
import 'package:space_farm/src/apps/widget/icon_app_card_content.dart';
import 'package:space_farm/src/apps/widget/library_app_card.dart';
import 'package:space_farm/src/common/constant/localization/localization.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';
import 'package:space_farm/src/settings/logic/app_settings_bloc.dart';
import 'package:space_farm/src/settings/widget/settings_scope.dart';
import 'package:space_farm/src/shared/checkbox.dart';
import 'package:space_farm/src/shared/dropdown.dart';
import 'package:space_farm/src/steam/model/steam_app_type.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.settingsOf(context);
    const exampleApp = LocalApp(
      appId: 730,
      name: 'Counter-Strike 2',
      type: SteamAppType.game,
      stopAtMinutes: 1500,
      playtimeMinutes: 720,
    );
    return Scaffold(
      backgroundColor: const Color(0XFF171D25),
      appBar: AppBar(
        title: Text(context.l10n.settings),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text(context.l10n.settingsLanguage, style: const TextStyle(fontSize: 16))),
                  SteamDropdownSingle<Locale>(
                    options: Localization.supportedLocales.toSet(),
                    selected: settings.locale,
                    onChanged: (locale) {
                      SettingsScope.of(
                        context,
                        listen: false,
                      ).add(AppSettingsEvent.updateAppSettings(appSettings: settings.copyWith(locale: locale)));
                    },
                    labelBuilder: (locale) => switch (locale) {
                      const Locale.fromSubtags(languageCode: 'en') => context.l10n.languageEnglish,
                      const Locale.fromSubtags(languageCode: 'ru') => context.l10n.languageRussian,
                      _ => '',
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1, height: 1),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(context.l10n.cardType, style: const TextStyle(fontSize: 16))),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final cardType in SteamAppCardType.values)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              SettingsScope.of(context, listen: false).add(
                                AppSettingsEvent.updateAppSettings(appSettings: settings.copyWith(cardType: cardType)),
                              );
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, right: 8),
                                  child: SteamCheckbox(value: cardType == settings.cardType),
                                ),
                                switch (cardType) {
                                  SteamAppCardType.header => SizedBox(
                                    width: 200,
                                    child: HeaderAppCardContent(
                                      app: exampleApp,
                                      onTap: () {
                                        SettingsScope.of(context, listen: false).add(
                                          AppSettingsEvent.updateAppSettings(
                                            appSettings: settings.copyWith(cardType: cardType),
                                          ),
                                        );
                                      },
                                      isRunning: false,
                                      onRightClick: (_) {},
                                      timeFilterType: TimeFilterType.hours,
                                    ),
                                  ),
                                  SteamAppCardType.library => SizedBox(
                                    height: 300,
                                    width: 200,
                                    child: LibraryAppCardContent(
                                      app: exampleApp,
                                      onTap: () {
                                        SettingsScope.of(context, listen: false).add(
                                          AppSettingsEvent.updateAppSettings(
                                            appSettings: settings.copyWith(cardType: cardType),
                                          ),
                                        );
                                      },
                                      isRunning: false,
                                      onRightClick: (_) {},
                                      timeFilterType: TimeFilterType.hours,
                                    ),
                                  ),
                                  SteamAppCardType.icon => SizedBox(
                                    width: 300,
                                    child: IconAppCardContent(
                                      app: exampleApp,
                                      onTap: () {
                                        SettingsScope.of(context, listen: false).add(
                                          AppSettingsEvent.updateAppSettings(
                                            appSettings: settings.copyWith(cardType: cardType),
                                          ),
                                        );
                                      },
                                      isRunning: false,
                                      onRightClick: (_) {},
                                      timeFilterType: TimeFilterType.hours,
                                    ),
                                  ),
                                },
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
