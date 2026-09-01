import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../services/audio_service.dart';
import '../utils/app_colors.dart';
import '../utils/page_transitions.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';
import '../widgets/space_logo.dart';
import '../widgets/star_field.dart';
import 'game_screen.dart';
import 'intro_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.settings});

  final GameSettings settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarField(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    const SpaceLogo(compact: true),
                    const SizedBox(height: 24),
                    NeonCard(
                      glowColor: AppColors.purple,
                      child: Column(
                        children: [
                          _MenuStatus(settings: settings),
                          const SizedBox(height: 20),
                          NeonButton(
                            label: 'Play',
                            icon: Icons.play_arrow_rounded,
                            onPressed: () {
                              AudioService.instance.playTap();
                              Navigator.of(context).push(
                                fadeScaleRoute(GameScreen(settings: settings)),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          NeonButton(
                            label: 'Settings',
                            icon: Icons.tune_rounded,
                            onPressed: () {
                              AudioService.instance.playTap();
                              Navigator.of(context).push(
                                fadeScaleRoute(
                                  SettingsScreen(settings: settings),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          NeonButton(
                            label: 'Leaderboard',
                            icon: Icons.leaderboard_rounded,
                            onPressed: () {
                              AudioService.instance.playTap();
                              Navigator.of(
                                context,
                              ).push(fadeScaleRoute(const LeaderboardScreen()));
                            },
                          ),
                          const SizedBox(height: 14),
                          NeonButton(
                            label: 'Exit',
                            icon: Icons.power_settings_new_rounded,
                            onPressed: () => _returnToIntro(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _returnToIntro(BuildContext context) async {
    await AudioService.instance.playTap();
    await AudioService.instance.stopMusic();
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      fadeScaleRoute(IntroScreen(settings: settings)),
      (route) => false,
    );
  }
}

class _MenuStatus extends StatelessWidget {
  const _MenuStatus({required this.settings});

  final GameSettings settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.cyan.withValues(alpha: 0.08),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatusChip(
                icon: Icons.bolt_rounded,
                label: settings.difficultyLabel,
              ),
              _StatusChip(
                icon: settings.musicOn
                    ? Icons.music_note_rounded
                    : Icons.music_off_rounded,
                label: settings.musicOn ? 'Music On' : 'Music Off',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.cyan, size: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
