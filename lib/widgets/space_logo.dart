import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class SpaceLogo extends StatelessWidget {
  const SpaceLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'space-logo',
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 74 : 108,
              height: compact ? 74 : 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.neonGradient(),
                boxShadow: [AppColors.glow(AppColors.cyan, blur: 32)],
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: compact ? 38 : 56,
              ),
            ),
            SizedBox(height: compact ? 10 : 18),
            Text(
              'SPACE SURVIVAL',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: compact ? 24 : 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
