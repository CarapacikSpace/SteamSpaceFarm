import 'package:material_ui/material_ui.dart';

abstract final class SteamUiColors() {
  static const background = Color(0xFF171D25);
  static const raisedSurface = Color(0xFF3D4450);
  static const raisedSurfaceHover = Color(0xFF48505E);
  static const menuHover = Color(0xFF5A6069);
  static const text = Color(0xFFDFE3E6);
  static const textStrong = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFFACB2B8);
  static const textSubtitle = Color(0xFFD6D9DC);
  static const textNote = Color(0xFF636B74);
  static const accent = Color(0xFF1A9FFF);
  static const wishlist = Color(0xFF03628B);
  static const searchText = Color(0xFFFFFFFF);
  static const searchPlaceholder = Color(0xFFDCDEDF);
  static const searchSurface = Color(0x20FFFFFF);
  static const searchSurfaceFocused = Color(0xFF242931);
  static const searchBorder = Color(0x24FFFFFF);
  static const searchBorderHover = Color(0x631AA0FF);
  static const searchButtonHover = Color(0xFF45ACFF);
  static const seeMoreSurface = Color(0xFFCCCCCC);
  static const seeMoreSurfaceHover = Color(0xFFFFFFFF);
  static const seeMoreText = Color(0xFF000000);
  static const playtimeSurface = Color(0xFF3D4450);
  static const running = Color(0xFFA1CD44);
  static const overflowSurface = Color(0xFFE5E5E5);
  static const overflowSurfaceHover = Color(0xFF67C1F5);
  static const filterBarrier = Color(0x99191D25);
  static const pressed = Color(0xFF393F49);
  static const disabledSurface = Color(0x593D434D);
  static const disabledText = Color(0xFF464D58);
}

abstract final class SteamUiMetrics() {
  static const controlRadius = 2.0;
  static const buttonHeight = 32.0;
  static const touchButtonHeight = 40.0;
  static const seeMoreButtonHeight = 24.0;
  static const inputHeight = 44.0;
  static const touchInputHeight = 48.0;
  static const controlHeight = 36.0;
  static const catalogControlHeight = 34.0;
  static const dropdownWidth = 250.0;
  static const checkboxSize = 20.0;
  static const ownershipOverlap = 12.0;
  static const cardHoverScale = 1.03;
}

abstract final class SteamUiDurations() {
  static const fast = Duration(milliseconds: 100);
  static const regular = Duration(milliseconds: 200);
  static const pressed = Duration(milliseconds: 40);
}

abstract final class SteamUiGradients() {
  static const primary = LinearGradient(colors: [Color(0xFF3A9FEF), Color(0xFF2565D5)]);
  static const primaryHover = LinearGradient(colors: [Color(0xFF47BFFF), Color(0xFF319EE0)]);
  static const primaryPressed = LinearGradient(colors: [Color(0xFF337DDF), Color(0xFF1D4CC7)]);
  static const ownershipPersonal = LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: [Color(0xFFB7255A), Color(0xFF8C1C5F), Color(0xFF610E5D)],
    stops: [.05, .5, .95],
  );
  static const ownershipFamily = LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: [Color(0xFF107C65), Color(0xFF2E799F), Color(0xFF374984)],
    stops: [.05, .5, .95],
  );
  static const iconCard = LinearGradient(colors: [Color(0x4D565C67), Color(0x4D5A626C)]);
  static const iconCardHover = LinearGradient(colors: [Color(0x4D828997), Color(0x4DA3AAB2)]);
  static const run = LinearGradient(colors: [Color(0xFF8AC329), Color(0xFF4A7A16)], stops: [0, .6]);
  static const runHover = LinearGradient(colors: [Color(0xFFA4D93A), Color(0xFF5C8F1E)], stops: [0, .6]);
  static const runPressed = LinearGradient(colors: [Color(0xFF6F9F20), Color(0xFF355D10)], stops: [0, .6]);
}
