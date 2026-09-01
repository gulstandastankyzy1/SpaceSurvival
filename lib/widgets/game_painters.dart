import 'dart:math';

import 'package:flutter/material.dart';

import '../models/game_object.dart';
import '../utils/app_colors.dart';

class GamePainter extends CustomPainter {
  GamePainter({
    required this.playerX,
    required this.objects,
    required this.particles,
    required this.shipPulse,
  });

  final double playerX;
  final List<GameObject> objects;
  final List<Particle> particles;
  final double shipPulse;

  @override
  void paint(Canvas canvas, Size size) {
    _drawObjects(canvas);
    _drawParticles(canvas);
    _drawShip(canvas, size);
  }

  void _drawShip(Canvas canvas, Size size) {
    final center = Offset(playerX, size.height - 86);
    final glow = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.28 + shipPulse * 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, 34 + shipPulse * 8, glow);

    final ship = Path()
      ..moveTo(center.dx, center.dy - 34)
      ..lineTo(center.dx - 26, center.dy + 30)
      ..lineTo(center.dx, center.dy + 18)
      ..lineTo(center.dx + 26, center.dy + 30)
      ..close();
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, AppColors.cyan, AppColors.purple],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(ship.getBounds());
    canvas.drawPath(ship, paint);

    final cockpit = Paint()..color = AppColors.pink.withValues(alpha: 0.9);
    canvas.drawCircle(Offset(center.dx, center.dy - 5), 7, cockpit);

    final flame = Path()
      ..moveTo(center.dx - 9, center.dy + 24)
      ..quadraticBezierTo(
        center.dx,
        center.dy + 48 + shipPulse * 10,
        center.dx + 9,
        center.dy + 24,
      );
    final flamePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.amber, AppColors.pink],
      ).createShader(flame.getBounds());
    canvas.drawPath(flame, flamePaint);
  }

  void _drawObjects(Canvas canvas) {
    for (final object in objects) {
      canvas.save();
      canvas.translate(object.position.dx, object.position.dy);
      canvas.rotate(object.rotation);
      if (object.type == GameObjectType.asteroid) {
        _drawAsteroid(canvas, object.size);
      } else {
        _drawCrystal(canvas, object.size);
      }
      canvas.restore();
    }
  }

  void _drawAsteroid(Canvas canvas, double size) {
    final radius = size / 2;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = (pi * 2 / 10) * i;
      final rockyRadius = radius * (0.72 + (i.isEven ? 0.24 : 0.04));
      final point = Offset(cos(angle) * rockyRadius, sin(angle) * rockyRadius);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF7B88A8)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.purple.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawCrystal(Canvas canvas, double size) {
    final half = size / 2;
    final path = Path()
      ..moveTo(0, -half)
      ..lineTo(half * 0.7, 0)
      ..lineTo(0, half)
      ..lineTo(-half * 0.7, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.cyan.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader =
            const LinearGradient(
              colors: [Colors.white, AppColors.cyan, AppColors.purple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromCenter(center: Offset.zero, width: size, height: size),
            ),
    );
  }

  void _drawParticles(Canvas canvas) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.life.clamp(0, 1))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
