import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  /// Returns a value based on the screen size
  /// For example: getValueForScreenType<double>(
  ///   context: context,
  ///   mobile: 12,
  ///   tablet: 16,
  ///   desktop: 20,
  /// )
  static T getValueForScreenType<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Returns a widget based on the screen size
  static Widget getWidgetForScreenType({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Returns a responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getValueForScreenType<EdgeInsets>(
      context: context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// Returns a responsive horizontal padding based on screen size
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    return getValueForScreenType<EdgeInsets>(
      context: context,
      mobile: const EdgeInsets.symmetric(horizontal: 16),
      tablet: const EdgeInsets.symmetric(horizontal: 48),
      desktop: const EdgeInsets.symmetric(horizontal: 96),
    );
  }

  /// Returns a responsive width constraint based on screen size
  static double getResponsiveWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isDesktop(context)) {
      return width * 0.5; // 50% of screen width for desktop
    } else if (isTablet(context)) {
      return width * 0.7; // 70% of screen width for tablet
    } else {
      return width; // Full width for mobile
    }
  }

  /// Returns a responsive font size based on screen size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    return getValueForScreenType<double>(
      context: context,
      mobile: baseFontSize,
      tablet: baseFontSize * 1.2,
      desktop: baseFontSize * 1.4,
    );
  }
}