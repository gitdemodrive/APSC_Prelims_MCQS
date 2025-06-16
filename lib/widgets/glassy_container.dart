import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/responsive_helper.dart';

class GlassyContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? blurSigma;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Gradient? gradient;

  const GlassyContainer({
    Key? key,
    required this.child,
    this.color,
    this.blurSigma = 10.0,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.border,
    this.boxShadow,
    this.width,
    this.height,
    this.alignment,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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

    final defaultColor = isDarkMode
        ? Colors.black.withOpacity(0.7)
        : Colors.white.withOpacity(0.7);

    final defaultBorder = Border.all(
      color: isDarkMode
          ? Colors.white.withOpacity(0.1)
          : Colors.white.withOpacity(0.5),
      width: 1.5,
    );

    final defaultBoxShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ];

    final containerContent = ClipRRect(
      borderRadius: borderRadius ?? defaultBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma!, sigmaY: blurSigma!),
        child: Container(
          width: width,
          height: height,
          alignment: alignment,
          padding: padding ?? defaultPadding,
          decoration: BoxDecoration(
            color: color ?? defaultColor,
            borderRadius: borderRadius ?? defaultBorderRadius,
            border: border ?? defaultBorder,
            boxShadow: boxShadow ?? defaultBoxShadow,
            gradient: gradient,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? defaultBorderRadius,
          child: containerContent,
        ),
      );
    }

    return containerContent;
  }
}