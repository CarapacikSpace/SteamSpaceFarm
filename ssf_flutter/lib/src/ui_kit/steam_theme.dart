import 'package:material_ui/material_ui.dart';

abstract final class SteamThemeColors() {
  static const Color backgroundTop = Color(0xFF2D333C);
  static const Color backgroundMiddle = Color(0xFF23272D);
  static const Color background = Color(0xFF171D25);
  static const Color chrome = Color(0xFF171D25);
  static const Color surface = Color(0xFF24282F);
  static const Color surfaceRaised = Color(0xFF3D4450);
  static const Color control = Color(0x99212124);
  static const Color divider = Color(0x803D4450);
  static const Color text = Color(0xFFD6D7D8);
  static const Color textSecondary = Color(0xFF9CA4A7);
  static const Color blue = Color(0xFF1A9FFF);
  static const Color green = Color(0xFF75B022);
  static const Color error = Color(0xFFE35D6A);
}

abstract final class SteamThemeMetrics() {
  static const double appBarHeight = 48;
  static const double controlHeight = 36;
  static const double inputHeight = 48;
  static const double controlRadius = 3;
}

ThemeData buildSteamTheme() {
  const colors = ColorScheme.dark(
    primary: SteamThemeColors.blue,
    secondary: SteamThemeColors.green,
    surface: SteamThemeColors.surface,
    error: SteamThemeColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: SteamThemeColors.text,
  );
  const controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(SteamThemeMetrics.controlRadius)),
  );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colors,
    scaffoldBackgroundColor: SteamThemeColors.background,
    dividerColor: SteamThemeColors.divider,
    splashFactory: InkRipple.splashFactory,
    tooltipTheme: const TooltipThemeData(
      constraints: BoxConstraints(minHeight: 32),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: Color(0xFFB3B8BC), borderRadius: BorderRadius.all(Radius.circular(2))),
      textStyle: TextStyle(color: Colors.black, fontSize: 14, height: 1.4),
    ),
    appBarTheme: const AppBarTheme(
      toolbarHeight: SteamThemeMetrics.appBarHeight,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: SteamThemeColors.chrome,
      foregroundColor: SteamThemeColors.text,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: SteamThemeColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: .2,
      ),
    ),
    cardTheme: const CardThemeData(
      color: SteamThemeColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(SteamThemeMetrics.controlRadius))),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: SteamThemeColors.control,
      isDense: true,
      constraints: BoxConstraints(minHeight: SteamThemeMetrics.inputHeight),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      hintStyle: TextStyle(color: Color(0xFF808080), fontSize: 13),
      border: OutlineInputBorder(borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF32353A))),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: SteamThemeColors.blue)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        enabledMouseCursor: SystemMouseCursors.click,
        disabledMouseCursor: SystemMouseCursors.basic,
        foregroundColor: SteamThemeColors.textSecondary,
        minimumSize: const Size(SteamThemeMetrics.controlHeight, SteamThemeMetrics.controlHeight),
        maximumSize: const Size(SteamThemeMetrics.controlHeight, SteamThemeMetrics.controlHeight),
        padding: const EdgeInsets.all(8),
        shape: controlShape,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        enabledMouseCursor: SystemMouseCursors.click,
        disabledMouseCursor: SystemMouseCursors.basic,
        minimumSize: const Size(0, SteamThemeMetrics.controlHeight),
        maximumSize: const Size(double.infinity, SteamThemeMetrics.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: controlShape,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        enabledMouseCursor: SystemMouseCursors.click,
        disabledMouseCursor: SystemMouseCursors.basic,
        foregroundColor: SteamThemeColors.text,
        backgroundColor: SteamThemeColors.control,
        side: BorderSide.none,
        minimumSize: const Size(0, SteamThemeMetrics.controlHeight),
        maximumSize: const Size(double.infinity, SteamThemeMetrics.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: controlShape,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        enabledMouseCursor: SystemMouseCursors.click,
        disabledMouseCursor: SystemMouseCursors.basic,
        foregroundColor: SteamThemeColors.textSecondary,
        minimumSize: const Size(0, SteamThemeMetrics.controlHeight),
        shape: controlShape,
        textStyle: const TextStyle(fontSize: 13),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: SteamThemeColors.control,
      side: BorderSide.none,
      shape: controlShape,
      labelStyle: TextStyle(color: SteamThemeColors.text, fontSize: 12),
      padding: EdgeInsets.symmetric(horizontal: 4),
      labelPadding: EdgeInsets.symmetric(horizontal: 6),
      deleteIconColor: SteamThemeColors.textSecondary,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: SteamThemeColors.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(),
      textStyle: TextStyle(color: SteamThemeColors.text, fontSize: 14),
    ),
  );
}

class const SteamLibraryBackground({required final Widget child, super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [SteamThemeColors.backgroundTop, SteamThemeColors.backgroundMiddle, SteamThemeColors.background],
        stops: [0, .2, .6],
      ),
    ),
    child: child,
  );
}
