import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/catalog/logic/app_sorting.dart';
import 'package:ssf_flutter/src/feature/catalog/logic/time_input_conversion.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/catalog/model/time_filter_type.dart';
import 'package:ssf_flutter/src/feature/game_execution/logic/beautiful_hours.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/beautiful_hours_configuration.dart';
import 'package:ssf_flutter/src/feature/game_execution/model/bulk_actions.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/steam_ui_kit.dart';

const Color _muted = Color(0xFF8D9BAB);

Future<BulkLaunchRequest?> showBulkLaunchDialog({
  required BuildContext context,
  required List<LocalApp> visibleApps,
  required BulkLaunchOrder initialOrder,
  required SortDirection initialDirection,
  required int concurrentLimit,
}) => _showAdaptiveActionSurface<BulkLaunchRequest>(
  context: context,
  child: BulkLaunchForm(
    visibleApps: visibleApps,
    initialOrder: initialOrder,
    initialDirection: initialDirection,
    concurrentLimit: concurrentLimit,
  ),
);

Future<BulkMarkRequest?> showBulkMarkDialog({
  required BuildContext context,
  required List<LocalApp> visibleApps,
  required List<LocalApp> allApps,
  required TimeFilterType initialUnit,
  required BeautifulHoursConfiguration initialBeautifulHours,
}) => _showAdaptiveActionSurface<BulkMarkRequest>(
  context: context,
  child: BulkMarkForm(
    visibleApps: visibleApps,
    allApps: allApps,
    initialUnit: initialUnit,
    initialBeautifulHours: initialBeautifulHours,
  ),
);

Future<T?> _showAdaptiveActionSurface<T>({required BuildContext context, required Widget child}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => SteamDialog(
      maxWidth: 720,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720, maxHeight: MediaQuery.sizeOf(context).height - 64),
        child: child,
      ),
    ),
  );
}

class const BulkLaunchForm({
  required final List<LocalApp> visibleApps,
  required final BulkLaunchOrder initialOrder,
  required final SortDirection initialDirection,
  required final int concurrentLimit,
  super.key,
}) extends StatefulWidget {
  @override
  State<BulkLaunchForm> createState() => _BulkLaunchFormState();
}

class _BulkLaunchFormState() extends State<BulkLaunchForm> {
  final TextEditingController _runSeconds = TextEditingController(text: '60');
  final TextEditingController _lowPlaytimeSeconds = TextEditingController(text: '60');
  final TextEditingController _delaySeconds = TextEditingController(text: '10');
  final TextEditingController _startAppId = TextEditingController();
  BulkLaunchMode _mode = BulkLaunchMode.marked;
  BulkLaunchOrder _order = BulkLaunchOrder.remainingMarkedTime;
  SortDirection _direction = SortDirection.descending;
  late int _concurrentLimit;
  String? _error;

  @override
  void initState() {
    super.initState();
    _concurrentLimit = widget.concurrentLimit;
  }

  @override
  void dispose() {
    _runSeconds.dispose();
    _lowPlaytimeSeconds.dispose();
    _delaySeconds.dispose();
    _startAppId.dispose();
    super.dispose();
  }

  BulkLaunchRequest get _previewRequest => BulkLaunchRequest(
    mode: _mode,
    order: _order,
    direction: _direction,
    concurrentLimit: _concurrentLimit,
    startAppId: int.tryParse(_startAppId.text.trim()),
  );

  int get _candidateCount =>
      selectBulkLaunchCandidates(request: _previewRequest, filteredCatalogApps: widget.visibleApps).length;

  void _selectMode(BulkLaunchMode mode) {
    setState(() {
      if (mode == BulkLaunchMode.marked) {
        _order = BulkLaunchOrder.remainingMarkedTime;
        _direction = SortDirection.descending;
      } else if (_mode == BulkLaunchMode.marked) {
        _order = widget.initialOrder;
        _direction = widget.initialDirection;
      }
      _mode = mode;
      _error = null;
    });
  }

  void _submit() {
    final String startText = _startAppId.text.trim();
    final int? startAppId = startText.isEmpty ? null : int.tryParse(startText);
    if (startText.isNotEmpty && startAppId == null) {
      setState(() => _error = GeneratedLocalizations.of(context).appIdInvalid);
      return;
    }
    final int? runSeconds = int.tryParse(_runSeconds.text.trim());
    final int? lowSeconds = int.tryParse(_lowPlaytimeSeconds.text.trim());
    final int? delaySeconds = int.tryParse(_delaySeconds.text.trim());
    if (_mode == BulkLaunchMode.allSequential &&
        (runSeconds == null ||
            runSeconds < 1 ||
            lowSeconds == null ||
            lowSeconds < 1 ||
            delaySeconds == null ||
            delaySeconds < 0)) {
      setState(() => _error = GeneratedLocalizations.of(context).sequentialTimingInvalid);
      return;
    }
    final request = BulkLaunchRequest(
      mode: _mode,
      order: _order,
      direction: _direction,
      concurrentLimit: _concurrentLimit,
      runSeconds: runSeconds ?? 60,
      lowPlaytimeRunSeconds: lowSeconds ?? 60,
      delaySeconds: delaySeconds ?? 10,
      startAppId: startAppId,
    );
    final int count = selectBulkLaunchCandidates(request: request, filteredCatalogApps: widget.visibleApps).length;
    if (count == 0) {
      setState(() {
        _error = _mode == BulkLaunchMode.allSequential && startAppId != null
            ? GeneratedLocalizations.of(context).startAppNotInSelection
            : GeneratedLocalizations.of(context).selectionHasNoEligibleApps;
      });
      return;
    }
    Navigator.of(context).pop(request);
  }

  @override
  Widget build(BuildContext context) => _ActionFormFrame(
    title: GeneratedLocalizations.of(context).launchApps,
    subtitle: GeneratedLocalizations.of(context).launchUsesFiltersHint,
    primaryLabel: GeneratedLocalizations.of(context).confirmLaunch,
    primaryIcon: Icons.play_arrow,
    error: _error,
    onPrimary: _submit,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(GeneratedLocalizations.of(context).mode),
        _ModePicker(
          values: BulkLaunchMode.values,
          selected: _mode,
          label: (value) => _launchModeLabel(value as BulkLaunchMode),
          onSelected: (value) => _selectMode(value as BulkLaunchMode),
        ),
        const SizedBox(height: 10),
        Text(_launchModeDescription(_mode, _concurrentLimit), style: const TextStyle(color: _muted)),
        if (_mode != BulkLaunchMode.allSequential) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  GeneratedLocalizations.of(context).concurrentApps,
                  style: const TextStyle(color: SteamUiColors.textSubtitle, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              SteamDropdown<int>(
                width: 72,
                maxMenuHeight: 288,
                items: [for (var value = 1; value <= 30; value++) value],
                value: _concurrentLimit,
                labelBuilder: (value) => '$value',
                onChanged: (value) => setState(() {
                  _concurrentLimit = value;
                  _error = null;
                }),
              ),
            ],
          ),
        ],
        if (_mode == BulkLaunchMode.allSequential) ...[
          const SizedBox(height: 20),
          _ResponsiveFields(
            children: [
              _NumberField(
                label: GeneratedLocalizations.of(context).defaultDuration,
                suffix: GeneratedLocalizations.of(context).secondsAbbreviation,
                controller: _runSeconds,
              ),
              _NumberField(
                label: GeneratedLocalizations.of(context).lowPlaytimeDurationLabel,
                suffix: GeneratedLocalizations.of(context).secondsAbbreviation,
                controller: _lowPlaytimeSeconds,
              ),
              _NumberField(
                label: GeneratedLocalizations.of(context).delayBetweenGames,
                suffix: GeneratedLocalizations.of(context).secondsAbbreviation,
                controller: _delaySeconds,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _NumberField(
            label: GeneratedLocalizations.of(context).sequentialStartAppId,
            hint: GeneratedLocalizations.of(context).optional,
            controller: _startAppId,
            onChanged: (_) => setState(() => _error = null),
          ),
        ],
        const SizedBox(height: 20),
        _SectionLabel(GeneratedLocalizations.of(context).launchOrder),
        LayoutBuilder(
          builder: (context, constraints) {
            final double orderWidth = constraints.maxWidth < 520 ? constraints.maxWidth : constraints.maxWidth - 92;
            final order = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GeneratedLocalizations.of(context).sortBy,
                  style: const TextStyle(color: SteamUiColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                SteamDropdown<BulkLaunchOrder>(
                  width: orderWidth,
                  items: BulkLaunchOrder.values,
                  value: _order,
                  labelBuilder: _launchOrderLabel,
                  onChanged: (value) => setState(() {
                    _order = value;
                    _error = null;
                  }),
                ),
              ],
            );
            final direction = Padding(
              padding: const EdgeInsets.only(top: 21),
              child: SizedBox(
                width: 80,
                child: SteamSegmentedControl<SortDirection>(
                  values: SortDirection.values,
                  selected: _direction,
                  labelBuilder: (value) => value == SortDirection.ascending ? '↑' : '↓',
                  onChanged: (value) => setState(() {
                    _direction = value;
                    _error = null;
                  }),
                ),
              ),
            );
            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [order, const SizedBox(height: 10), direction],
              );
            }
            return Row(
              children: [
                Expanded(child: order),
                const SizedBox(width: 12),
                direction,
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        _CandidateSummary(count: _candidateCount, caption: GeneratedLocalizations.of(context).eligibleApps),
        const SizedBox(height: 10),
        Text(
          GeneratedLocalizations.of(context).launchConfirmationHint,
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class const BulkMarkForm({
  required final List<LocalApp> visibleApps,
  required final List<LocalApp> allApps,
  required final TimeFilterType initialUnit,
  required final BeautifulHoursConfiguration initialBeautifulHours,
  super.key,
}) extends StatefulWidget {
  @override
  State<BulkMarkForm> createState() => _BulkMarkFormState();
}

class _BulkMarkFormState() extends State<BulkMarkForm> {
  late final TextEditingController _minimum;
  late final TextEditingController _maximum;
  final TextEditingController _target = TextEditingController();
  late final TextEditingController _beautifulValues;
  late final TextEditingController _beautifulMinimum;
  late final TextEditingController _beautifulMaximum;
  late TimeFilterType _unit;
  BulkMarkMode _mode = BulkMarkMode.range;
  String? _error;

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit;
    _minimum = TextEditingController(text: _unit == TimeFilterType.hours ? '12' : '720');
    _maximum = TextEditingController(text: _unit == TimeFilterType.hours ? '25' : '1501');
    _beautifulValues = TextEditingController(
      text: widget.initialBeautifulHours.formatHoursText(decimalSeparator: ',', valueSeparator: '; '),
    );
    _beautifulMinimum = TextEditingController(text: '${widget.initialBeautifulHours.minimumHours}');
    _beautifulMaximum = TextEditingController(text: '${widget.initialBeautifulHours.maximumHours}');
  }

  @override
  void dispose() {
    _minimum.dispose();
    _maximum.dispose();
    _target.dispose();
    _beautifulValues.dispose();
    _beautifulMinimum.dispose();
    _beautifulMaximum.dispose();
    super.dispose();
  }

  RangeBulkMarkRequest? get _rangeRequest {
    final int? minimum = TimeInputConversion.toMinutes(_minimum.text, _unit);
    final int? maximum = TimeInputConversion.toMinutes(_maximum.text, _unit);
    final String targetText = _target.text.trim();
    final int? target = targetText.isEmpty ? null : TimeInputConversion.toMinutes(targetText, _unit);
    if (minimum == null || maximum == null || maximum <= minimum || (targetText.isNotEmpty && target == null)) {
      return null;
    }
    return RangeBulkMarkRequest(minimumMinutes: minimum, maximumMinutes: maximum, targetMinutes: target);
  }

  BeautifulHoursConfiguration? get _beautifulConfiguration {
    final int? minimum = int.tryParse(_beautifulMinimum.text.trim());
    final int? maximum = int.tryParse(_beautifulMaximum.text.trim());
    if (minimum == null || maximum == null) {
      return null;
    }
    try {
      return BeautifulHoursConfiguration.fromInput(
        hoursText: _beautifulValues.text,
        minimumHours: minimum,
        maximumHours: maximum,
      );
    } on FormatException {
      return null;
    }
  }

  int get _candidateCount {
    switch (_mode) {
      case BulkMarkMode.range:
        final RangeBulkMarkRequest? request = _rangeRequest;
        if (request == null) {
          return 0;
        }
        return widget.visibleApps.where((app) {
          final int? minutes = app.playtimeMinutes;
          return minutes != null && minutes >= request.minimumMinutes && minutes < request.maximumMinutes;
        }).length;
      case BulkMarkMode.beautifulHours:
        final BeautifulHoursConfiguration? configuration = _beautifulConfiguration;
        if (configuration == null) {
          return 0;
        }
        return widget.visibleApps
            .where((app) => BeautifulHours.isEligible(app.playtimeMinutes ?? 0, configuration))
            .length;
      case BulkMarkMode.clearMarks:
        return widget.allApps.where((app) => app.stopAtMinutes != null).length;
    }
  }

  void _changeUnit(TimeFilterType unit) {
    if (unit == _unit) {
      return;
    }
    for (final TextEditingController controller in [_minimum, _maximum, _target]) {
      if (controller.text.trim().isEmpty) {
        continue;
      }
      final int? minutes = TimeInputConversion.toMinutes(controller.text, _unit);
      if (minutes != null) {
        controller.text = TimeInputConversion.fromMinutes(minutes, unit);
      }
    }
    setState(() {
      _unit = unit;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final BeautifulHoursConfiguration? beautifulConfiguration = _beautifulConfiguration;
    final BulkMarkRequest? request = switch (_mode) {
      BulkMarkMode.range => _rangeRequest,
      BulkMarkMode.beautifulHours =>
        beautifulConfiguration == null ? null : BeautifulHoursBulkMarkRequest(configuration: beautifulConfiguration),
      BulkMarkMode.clearMarks => const ClearMarksBulkRequest(),
    };
    if (request == null) {
      setState(() => _error = GeneratedLocalizations.of(context).bulkTargetsInvalidRange);
      return;
    }
    if (_candidateCount == 0) {
      setState(() => _error = GeneratedLocalizations.of(context).bulkTargetsNoChanges);
      return;
    }
    if (_mode == BulkMarkMode.clearMarks) {
      final bool confirmed = await showSteamConfirmationDialog(
        context: context,
        title: GeneratedLocalizations.of(context).clearAllTargetsTitle,
        message: GeneratedLocalizations.of(context).clearAllTargetsDescription(_candidateCount),
        confirmText: GeneratedLocalizations.of(context).clearTargets,
      );
      if (!confirmed || !mounted) {
        return;
      }
    }
    if (mounted) {
      Navigator.of(context).pop(request);
    }
  }

  @override
  Widget build(BuildContext context) => _ActionFormFrame(
    title: GeneratedLocalizations.of(context).bulkTargets,
    subtitle: GeneratedLocalizations.of(context).bulkTargetsDescription,
    primaryLabel: _mode == BulkMarkMode.clearMarks
        ? GeneratedLocalizations.of(context).clearAllTargetsAction
        : GeneratedLocalizations.of(context).applyTargets,
    primaryIcon: _mode == BulkMarkMode.clearMarks ? Icons.flag_outlined : Icons.outlined_flag,
    destructive: _mode == BulkMarkMode.clearMarks,
    error: _error,
    onPrimary: _submit,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(GeneratedLocalizations.of(context).mode),
        _ModePicker(
          values: BulkMarkMode.values,
          selected: _mode,
          label: (value) => _markModeLabel(value as BulkMarkMode),
          onSelected: (value) => setState(() {
            _mode = value as BulkMarkMode;
            _error = null;
          }),
        ),
        const SizedBox(height: 18),
        switch (_mode) {
          BulkMarkMode.range => _buildRangeFields(),
          BulkMarkMode.beautifulHours => _buildBeautifulFields(),
          BulkMarkMode.clearMarks => _InfoPanel(
            icon: Icons.warning_amber_rounded,
            title: GeneratedLocalizations.of(context).entireLibraryOperationTitle,
            body: GeneratedLocalizations.of(context).clearTargetsIgnoresFiltersHint,
          ),
        },
        const SizedBox(height: 18),
        _CandidateSummary(
          count: _candidateCount,
          caption: _mode == BulkMarkMode.clearMarks
              ? GeneratedLocalizations.of(context).entireLibrary
              : GeneratedLocalizations.of(context).currentSelection,
        ),
      ],
    ),
  );

  Widget _buildRangeFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(GeneratedLocalizations.of(context).targetRangeBoundsHint, style: const TextStyle(color: _muted)),
      const SizedBox(height: 14),
      SteamSegmentedControl<TimeFilterType>(
        values: TimeFilterType.values,
        selected: _unit,
        labelBuilder: (value) => value == TimeFilterType.hours
            ? GeneratedLocalizations.of(context).hours
            : GeneratedLocalizations.of(context).minutes,
        onChanged: _changeUnit,
      ),
      const SizedBox(height: 14),
      _ResponsiveFields(
        children: [
          _TimeField(
            label: GeneratedLocalizations.of(context).minimum,
            controller: _minimum,
            unit: _unit,
            onChanged: (_) => setState(() => _error = null),
          ),
          _TimeField(
            label: GeneratedLocalizations.of(context).maximum,
            controller: _maximum,
            unit: _unit,
            onChanged: (_) => setState(() => _error = null),
          ),
        ],
      ),
      const SizedBox(height: 14),
      _TimeField(
        label: GeneratedLocalizations.of(context).targetPlaytime,
        hint: GeneratedLocalizations.of(context).optionalMaximumHint,
        controller: _target,
        unit: _unit,
        onChanged: (_) => setState(() => _error = null),
      ),
    ],
  );

  Widget _buildBeautifulFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(GeneratedLocalizations.of(context).milestoneTargetRulesHint, style: const TextStyle(color: _muted)),
      const SizedBox(height: 14),
      Text(GeneratedLocalizations.of(context).playtimeMilestones, style: const TextStyle(fontSize: 12, color: _muted)),
      const SizedBox(height: 8),
      TextField(
        controller: _beautifulValues,
        minLines: 2,
        maxLines: 3,
        keyboardType: TextInputType.text,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9,.; ]'))],
        onChanged: (_) => setState(() => _error = null),
        decoration: _fieldDecoration(
          label: GeneratedLocalizations.of(context).playtimeMilestones,
          hint: '25,5; 30; 50; 66; 77; 100…',
        ),
      ),
      const SizedBox(height: 14),
      _ResponsiveFields(
        children: [
          _NumberField(
            label: GeneratedLocalizations.of(context).minimumTarget,
            suffix: GeneratedLocalizations.of(context).hoursAbbreviation,
            controller: _beautifulMinimum,
            onChanged: (_) => setState(() => _error = null),
          ),
          _NumberField(
            label: GeneratedLocalizations.of(context).maximumTarget,
            suffix: GeneratedLocalizations.of(context).hoursAbbreviation,
            controller: _beautifulMaximum,
            onChanged: (_) => setState(() => _error = null),
          ),
        ],
      ),
    ],
  );
}

class const _ActionFormFrame({
  required final String title,
  required final String subtitle,
  required final String primaryLabel,
  required final IconData primaryIcon,
  required final VoidCallback onPrimary,
  required final Widget child,
  final String? error,
  final bool destructive = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(subtitle, style: const TextStyle(color: _muted)),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: GeneratedLocalizations.of(context).close,
                    child: SteamButton(
                      compact: true,
                      iconOnly: true,
                      height: 32,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              child,
              if (error != null) ...[
                const SizedBox(height: 14),
                Text(
                  error!,
                  style: const TextStyle(color: Color(0xFFE35D6A), fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
      const Divider(height: 1),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final Widget primary = SteamButton(
              variant: destructive ? SteamButtonVariant.secondary : SteamButtonVariant.primary,
              onPressed: onPrimary,
              icon: Icon(primaryIcon),
              child: Text(primaryLabel),
            );
            final Widget cancel = SteamTextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(GeneratedLocalizations.of(context).cancel),
            );
            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [primary, const SizedBox(height: 6), cancel],
              );
            }
            return Row(mainAxisAlignment: MainAxisAlignment.end, children: [cancel, const SizedBox(width: 8), primary]);
          },
        ),
      ),
    ],
  );
}

class const _ModePicker({
  required final List<Enum> values,
  required final Enum selected,
  required final String Function(Enum) label,
  required final ValueChanged<Enum> onSelected,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      SteamSegmentedControl<Enum>(values: values, selected: selected, labelBuilder: label, onChanged: onSelected);
}

class const _ResponsiveFields({required final List<Widget> children}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 520) {
        return Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i != children.length - 1) const SizedBox(width: 12),
          ],
        ],
      );
    },
  );
}

class const _NumberField({
  required final String label,
  required final TextEditingController controller,
  final String? hint,
  final String? suffix,
  final ValueChanged<String>? onChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: _muted)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        decoration: _fieldDecoration(label: label, hint: hint, suffix: suffix),
      ),
    ],
  );
}

class const _TimeField({
  required final String label,
  required final TextEditingController controller,
  required final TimeFilterType unit,
  final String? hint,
  final ValueChanged<String>? onChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: _muted)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          if (unit == TimeFilterType.hours)
            FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
          else
            FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: onChanged,
        decoration: _fieldDecoration(
          label: label,
          hint: hint,
          suffix: unit == TimeFilterType.hours
              ? GeneratedLocalizations.of(context).hoursAbbreviation
              : GeneratedLocalizations.of(context).minutesAbbreviation,
        ),
      ),
      const SizedBox(height: 5),
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final String? opposite = TimeInputConversion.oppositeValue(value.text, unit);
          return Text(
            opposite == null
                ? ' '
                : '= $opposite ${unit == TimeFilterType.hours ? GeneratedLocalizations.of(context).minutesAbbreviation : GeneratedLocalizations.of(context).hoursAbbreviation}',
            style: const TextStyle(color: _muted, fontSize: 12),
          );
        },
      ),
    ],
  );
}

class const _CandidateSummary({required final int count, required final String caption}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF1B2B3D), borderRadius: BorderRadius.circular(6)),
    child: Row(
      children: [
        Icon(
          count == 0 ? Icons.info_outline : Icons.check_circle_outline,
          color: count == 0 ? _muted : const Color(0xFF66C0F4),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('$caption: $count', style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}

class const _InfoPanel({required final IconData icon, required final String title, required final String body})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1B2B3D),
      border: Border.all(color: const Color(0xFF33465C)),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFE5A94D)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(body, style: const TextStyle(color: _muted)),
            ],
          ),
        ),
      ],
    ),
  );
}

class const _SectionLabel(final String text) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.7),
    ),
  );
}

String _launchModeLabel(BulkLaunchMode mode) => switch (mode) {
  BulkLaunchMode.marked => GeneratedLocalizations.current.marked,
  BulkLaunchMode.favorites => GeneratedLocalizations.current.favorites,
  BulkLaunchMode.allSequential => GeneratedLocalizations.current.allSequentially,
};

String _launchModeDescription(BulkLaunchMode mode, int limit) => switch (mode) {
  BulkLaunchMode.marked => GeneratedLocalizations.current.markedLaunchDescription(limit),
  BulkLaunchMode.favorites => GeneratedLocalizations.current.favoritesLaunchDescription(limit),
  BulkLaunchMode.allSequential => GeneratedLocalizations.current.sequentialLaunchDescription,
};

String _launchOrderLabel(BulkLaunchOrder order) => switch (order) {
  BulkLaunchOrder.name => GeneratedLocalizations.current.name,
  BulkLaunchOrder.playtime => GeneratedLocalizations.current.currentPlaytime,
  BulkLaunchOrder.lastPlayed => GeneratedLocalizations.current.lastPlayed,
  BulkLaunchOrder.appId => 'AppID',
  BulkLaunchOrder.remainingMarkedTime => GeneratedLocalizations.current.timeUntilTarget,
};

String _markModeLabel(BulkMarkMode mode) => switch (mode) {
  BulkMarkMode.range => GeneratedLocalizations.current.range,
  BulkMarkMode.beautifulHours => GeneratedLocalizations.current.playtimeMilestones,
  BulkMarkMode.clearMarks => GeneratedLocalizations.current.clearAll,
};

InputDecoration _fieldDecoration({required String label, String? hint, String? suffix}) => InputDecoration(
  hintText: hint ?? label,
  suffixText: suffix,
  filled: true,
  fillColor: const Color(0xFF1B2B3D),
  border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF33465C))),
  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF33465C))),
  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF66C0F4), width: 1.5)),
);
