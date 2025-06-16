import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'dart:math' as math;

/// A utility class that provides helper methods for animations throughout the app.
/// This centralizes animation logic to reduce duplication and improve maintainability.
class AnimationHelper {
  /// Creates a standard animation controller with consistent settings
  /// 
  /// [vsync] - The TickerProvider (usually a State with SingleTickerProviderStateMixin)
  /// [duration] - Duration of the animation (defaults to 10 seconds)
  /// [autoStart] - Whether to automatically start the animation
  /// [repeat] - Whether the animation should repeat
  /// [reverse] - Whether the animation should reverse when repeating
  static AnimationController createController({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 10),
    bool autoStart = true,
    bool repeat = true,
    bool reverse = true,
  }) {
    final controller = AnimationController(
      vsync: vsync,
      duration: duration,
    );
    
    if (autoStart && repeat) {
      controller.repeat(reverse: reverse);
    } else if (autoStart) {
      controller.forward();
    }
    
    return controller;
  }
  
  /// Creates a standard tween animation with consistent settings
  /// 
  /// [controller] - The animation controller to drive this animation
  /// [begin] - The starting value (defaults to 0.0)
  /// [end] - The ending value (defaults to 1.0)
  /// [curve] - The curve to apply (defaults to linear)
  static Animation<double> createAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.linear,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }
  
  /// Creates a floating animation effect for UI elements
  /// 
  /// [animation] - The animation that drives this effect
  /// [baseOffset] - The base position
  /// [amplitude] - How far the element should move (defaults to 20)
  static double getFloatingOffset(Animation<double> animation, double baseOffset, {double amplitude = 20}) {
    return baseOffset + (animation.value * amplitude);
  }
  
  /// Creates a breathing animation effect for UI elements
  /// 
  /// [animation] - The animation that drives this effect
  /// [baseSize] - The base size
  /// [amplitude] - How much the element should scale (defaults to 0.1)
  static double getBreathingSize(Animation<double> animation, double baseSize, {double amplitude = 0.1}) {
    // Using sine wave for smooth breathing effect
    final wave = (math.sin(animation.value * math.pi * 2) + 1) / 2;
    return baseSize * (1 + (wave * amplitude));
  }
}