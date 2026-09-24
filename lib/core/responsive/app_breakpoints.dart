import 'package:flutter/widgets.dart';

enum ScreenSize { compact, medium, expanded }

/// Compact < 600, medium 600-1024, expanded > 1024.
abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 1024;

  static ScreenSize of(double width) {
    if (width < compact) return ScreenSize.compact;
    if (width <= medium) return ScreenSize.medium;
    return ScreenSize.expanded;
  }
}

extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => AppBreakpoints.of(MediaQuery.sizeOf(this).width);
  bool get isCompact => screenSize == ScreenSize.compact;
}
