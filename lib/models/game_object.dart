import 'dart:ui';

enum GameObjectType { asteroid, crystal }

class GameObject {
  GameObject({
    required this.type,
    required this.position,
    required this.size,
    required this.speed,
    this.rotation = 0,
  });

  GameObjectType type;
  Offset position;
  double size;
  double speed;
  double rotation;

  Rect get rect => Rect.fromCenter(center: position, width: size, height: size);
}

class Particle {
  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.life,
    required this.size,
  });

  Offset position;
  Offset velocity;
  Color color;
  double life;
  double size;
}
