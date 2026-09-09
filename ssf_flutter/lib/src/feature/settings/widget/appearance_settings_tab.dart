import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/catalog/model/card_type.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_app_card.dart';
import 'package:ssf_flutter/src/feature/settings/model/app_settings.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/localization/localization.dart';
import 'package:ssf_flutter/src/localization/localization_context.dart';
import 'package:ssf_flutter/src/ui_kit/steam_ui_kit.dart';

class const AppearanceSettingsTab({
  required final AppSettings settings,
  required final bool isSaving,
  required final Object? error,
  required final ValueChanged<AppSettings> onChanged,
  required final VoidCallback onRetry,
  super.key,
}) extends StatelessWidget {
  static const LocalApp _previewApp = LocalApp(
    appId: 730,
    name: 'Counter-Strike 2',
    type: SteamAppType.game,
    playtimeMinutes: 720,
    stopAtMinutes: 1500,
    icon: '8dbc71957312bbd3baea65848b545be9eae2a355',
  );

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SteamPageHeader(
              eyebrow: GeneratedLocalizations.of(context).interface,
              title: context.l10n.settingsAppearance,
              description: context.l10n.settingsImmediateSaveHint,
            ),
            if (isSaving) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 6),
              Text(context.l10n.settingsSaving),
            ],
            if (error != null) ...[const SizedBox(height: 16), _SettingsError(onRetry: onRetry)],
            const SizedBox(height: 24),
            _SettingsSectionTitle(title: context.l10n.settingsLanguage, icon: Icons.language),
            const SizedBox(height: 8),
            _SettingsSurface(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool narrow = constraints.maxWidth < 360;
                  final dropdown = SteamDropdown<Locale>(
                    width: narrow ? constraints.maxWidth : 180,
                    items: Localization.supportedLocales,
                    value: settings.locale,
                    labelBuilder: (locale) => switch (locale.languageCode) {
                      'ru' => context.l10n.languageRussian,
                      'en' => context.l10n.languageEnglish,
                      _ => locale.languageCode,
                    },
                    onChanged: isSaving
                        ? null
                        : (locale) {
                            if (locale != settings.locale) {
                              onChanged(settings.copyWith(locale: locale));
                            }
                          },
                  );
                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          GeneratedLocalizations.of(context).appLanguage,
                          style: const TextStyle(color: SteamUiColors.textSubtitle, fontSize: 13),
                        ),
                        const SizedBox(height: 9),
                        dropdown,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          GeneratedLocalizations.of(context).appLanguage,
                          style: const TextStyle(color: SteamUiColors.textSubtitle, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 16),
                      dropdown,
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _SettingsSectionTitle(title: context.l10n.cardType, icon: Icons.view_module_outlined),
            const SizedBox(height: 5),
            Text(context.l10n.settingsCardPreviewHint, style: const TextStyle(color: Color(0xFF8D9BAB))),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final double tileWidth = constraints.maxWidth >= 760
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final SteamAppCardType cardType in SteamAppCardType.values)
                      SizedBox(
                        width: tileWidth,
                        child: _CardTypeOption(
                          cardType: cardType,
                          app: _previewApp,
                          selected: settings.cardType == cardType,
                          enabled: !isSaving,
                          onSelected: () => onChanged(settings.copyWith(cardType: cardType)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class const _CardTypeOption({
  required final SteamAppCardType cardType,
  required final LocalApp app,
  required final bool selected,
  required final bool enabled,
  required final VoidCallback onSelected,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: selected ? SteamUiColors.accent : const Color(0x333D4450)),
      borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: enabled && !selected ? onSelected : null,
      mouseCursor: enabled && !selected ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Ink(
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [Color(0xE61D3A50), Color(0xCC172230)])
              : const LinearGradient(colors: [Color(0xE6172230), Color(0xCC171D25)]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: selected ? SteamUiColors.accent : SteamUiColors.raisedSurface,
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _cardTypeLabel(context, cardType),
                      style: TextStyle(
                        color: selected ? Colors.white : SteamUiColors.textSubtitle,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 310,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(radius: 1.1, colors: [Color(0x332F6B91), Color(0x00171D25)]),
                  ),
                  child: Center(
                    child: IgnorePointer(
                      child: SizedBox.fromSize(
                        size: _previewSize(cardType),
                        child: CatalogAppCard(
                          app: app,
                          cardType: cardType,
                          useHours: true,
                          isRunning: false,
                          onTap: onSelected,
                          onMenuRequested: onSelected,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class const _SettingsSurface({required final Widget child, final EdgeInsetsGeometry padding = const EdgeInsets.all(18)})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xE6172230), Color(0xE6171D25)],
      ),
      border: Border.all(color: const Color(0x333D4450)),
      borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
      boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 4))],
    ),
    child: Padding(padding: padding, child: child),
  );
}

class const _SettingsSectionTitle({required final String title, required final IconData icon}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: SteamUiColors.accent),
      const SizedBox(width: 7),
      Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: SteamUiColors.textSubtitle,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: .5,
        ),
      ),
    ],
  );
}

class const _SettingsError({required final VoidCallback onRetry}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0x332F7D8C),
      border: Border.all(color: Theme.of(context).colorScheme.error),
      borderRadius: BorderRadius.circular(SteamUiMetrics.controlRadius),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Expanded(child: Text(context.l10n.settingsSaveError)),
          SteamButton(
            compact: true,
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    ),
  );
}

Size _previewSize(SteamAppCardType cardType) => switch (cardType) {
  SteamAppCardType.libraryCapsule => const Size(170, 275),
  SteamAppCardType.mainCapsule => const Size(170, 173),
  SteamAppCardType.storeHeader => const Size(170, 155),
  SteamAppCardType.appIcon => const Size(340, 60),
};

String _cardTypeLabel(BuildContext context, SteamAppCardType cardType) => switch (cardType) {
  SteamAppCardType.libraryCapsule => context.l10n.cardTypeLibraryCapsule,
  SteamAppCardType.mainCapsule => context.l10n.cardTypeMainCapsule,
  SteamAppCardType.storeHeader => context.l10n.cardTypeStoreHeader,
  SteamAppCardType.appIcon => context.l10n.cardTypeAppIcon,
};
