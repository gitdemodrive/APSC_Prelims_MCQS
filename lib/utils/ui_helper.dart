import 'package:flutter/material.dart';
import '../theme.dart';
import 'responsive_helper.dart';

/// A utility class for common UI calculations and styles
/// This helps reduce code duplication across widget files
class UIHelper {
  /// Returns default padding for containers based on screen size
  static EdgeInsets getDefaultPadding(BuildContext context) {
    return ResponsiveHelper.getValueForScreenType<EdgeInsets>(
      context: context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(20),
      desktop: const EdgeInsets.all(24),
    );
  }

  /// Returns default content padding for form fields based on screen size
  static EdgeInsets getFormFieldPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      vertical: ResponsiveHelper.getValueForScreenType<double>(
        context: context,
        mobile: 16,
        tablet: 18,
        desktop: 20,
      ),
      horizontal: ResponsiveHelper.getValueForScreenType<double>(
        context: context,
        mobile: 16,
        tablet: 18,
        desktop: 20,
      ),
    );
  }

  /// Returns default border radius for containers based on screen size
  static BorderRadius getDefaultBorderRadius(BuildContext context) {
    return BorderRadius.circular(
      ResponsiveHelper.getValueForScreenType<double>(
        context: context,
        mobile: 12,
        tablet: 16,
        desktop: 20,
      ),
    );
  }

  /// Returns default button border radius
  static BorderRadius getButtonBorderRadius() {
    return BorderRadius.circular(8);
  }

  /// Returns default border for glassy containers
  static Border getGlassyBorder(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Border.all(
      color: isDarkMode
          ? Colors.white.withOpacity(0.1)
          : Colors.white.withOpacity(0.5),
      width: 1.5,
    );
  }

  /// Returns default box shadow for cards and containers
  static List<BoxShadow> getDefaultBoxShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ];
  }

  /// Returns default color for glassy containers based on theme
  static Color getGlassyColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return isDarkMode
        ? Colors.black.withOpacity(0.7)
        : Colors.white.withOpacity(0.7);
  }

  /// Returns color based on score percentage
  static Color getScoreColor(double percentage) {
    if (percentage >= 80) {
      return AppTheme.successColor;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return AppTheme.errorColor;
    }
  }

  /// Returns message based on score percentage
  static String getScoreMessage(double percentage) {
    if (percentage >= 80) {
      return 'Excellent!';
    } else if (percentage >= 60) {
      return 'Good job!';
    } else if (percentage >= 40) {
      return 'Keep practicing!';
    } else {
      return 'Need improvement';
    }
  }
}