import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';

/// Glassmorphism card widget with blur effect
/// Used for overlays, modals, and premium UI elements
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withValues(alpha: opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border:
                border ?? Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
