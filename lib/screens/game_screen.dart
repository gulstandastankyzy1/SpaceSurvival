import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/game_object.dart';
import '../models/game_settings.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/game_painters.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';
import '../widgets/star_field.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.settings});

  final GameSettings settings;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Random _random = Random();
  final List<GameObject> _objects = [];
  final List<Particle> _particles = [];

  Size _gameSize = Size.zero;
  Duration _lastElapsed = Duration.zero;
  double _playerX = 180;
  double _score = 0;
  double _countdown = 3;
  double _spawnTimer = 0;
  double _survivalTime = 0;
  int _bestScore = 0;
  int _lives = 3;
  bool _paused = false;
  bool _gameOver = false;
  bool _scoreSaved = false;

  @override
  void initState() {
    super.initState();
    _bestScore = StorageService.bestScore();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    if (_gameSize == Size.zero) {
      return;
    }

    setState(() {
      if (_paused || _gameOver) {
        _updateParticles(dt);
        return;
      }

      if (_countdown > 0) {
        _countdown -= dt;
        return;
      }

      // Game loop: every frame we move objects, add score, spawn new hazards,
      // and then check collisions. This is the heart of the game.
      _survivalTime += dt;
      _score += dt * 12;
      _spawnTimer -= dt;
      if (_spawnTimer <= 0) {
        _spawnObject();
        final pressure = min(_survivalTime / 55, 0.45);
        _spawnTimer = max(0.34, 0.92 - pressure);
      }

      _moveObjects(dt);
      _updateParticles(dt);
      _checkCollisions();
    });
  }

  void _spawnObject() {
    final isCrystal = _random.nextDouble() < 0.22;
    final size = isCrystal ? 30.0 : 34.0 + _random.nextDouble() * 28;
    final x = size + _random.nextDouble() * (_gameSize.width - size * 2);
    final difficultyBoost = 1 + min(_survivalTime / 45, 1.25);
    final baseSpeed = isCrystal ? 150.0 : 120.0 + _random.nextDouble() * 95;

    _objects.add(
      GameObject(
        type: isCrystal ? GameObjectType.crystal : GameObjectType.asteroid,
        position: Offset(x, -size),
        size: size,
        speed: baseSpeed * difficultyBoost * widget.settings.speedMultiplier,
        rotation: _random.nextDouble() * pi,
      ),
    );
  }

  void _moveObjects(double dt) {
    for (final object in _objects) {
      object.position += Offset(0, object.speed * dt);
      object.rotation +=
          dt * (object.type == GameObjectType.asteroid ? 1.4 : 2.6);
    }
    _objects.removeWhere(
      (object) => object.position.dy > _gameSize.height + 80,
    );
  }

  void _checkCollisions() {
    // Collision detection is simple on purpose: each object and the ship use
    // rectangles. If the rectangles overlap, we count it as a hit/collection.
    final shipRect = Rect.fromCenter(
      center: Offset(_playerX, _gameSize.height - 86),
      width: 52,
      height: 64,
    );

    final hitObjects = <GameObject>[];
    for (final object in _objects) {
      if (!shipRect.overlaps(object.rect.deflate(6))) {
        continue;
      }
      hitObjects.add(object);
      if (object.type == GameObjectType.crystal) {
        _score += 65;
        _burst(object.position, AppColors.cyan, count: 12);
        AudioService.instance.playCrystal();
      } else {
        _lives -= 1;
        _burst(object.position, AppColors.danger, count: 18);
        AudioService.instance.playExplosion();
        if (_lives <= 0) {
          _finishGame();
        }
      }
    }
    _objects.removeWhere(hitObjects.contains);
  }

  void _burst(Offset origin, Color color, {required int count}) {
    for (var i = 0; i < count; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 55 + _random.nextDouble() * 130;
      _particles.add(
        Particle(
          position: origin,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          color: color,
          life: 1,
          size: 2 + _random.nextDouble() * 4,
        ),
      );
    }
  }

  void _updateParticles(double dt) {
    for (final particle in _particles) {
      particle.position += particle.velocity * dt;
      particle.life -= dt * 1.8;
      particle.size = max(0, particle.size - dt * 2);
    }
    _particles.removeWhere((particle) => particle.life <= 0);
  }

  void _finishGame() {
    _gameOver = true;
    if (!_scoreSaved) {
      _scoreSaved = true;
      final finalScore = _score.round();
      _bestScore = max(_bestScore, finalScore);
      StorageService.saveScore(finalScore);
      AudioService.instance.playGameOver();
    }
  }

  void _restart() {
    setState(() {
      _objects.clear();
      _particles.clear();
      _score = 0;
      _countdown = 3;
      _spawnTimer = 0;
      _survivalTime = 0;
      _lives = 3;
      _paused = false;
      _gameOver = false;
      _scoreSaved = false;
      _playerX = _gameSize.width / 2;
    });
  }

  void _movePlayer(Offset localPosition) {
    if (_paused || _gameOver || _gameSize == Size.zero) {
      return;
    }
    setState(() {
      _playerX = localPosition.dx.clamp(34, _gameSize.width - 34);
    });
  }

  @override
  Widget build(BuildContext context) {
    final score = _score.round();

    return Scaffold(
      body: StarField(
        speed: 1.35,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              _gameSize = constraints.biggest;
              if (_playerX == 180) {
                _playerX = _gameSize.width / 2;
              }
              return GestureDetector(
                onPanStart: (details) => _movePlayer(details.localPosition),
                onPanUpdate: (details) => _movePlayer(details.localPosition),
                onTapDown: (details) => _movePlayer(details.localPosition),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: _gameSize,
                      painter: GamePainter(
                        playerX: _playerX,
                        objects: _objects,
                        particles: _particles,
                        shipPulse: sin(_survivalTime * 5).abs(),
                      ),
                    ),
                    _Hud(
                      score: score,
                      bestScore: max(_bestScore, score),
                      lives: _lives,
                      paused: _paused,
                      onPause: () => setState(() => _paused = !_paused),
                      onRestart: _restart,
                      onBack: () => Navigator.pop(context),
                    ),
                    if (_countdown > 0 && !_gameOver)
                      _Countdown(value: _countdown),
                    if (_paused && !_gameOver)
                      _PauseOverlay(
                        onResume: () {
                          setState(() => _paused = false);
                        },
                        onRestart: _restart,
                      ),
                    if (_gameOver)
                      _GameOverOverlay(
                        score: score,
                        bestScore: _bestScore,
                        onRestart: _restart,
                        onMenu: () => Navigator.pop(context),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({
    required this.score,
    required this.bestScore,
    required this.lives,
    required this.paused,
    required this.onPause,
    required this.onRestart,
    required this.onBack,
  });

  final int score;
  final int bestScore;
  final int lives;
  final bool paused;
  final VoidCallback onPause;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _IconAction(
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
            label: 'Back',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: NeonCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              glowColor: AppColors.cyan,
              child: Row(
                children: [
                  Expanded(
                    child: _Metric(label: 'Score', value: '$score'),
                  ),
                  Expanded(
                    child: _Metric(label: 'Best', value: '$bestScore'),
                  ),
                  Row(
                    children: List.generate(3, (index) {
                      return Icon(
                        index < lives
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: AppColors.danger,
                        size: 18,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _IconAction(
            icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            onPressed: onPause,
            label: paused ? 'Resume' : 'Pause',
          ),
          const SizedBox(width: 8),
          _IconAction(
            icon: Icons.restart_alt_rounded,
            onPressed: onRestart,
            label: 'Restart',
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.cyan),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onPressed,
    required this.label,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [AppColors.glow(AppColors.purple, blur: 14, opacity: 0.25)],
      ),
      child: IconButton.filledTonal(
        tooltip: label,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final number = value.ceil().clamp(1, 3);
    return Center(
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: 1 + (value % 1) * 0.25,
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: 92,
            fontWeight: FontWeight.w900,
            color: AppColors.cyan,
            shadows: [Shadow(color: AppColors.cyan, blurRadius: 24)],
          ),
        ),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({required this.onResume, required this.onRestart});

  final VoidCallback onResume;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return _CenterOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Paused', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          NeonButton(
            label: 'Resume',
            icon: Icons.play_arrow_rounded,
            onPressed: onResume,
          ),
          const SizedBox(height: 12),
          NeonButton(
            label: 'Restart',
            icon: Icons.restart_alt_rounded,
            onPressed: onRestart,
          ),
        ],
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.score,
    required this.bestScore,
    required this.onRestart,
    required this.onMenu,
  });

  final int score;
  final int bestScore;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return _CenterOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Game Over', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Score: $score   Best: $bestScore'),
          const SizedBox(height: 18),
          NeonButton(
            label: 'Play Again',
            icon: Icons.restart_alt_rounded,
            onPressed: onRestart,
          ),
          const SizedBox(height: 12),
          NeonButton(
            label: 'Menu',
            icon: Icons.home_rounded,
            onPressed: onMenu,
          ),
        ],
      ),
    );
  }
}

class _CenterOverlay extends StatelessWidget {
  const _CenterOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.46),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: NeonCard(glowColor: AppColors.pink, child: child),
      ),
    );
  }
}
