import 'package:flutter/cupertino.dart';

class SteamSwitch extends StatelessWidget {
  const SteamSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: const Color(0xFF1A9FFF),
      inactiveTrackColor: const Color(0xFF3A3F45),
    );
  }
}
