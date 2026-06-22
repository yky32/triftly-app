import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Frosted “liquid glass” surface — blur + translucent fill + soft highlight edge.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    this.borderRadius,
    this.padding,
    this.blur = 24,
    this.tint,
    super.key,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(AppRadii.xl);

    final fill = tint ??
        (isDark
            ? const Color(0xFF2A2A2C).withValues(alpha: 0.62)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.55));

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.9);

    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.7);

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: AppShadows.navBar(context),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                color: fill,
                border: Border.all(color: borderColor, width: 1.2),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [highlight, Colors.transparent],
                  stops: const [0, 0.5],
                ),
              ),
              child: padding != null ? Padding(padding: padding!, child: child) : child,
            ),
          ),
        ),
      ),
    );
  }
}
