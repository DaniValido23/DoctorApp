import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1400;
  static const double extraLargeDesktopBreakpoint = 1700;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Returns appropriate number of columns for grid layouts
  static int getGridColumns(BuildContext context, {int maxColumns = 4}) {
    final width = getScreenWidth(context);

    if (width < mobileBreakpoint) {
      // Mobile: 1 column
      return 1;
    } else if (width < tabletBreakpoint) {
      // Tablet: 2 columns
      return 2;
    } else if (width < desktopBreakpoint) {
      // Small desktop: 3 columns
      return 3;
    } else {
      // Desktop: 4 columns (or maxColumns if less)
      return maxColumns.clamp(1, 4);
    }
  }

  /// Returns appropriate padding for the screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Returns maximum content width for centered layouts
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);

    if (isMobile(context)) {
      return screenWidth;
    } else if (isTablet(context)) {
      return 800;
    } else {
      return 1200;
    }
  }

  /// Returns appropriate card width for lists
  static double getCardWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else {
      return 400;
    }
  }

  /// Returns appropriate sidebar width
  static double getSidebarWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 280;
    } else {
      return 240;
    }
  }
}

/// Widget that adapts layout based on screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (ResponsiveUtils.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Widget that provides responsive padding and max width
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? ResponsiveUtils.getScreenPadding(context);
    final effectiveMaxWidth = maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: child,
        ),
      ),
    );
  }
}