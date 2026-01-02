import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static double getResponsiveFontSize(BuildContext context, double size) {
    return isTablet(context) ? size * 1.2 : size;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    return isTablet(context)
        ? const EdgeInsets.all(24)
        : const EdgeInsets.all(16);
  }

  static double getResponsiveIconSize(BuildContext context, double size) {
    return isTablet(context) ? size * 1.2 : size;
  }
}

