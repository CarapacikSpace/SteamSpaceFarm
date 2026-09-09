import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/catalog/model/library_ownership.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/steam_ui_kit.dart';

class const AutoStopDraft({required final int? minutes});

enum OwnershipSelection() {
  automatic,
  personal,
  family,
  unknown,
}

Future<int?> showCurrentTimeDialog(BuildContext context, LocalApp app) => showDialog<int>(
  context: context,
  builder: (context) => _CurrentTimeDialog(app: app),
);

Future<AutoStopDraft?> showAutoStopDialog(BuildContext context, LocalApp app) => showDialog<AutoStopDraft>(
  context: context,
  builder: (context) => _AutoStopDialog(app: app),
);

Future<OwnershipSelection?> showOwnershipDialog(BuildContext context, LocalApp app) => showDialog<OwnershipSelection>(
  context: context,
  builder: (context) => _OwnershipDialog(app: app),
);

class const _CurrentTimeDialog({required final LocalApp app}) extends StatefulWidget {
  @override
  State<_CurrentTimeDialog> createState() => _CurrentTimeDialogState();
}

class _CurrentTimeDialogState() extends State<_CurrentTimeDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.app.playtimeMinutes ?? 0}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, int.parse(_controller.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) => _EditDialog(
    title: GeneratedLocalizations.of(context).currentPlaytime,
    appName: widget.app.name,
    onSave: _submit,
    child: Form(
      key: _formKey,
      child: ValueListenableBuilder(
        valueListenable: _controller,
        builder: (context, value, _) {
          final int? minutes = int.tryParse(value.text.trim());
          final bool reachesGoal =
              minutes != null && widget.app.stopAtMinutes != null && minutes >= widget.app.stopAtMinutes!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GeneratedLocalizations.of(context).playtimeInMinutes,
                style: const TextStyle(fontSize: 12, color: Color(0xFFB8BEC7)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: GeneratedLocalizations.of(context).playtimeMinutesExample,
                  suffixText: GeneratedLocalizations.of(context).minutesAbbreviation,
                ),
                validator: (text) {
                  final int? parsed = int.tryParse(text?.trim() ?? '');
                  return parsed == null || parsed < 0
                      ? GeneratedLocalizations.of(context).nonNegativeIntegerRequired
                      : null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Text(_hoursHint(minutes), style: const TextStyle(color: Color(0xFF8D9BAB))),
              if (reachesGoal) ...[
                const SizedBox(height: 14),
                _Notice(
                  icon: Icons.warning_amber_rounded,
                  text: GeneratedLocalizations.of(context).playtimeClearsReachedTargetHint,
                ),
              ],
            ],
          );
        },
      ),
    ),
  );
}

class const _AutoStopDialog({required final LocalApp app}) extends StatefulWidget {
  @override
  State<_AutoStopDialog> createState() => _AutoStopDialogState();
}

class _AutoStopDialogState() extends State<_AutoStopDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.app.stopAtMinutes?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final String text = _controller.text.trim();
    final int? value = int.tryParse(text);
    final int current = widget.app.playtimeMinutes ?? 0;
    Navigator.pop(context, AutoStopDraft(minutes: value != null && value > current ? value : null));
  }

  @override
  Widget build(BuildContext context) => _EditDialog(
    title: GeneratedLocalizations.of(context).autoStop,
    appName: widget.app.name,
    onSave: _submit,
    child: Form(
      key: _formKey,
      child: ValueListenableBuilder(
        valueListenable: _controller,
        builder: (context, value, _) {
          final String text = value.text.trim();
          final int? minutes = int.tryParse(text);
          final int current = widget.app.playtimeMinutes ?? 0;
          final bool removesGoal = text.isEmpty || (minutes != null && minutes <= current);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GeneratedLocalizations.of(context).targetPlaytime,
                style: const TextStyle(fontSize: 12, color: Color(0xFFB8BEC7)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: GeneratedLocalizations.of(context).targetPlaytimeInMinutes,
                  suffixText: GeneratedLocalizations.of(context).minutesAbbreviation,
                ),
                validator: (value) {
                  final String text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return null;
                  }
                  final int? parsed = int.tryParse(text);
                  return parsed == null || parsed <= 0
                      ? GeneratedLocalizations.of(context).positiveIntegerRequired
                      : null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Text(
                text.isEmpty ? GeneratedLocalizations.of(context).emptyTargetClearsHint : _hoursHint(minutes),
                style: const TextStyle(color: Color(0xFF8D9BAB)),
              ),
              if (removesGoal && text.isNotEmpty) ...[
                const SizedBox(height: 14),
                _Notice(
                  icon: Icons.info_outline,
                  text: GeneratedLocalizations.of(context).targetAlreadyReachedHint(current),
                ),
              ],
            ],
          );
        },
      ),
    ),
  );
}

class const _OwnershipDialog({required final LocalApp app}) extends StatefulWidget {
  @override
  State<_OwnershipDialog> createState() => _OwnershipDialogState();
}

class _OwnershipDialogState() extends State<_OwnershipDialog> {
  late OwnershipSelection _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.app.isLibraryOwnershipManual
        ? switch (widget.app.libraryOwnership) {
            LibraryOwnership.personal => OwnershipSelection.personal,
            LibraryOwnership.family => OwnershipSelection.family,
            LibraryOwnership.unknown => OwnershipSelection.unknown,
          }
        : OwnershipSelection.automatic;
  }

  @override
  Widget build(BuildContext context) => _EditDialog(
    title: GeneratedLocalizations.of(context).ownership,
    appName: widget.app.name,
    onSave: () => Navigator.pop(context, _selection),
    child: RadioGroup<OwnershipSelection>(
      groupValue: _selection,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selection = value);
        }
      },
      child: Column(
        children: [
          for (final option in OwnershipSelection.values)
            RadioListTile<OwnershipSelection>(
              value: option,
              contentPadding: EdgeInsets.zero,
              title: Text(_ownershipTitle(option)),
              subtitle: option == OwnershipSelection.automatic
                  ? Text(GeneratedLocalizations.of(context).ownershipFromSteamOnRefresh)
                  : null,
            ),
        ],
      ),
    ),
  );
}

class const _EditDialog({
  required final String title,
  required final String appName,
  required final Widget child,
  required final VoidCallback onSave,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SteamDialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              appName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF8D9BAB)),
            ),
            const SizedBox(height: 22),
            child,
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SteamTextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(GeneratedLocalizations.of(context).cancel),
                ),
                const SizedBox(width: 10),
                SteamButton(
                  variant: SteamButtonVariant.primary,
                  onPressed: onSave,
                  child: Text(GeneratedLocalizations.of(context).save),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class const _Notice({required final IconData icon, required final String text}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: const Color(0xFF253444), borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: const Color(0xFF66C0F4)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Color(0xFFD6D7D8))),
          ),
        ],
      ),
    ),
  );
}

String _hoursHint(int? minutes) =>
    minutes == null ? '' : GeneratedLocalizations.current.playtimeHoursApproximate((minutes / 60).toStringAsFixed(1));

String _ownershipTitle(OwnershipSelection option) => switch (option) {
  OwnershipSelection.automatic => GeneratedLocalizations.current.detectAutomatically,
  OwnershipSelection.personal => GeneratedLocalizations.current.ownershipPersonal,
  OwnershipSelection.family => 'Steam Family',
  OwnershipSelection.unknown => GeneratedLocalizations.current.ownershipNonPersonal,
};
