import 'package:flutter/material.dart';

import '../models/game_settings.dart';
import '../services/audio_service.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_card.dart';
import '../widgets/star_field.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings});

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
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      title: 'Settings',
                      onBack: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 18),
                    NeonCard(
                      glowColor: AppColors.cyan,
                      child: AnimatedBuilder(
                        animation: settings,
                        builder: (context, _) {
                          return Column(
                            children: [
                              _SwitchTile(
                                icon: settings.soundOn
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                                title: 'Sound Effects',
                                value: settings.soundOn,
                                onChanged: (value) async {
                                  await settings.setSound(value);
                                  await AudioService.instance
                                      .updateFromSettings(settings);
                                  await AudioService.instance.playTap();
                                },
                              ),
                              _SwitchTile(
                                icon: settings.musicOn
                                    ? Icons.music_note_rounded
                                    : Icons.music_off_rounded,
                                title: 'Background Music',
                                value: settings.musicOn,
                                onChanged: (value) async {
                                  await settings.setMusic(value);
                                  await AudioService.instance
                                      .updateFromSettings(settings);
                                },
                              ),
                              _SwitchTile(
                                icon: settings.darkTheme
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                title: settings.darkTheme
                                    ? 'Dark Theme'
                                    : 'Light Theme',
                                value: settings.darkTheme,
                                onChanged: settings.setTheme,
                              ),
                              const SizedBox(height: 18),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Difficulty',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SegmentedButton<GameDifficulty>(
                                segments: const [
                                  ButtonSegment(
                                    value: GameDifficulty.easy,
                                    label: Text('Easy'),
                                    icon: Icon(Icons.shield_rounded),
                                  ),
                                  ButtonSegment(
                                    value: GameDifficulty.medium,
                                    label: Text('Medium'),
                                    icon: Icon(Icons.bolt_rounded),
                                  ),
                                  ButtonSegment(
                                    value: GameDifficulty.hard,
                                    label: Text('Hard'),
                                    icon: Icon(
                                      Icons.local_fire_department_rounded,
                                    ),
                                  ),
                                ],
                                selected: {settings.difficulty},
                                onSelectionChanged: (value) {
                                  settings.setDifficulty(value.first);
                                },
                              ),
                            ],
                          );
                        },
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
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Back',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: value
            ? AppColors.cyan.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? AppColors.cyan : null),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
