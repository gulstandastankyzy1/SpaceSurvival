import 'package:flutter/material.dart';

import '../models/game_settings.dart';
import '../services/audio_service.dart';
import '../utils/page_transitions.dart';
import '../widgets/neon_button.dart';
import '../widgets/space_logo.dart';
import '../widgets/star_field.dart';
import 'home_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.settings});

  final GameSettings settings;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.82,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    AudioService.instance.playTap();
    AudioService.instance.startMusic();
    // Navigation is intentionally simple: push the next screen with a custom
    // fade/scale route so students can explain it during presentation.
    Navigator.of(
      context,
    ).push(fadeScaleRoute(HomeScreen(settings: widget.settings)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarField(
        speed: 0.7,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SpaceLogo(),
                      const SizedBox(height: 42),
                      Text(
                        'Dodge asteroids. Collect energy. Survive the galaxy.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 34),
                      NeonButton(
                        label: 'Tap to Start',
                        icon: Icons.play_arrow_rounded,
                        onPressed: _start,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
