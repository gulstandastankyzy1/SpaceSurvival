import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class StarField extends StatefulWidget {
  const StarField({super.key, this.child, this.speed = 1});

  final Widget? child;
  final double speed;

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final random = Random(24);
    _stars = List.generate(90, (_) {
      return _Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 0.8 + random.nextDouble() * 2.2,
        speed: 0.25 + random.nextDouble(),
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarFieldPainter(
            stars: _stars,
            progress: _controller.value,
            speed: widget.speed,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _Star {
  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
}

class _StarFieldPainter extends CustomPainter {
  _StarFieldPainter({
    required this.stars,
    required this.progress,
    required this.speed,
    required this.isDark,
  });

  final List<_Star> stars;
  final double progress;
  final double speed;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                AppColors.darkSpace,
                AppColors.deepSpace,
                const Color(0xFF190D2F),
              ]
            : [
                AppColors.lightSpace,
                const Color(0xFFE6F7FF),
                const Color(0xFFF4E9FF),
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    for (final star in stars) {
      final y = ((star.y + progress * star.speed * speed) % 1) * size.height;
      final x = star.x * size.width;
      final alpha = isDark ? 0.75 : 0.45;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y), star.radius, paint);
    }

    final gridPaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: isDark ? 0.07 : 0.1)
      ..strokeWidth = 1;
    for (double y = size.height * 0.56; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.speed != speed;
  }
}
