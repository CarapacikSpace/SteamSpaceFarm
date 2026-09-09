import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/services.dart' show FilteringTextInputFormatter, TextInputFormatter;
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/feature/catalog/model/library_ownership.dart';
import 'package:ssf_flutter/src/feature/catalog/widget/catalog_labels.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';
import 'package:ssf_flutter/src/ui_kit/steam_ui_kit.dart';

enum CatalogStatus() {
  all,
  running,
  marked,
  hidden,
  favorite,
}

String catalogStatusLabel(CatalogStatus status) => switch (status) {
  CatalogStatus.all => GeneratedLocalizations.current.all,
  CatalogStatus.running => GeneratedLocalizations.current.statusRunning,
  CatalogStatus.marked => GeneratedLocalizations.current.marked,
  CatalogStatus.hidden => GeneratedLocalizations.current.hidden,
  CatalogStatus.favorite => GeneratedLocalizations.current.favorites,
};

class const CatalogFilterState({
  required final Set<SteamAppType> selectedTypes,
  required final Set<LibraryOwnership> ownership,
  required final int? minimumMinutes,
  required final int? maximumMinutes,
}) {
  factory initial() => CatalogFilterState(
    selectedTypes: Set<SteamAppType>.of(SteamAppType.values),
    ownership: Set<LibraryOwnership>.of(LibraryOwnership.values),
    minimumMinutes: null,
    maximumMinutes: null,
  );

  int get activeGroupCount {
    var count = 0;
    if (selectedTypes.length != SteamAppType.values.length) {
      count++;
    }
    if (ownership.length != LibraryOwnership.values.length) {
      count++;
    }
    if (minimumMinutes != null || maximumMinutes != null) {
      count++;
    }
    return count;
  }
}

class const CatalogFilterSheet({
  required final CatalogFilterState initialState,
  required final CatalogStatus status,
  required final bool useHours,
  required final ValueChanged<CatalogFilterState> onChanged,
  required final ValueChanged<CatalogStatus> onStatusChanged,
  required final ValueChanged<bool> onUseHoursChanged,
  required final VoidCallback onClose,
  final bool embedded = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<CatalogFilterSheet> createState() => _CatalogFilterSheetState();
}

class _CatalogFilterSheetState() extends State<CatalogFilterSheet> {
  late Set<SteamAppType> _selectedTypes;
  late Set<LibraryOwnership> _ownership;
  late CatalogStatus _status;
  late bool _useHours;
  late final TextEditingController _minimumController;
  late final TextEditingController _maximumController;

  int get _divisor => _useHours ? 60 : 1;

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set<SteamAppType>.of(widget.initialState.selectedTypes);
    _ownership = Set<LibraryOwnership>.of(widget.initialState.ownership);
    _status = widget.status;
    _useHours = widget.useHours;
    _minimumController = TextEditingController(text: _displayValue(widget.initialState.minimumMinutes));
    _maximumController = TextEditingController(text: _displayValue(widget.initialState.maximumMinutes));
  }

  @override
  void dispose() {
    _minimumController.dispose();
    _maximumController.dispose();
    super.dispose();
  }

  String _displayValue(int? minutes) {
    if (minutes == null) {
      return '';
    }
    if (!_useHours) {
      return '$minutes';
    }
    return (minutes / Duration.minutesPerHour)
        .toStringAsFixed(4)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  void didUpdateWidget(covariant CatalogFilterSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _status = widget.status;
    }
    if (oldWidget.useHours != widget.useHours) {
      _useHours = widget.useHours;
    }
    if (oldWidget.useHours != widget.useHours || !_sameState(widget.initialState, _currentState)) {
      _applyState(widget.initialState);
    }
  }

  CatalogFilterState get _currentState => CatalogFilterState(
    selectedTypes: Set<SteamAppType>.of(_selectedTypes),
    ownership: Set<LibraryOwnership>.of(_ownership),
    minimumMinutes: _parseMinutes(_minimumController.text),
    maximumMinutes: _parseMinutes(_maximumController.text),
  );

  void _applyState(CatalogFilterState state) {
    _selectedTypes = Set<SteamAppType>.of(state.selectedTypes);
    _ownership = Set<LibraryOwnership>.of(state.ownership);
    _minimumController.text = _displayValue(state.minimumMinutes);
    _maximumController.text = _displayValue(state.maximumMinutes);
  }

  void _notify() {
    widget.onChanged(_currentState);
  }

  int? _parseMinutes(String value) {
    final double? parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return null;
    }
    return (parsed * _divisor).round();
  }

  List<TextInputFormatter> get _timeInputFormatters => _useHours
      ? [
          TextInputFormatter.withFunction((oldValue, newValue) {
            return RegExp(r'^\d*(?:[.,]\d{0,4})?$').hasMatch(newValue.text) ? newValue : oldValue;
          }),
        ]
      : [FilteringTextInputFormatter.digitsOnly];

  void _reset() {
    setState(() {
      _selectedTypes = Set<SteamAppType>.of(SteamAppType.values);
      _ownership = Set<LibraryOwnership>.of(LibraryOwnership.values);
      _status = CatalogStatus.all;
      _minimumController.clear();
      _maximumController.clear();
    });
    widget.onStatusChanged(CatalogStatus.all);
    _notify();
  }

  void _changeStatus(CatalogStatus status) {
    setState(() => _status = status);
    widget.onStatusChanged(status);
  }

  void _changeTimeUnit(bool useHours) {
    if (_useHours == useHours) {
      return;
    }
    final CatalogFilterState currentState = _currentState;
    setState(() {
      _useHours = useHours;
      _applyState(currentState);
    });
    widget.onUseHoursChanged(useHours);
    widget.onChanged(currentState);
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(GeneratedLocalizations.of(context).filters, style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Tooltip(
                    message: GeneratedLocalizations.of(context).close,
                    child: SteamButton(
                      compact: true,
                      iconOnly: true,
                      height: 32,
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close, size: 18),
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SteamFilterSection(
                title: GeneratedLocalizations.of(context).status,
                children: [
                  for (final CatalogStatus status in CatalogStatus.values)
                    SteamFilterItem(
                      selected: status == _status,
                      onPressed: () => _changeStatus(status),
                      child: Row(
                        children: [
                          Expanded(child: Text(catalogStatusLabel(status))),
                          if (status == _status) const Icon(Icons.check, size: 16, color: SteamUiColors.accent),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SteamFilterSection(
                title: GeneratedLocalizations.of(context).appType,
                children: [
                  for (final SteamAppType type in SteamAppType.values)
                    SteamFilterItem(
                      selected: _selectedTypes.contains(type),
                      onPressed: () {
                        setState(() {
                          _selectedTypes.contains(type) ? _selectedTypes.remove(type) : _selectedTypes.add(type);
                        });
                        _notify();
                      },
                      child: Row(
                        children: [
                          Expanded(child: Text(appTypeLabel(type))),
                          if (_selectedTypes.contains(type))
                            const Icon(Icons.check, size: 16, color: SteamUiColors.accent),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SteamFilterSection(
                title: GeneratedLocalizations.of(context).ownership,
                children: [
                  for (final LibraryOwnership ownership in LibraryOwnership.values)
                    SteamFilterItem(
                      selected: _ownership.contains(ownership),
                      onPressed: () {
                        setState(() {
                          _ownership.contains(ownership) ? _ownership.remove(ownership) : _ownership.add(ownership);
                        });
                        _notify();
                      },
                      child: Row(
                        children: [
                          Expanded(child: Text(ownershipLabel(ownership))),
                          if (_ownership.contains(ownership))
                            const Icon(Icons.check, size: 16, color: SteamUiColors.accent),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SteamFilterSection(
                title: GeneratedLocalizations.of(context).playtime,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 140,
                      child: SteamSegmentedControl<bool>(
                        values: const [true, false],
                        selected: _useHours,
                        labelBuilder: (value) => value
                            ? GeneratedLocalizations.of(context).hoursAbbreviation
                            : GeneratedLocalizations.of(context).minutesAbbreviation,
                        onChanged: _changeTimeUnit,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minimumController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: _timeInputFormatters,
                          decoration: InputDecoration(hintText: GeneratedLocalizations.of(context).minimumInclusive),
                          onChanged: (_) => _notify(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _maximumController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: _timeInputFormatters,
                          decoration: InputDecoration(hintText: GeneratedLocalizations.of(context).maximumExclusive),
                          onChanged: (_) => _notify(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SteamTextButton(onPressed: _reset, child: Text(GeneratedLocalizations.of(context).reset)),
                  const SizedBox(width: 8),
                  SteamButton(
                    variant: SteamButtonVariant.primary,
                    onPressed: widget.onClose,
                    child: Text(GeneratedLocalizations.of(context).done),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return widget.embedded ? content : SafeArea(child: content);
  }
}

bool _sameState(CatalogFilterState left, CatalogFilterState right) =>
    setEquals(left.selectedTypes, right.selectedTypes) &&
    setEquals(left.ownership, right.ownership) &&
    left.minimumMinutes == right.minimumMinutes &&
    left.maximumMinutes == right.maximumMinutes;
