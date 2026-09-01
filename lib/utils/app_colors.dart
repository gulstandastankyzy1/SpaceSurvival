import 'package:flutter/material.dart';

class AppColors {
  static const darkSpace = Color(0xFF070A18);
  static const deepSpace = Color(0xFF11142B);
  static const lightSpace = Color(0xFFF4F7FF);
  static const cyan = Color(0xFF28F4FF);
  static const purple = Color(0xFF9B5CFF);
  static const pink = Color(0xFFFF3DF2);
  static const amber = Color(0xFFFFCF5A);
  static const danger = Color(0xFFFF4D6D);

  static LinearGradient neonGradient({bool reversed = false}) {
    final colors = [cyan, purple, pink];
    return LinearGradient(
      colors: reversed ? colors.reversed.toList() : colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static BoxShadow glow(
    Color color, {
    double blur = 22,
    double opacity = 0.45,
  }) {
    return BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: blur,
      spreadRadius: 1,
    );
  }
}
