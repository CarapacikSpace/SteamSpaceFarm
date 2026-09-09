import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/localization/localization_context.dart';
import 'package:ssf_flutter/src/ui_kit/steam_tokens.dart';

enum SettingsSection() {
  appearance,
  steam,
  cache,
}

class const SettingsSideNavigation({
  required final SettingsSection selected,
  required final bool extended,
  required final ValueChanged<SettingsSection> onSelected,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xE6171D25),
    child: SizedBox(
      width: extended ? 232 : 72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 18, 10, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (extended)
              const Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 12),
                child: Text(
                  'SteamSpaceFarm',
                  style: TextStyle(
                    color: SteamUiColors.textNote,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .8,
                  ),
                ),
              ),
            _SettingsNavigationItem(
              icon: const Icon(Icons.palette_outlined),
              label: context.l10n.settingsAppearance,
              selected: selected == SettingsSection.appearance,
              extended: extended,
              onPressed: () => onSelected(SettingsSection.appearance),
            ),
            const SizedBox(height: 4),
            _SettingsNavigationItem(
              icon: const Icon(Icons.link_outlined),
              label: context.l10n.settingsIntegrationsSteam,
              selected: selected == SettingsSection.steam,
              extended: extended,
              onPressed: () => onSelected(SettingsSection.steam),
            ),
            const SizedBox(height: 4),
            _SettingsNavigationItem(
              icon: const Icon(Icons.inventory_2_outlined),
              label: GeneratedLocalizations.of(context).libraryCache,
              selected: selected == SettingsSection.cache,
              extended: extended,
              onPressed: () => onSelected(SettingsSection.cache),
            ),
          ],
        ),
      ),
    ),
  );
}

class const SettingsBottomNavigation({
  required final SettingsSection selected,
  required final ValueChanged<SettingsSection> onSelected,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: SteamUiColors.background,
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            Expanded(
              child: _SettingsNavigationItem(
                icon: const Icon(Icons.palette_outlined),
                label: context.l10n.settingsAppearance,
                selected: selected == SettingsSection.appearance,
                extended: true,
                compact: true,
                onPressed: () => onSelected(SettingsSection.appearance),
              ),
            ),
            Expanded(
              child: _SettingsNavigationItem(
                icon: const Icon(Icons.link_outlined),
                label: 'Steam',
                selected: selected == SettingsSection.steam,
                extended: true,
                compact: true,
                onPressed: () => onSelected(SettingsSection.steam),
              ),
            ),
            Expanded(
              child: _SettingsNavigationItem(
                icon: const Icon(Icons.inventory_2_outlined),
                label: GeneratedLocalizations.of(context).cache,
                selected: selected == SettingsSection.cache,
                extended: true,
                compact: true,
                onPressed: () => onSelected(SettingsSection.cache),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class const _SettingsNavigationItem({
  required final Widget icon,
  required final String label,
  required final bool selected,
  required final bool extended,
  required final VoidCallback onPressed,
  final bool compact = false,
}) extends StatefulWidget {
  @override
  State<_SettingsNavigationItem> createState() => _SettingsNavigationItemState();
}

class _SettingsNavigationItemState() extends State<_SettingsNavigationItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: SteamUiDurations.regular,
        height: widget.compact ? 54 : 42,
        padding: EdgeInsets.symmetric(horizontal: widget.extended ? 12 : 0),
        decoration: BoxDecoration(
          gradient: widget.selected || _hovered
              ? LinearGradient(
                  colors: widget.selected
                      ? const [Color(0x663D6B85), Color(0x1A3D6B85)]
                      : const [Color(0x3348505E), Color(0x0D48505E)],
                )
              : null,
          border: Border(
            left: BorderSide(color: widget.selected ? SteamUiColors.accent : Colors.transparent, width: 3),
          ),
        ),
        child: Row(
          mainAxisAlignment: widget.extended ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(size: 19, color: widget.selected ? Colors.white : SteamUiColors.textMuted),
              child: widget.icon,
            ),
            if (widget.extended) ...[
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.selected ? Colors.white : SteamUiColors.textSubtitle,
                    fontSize: 13,
                    fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
