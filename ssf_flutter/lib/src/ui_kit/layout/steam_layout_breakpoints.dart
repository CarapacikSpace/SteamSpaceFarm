/// Material 3 window-width breakpoints in logical pixels.
///
/// Use these for layout modes; individual controls still respect their parent's
/// constraints and the minimum space their contents need.
abstract final class SteamLayoutBreakpoints() {
  static const double minimumWindowWidth = 400;
  static const double medium = 600;
  static const double expanded = 840;
  static const double large = 1200;

  /// The catalog keeps its card actions below the heading at exactly 600 too.
  static bool wrapCardActions(double width) => width <= medium;
}
