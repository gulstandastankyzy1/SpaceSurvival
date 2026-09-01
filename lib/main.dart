import 'package:flutter/material.dart';

import 'models/game_settings.dart';
import 'screens/intro_screen.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  final settings = GameSettings();
  await settings.load();
  await AudioService.instance.init(settings);

  runApp(SpaceSurvivalApp(settings: settings));
}

class SpaceSurvivalApp extends StatelessWidget {
  const SpaceSurvivalApp({super.key, required this.settings});

  final GameSettings settings;

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder is a beginner-friendly way to rebuild the app when our
    // simple settings object changes. No complex state-management setup needed.
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Space Survival',
          debugShowCheckedModeBanner: false,
          themeMode: settings.darkTheme ? ThemeMode.dark : ThemeMode.light,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: IntroScreen(settings: settings),
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF12172C) : Colors.white;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkSpace
          : AppColors.lightSpace,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.cyan,
        brightness: brightness,
        surface: surface,
        primary: AppColors.cyan,
        secondary: AppColors.purple,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
        bodyMedium: TextStyle(letterSpacing: 0),
      ),
    );
  }
}
