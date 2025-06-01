import 'package:flutter/material.dart';
import 'package:space_farm/src/apps/model/card_type.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/apps/widget/app_card.dart';
import 'package:space_farm/src/settings/widget/settings_scope.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';

class AppsGridWidget extends StatelessWidget {
  const AppsGridWidget({
    required this.apps,
    required this.launchedAppIds,
    required this.timeFilterType,
    required this.onTap,
    required this.onUpdateApp,
    super.key,
  });

  final List<LocalApp> apps;
  final Set<int> launchedAppIds;
  final TimeFilterType timeFilterType;
  final ValueChanged<LocalApp> onTap;
  final ValueChanged<LocalApp> onUpdateApp;

  @override
  Widget build(BuildContext context) {
    final cardType = SettingsScope.settingsOf(context).cardType;
    if (cardType == SteamAppCardType.icon) {
      return ListView.builder(
        itemCount: apps.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final app = apps[index];
          final isRunning = launchedAppIds.contains(app.appId);
          return AppCard(
            app: app,
            isRunning: isRunning,
            onTap: onTap,
            timeFilterType: timeFilterType,
            onUpdateApp: onUpdateApp,
          );
        },
      );
    }
    SliverGridDelegate delegate;
    if (cardType case SteamAppCardType.header) {
      delegate = const SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisExtent: 160,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 2,
        maxCrossAxisExtent: 200,
      );
    } else if (cardType case SteamAppCardType.library) {
      delegate = const SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisExtent: 300,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 6 / 10,
        maxCrossAxisExtent: 200,
      );
    } else {
      delegate = const SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisExtent: 160,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 2,
        maxCrossAxisExtent: 200,
      );
    }
    return GridView.builder(
      itemCount: apps.length,
      padding: const EdgeInsets.all(16),
      gridDelegate: delegate,
      itemBuilder: (context, index) {
        final app = apps[index];
        final isRunning = launchedAppIds.contains(app.appId);
        return AppCard(
          app: app,
          isRunning: isRunning,
          onTap: onTap,
          timeFilterType: timeFilterType,
          onUpdateApp: onUpdateApp,
        );
      },
    );
  }
}
