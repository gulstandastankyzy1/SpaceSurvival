import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class NeonCard extends StatelessWidget {
  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
    this.glowColor = AppColors.cyan,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [AppColors.glow(glowColor, blur: 18, opacity: 0.18)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: glowColor.withValues(alpha: 0.35)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
