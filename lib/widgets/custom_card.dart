import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool hasShadow;
  final Border? border;

  const CustomCard({
    Key? key,
    required this.child,
    this.color,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.hasShadow = true,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultPadding = ResponsiveHelper.getValueForScreenType<EdgeInsets>(
      context: context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(20),
      desktop: const EdgeInsets.all(24),
    );

    final defaultBorderRadius = BorderRadius.circular(
      ResponsiveHelper.getValueForScreenType<double>(
        context: context,
        mobile: 12,
        tablet: 16,
        desktop: 20,
      ),
    );

    final cardContent = Padding(
      padding: padding ?? defaultPadding,
      child: child,
    );

    if (onTap != null) {
      return Card(
        color: color,
        elevation: hasShadow ? (elevation ?? 2) : 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? defaultBorderRadius,
          side: border != null ? border!.top : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? defaultBorderRadius,
          child: cardContent,
        ),
      );
    }

    return Card(
      color: color,
      elevation: hasShadow ? (elevation ?? 2) : 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? defaultBorderRadius,
        side: border != null ? border!.top : BorderSide.none,
      ),
      child: cardContent,
    );
  }
}