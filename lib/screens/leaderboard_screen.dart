import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_card.dart';
import '../widgets/star_field.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scores = StorageService.topScores();

    return Scaffold(
      body: StarField(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Back',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Leaderboard',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: NeonCard(
                        glowColor: AppColors.pink,
                        child: scores.isEmpty
                            ? const Center(
                                child: Text(
                                  'No scores yet. Start a run and claim rank #1.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.separated(
                                itemCount: scores.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final rank = index + 1;
                                  return _ScoreRow(
                                    rank: rank,
                                    score: scores[index],
                                  );
                                },
                              ),
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

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.rank, required this.score});

  final int rank;
  final int score;

  @override
  Widget build(BuildContext context) {
    final medalColor = switch (rank) {
      1 => AppColors.amber,
      2 => AppColors.cyan,
      3 => AppColors.purple,
      _ => Theme.of(context).colorScheme.onSurfaceVariant,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: medalColor.withValues(alpha: 0.12),
        border: Border.all(color: medalColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: medalColor.withValues(alpha: 0.22),
            child: Text('#$rank', style: TextStyle(color: medalColor)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Survival Run',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            '$score',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: medalColor),
          ),
        ],
      ),
    );
  }
}
