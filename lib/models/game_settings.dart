import 'package:flutter/material.dart';

import '../services/storage_service.dart';

enum GameDifficulty { easy, medium, hard }

class GameSettings extends ChangeNotifier {
  bool soundOn = true;
  bool musicOn = true;
  bool darkTheme = true;
  GameDifficulty difficulty = GameDifficulty.medium;

  double get speedMultiplier {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 0.82;
      case GameDifficulty.medium:
        return 1;
      case GameDifficulty.hard:
        return 1.25;
    }
  }

  String get difficultyLabel {
    return difficulty.name[0].toUpperCase() + difficulty.name.substring(1);
  }

  Future<void> load() async {
    soundOn = StorageService.getBool('soundOn', fallback: true);
    musicOn = StorageService.getBool('musicOn', fallback: true);
    darkTheme = StorageService.getBool('darkTheme', fallback: true);
    final savedDifficulty = StorageService.getString(
      'difficulty',
      fallback: GameDifficulty.medium.name,
    );
    difficulty = GameDifficulty.values.firstWhere(
      (item) => item.name == savedDifficulty,
      orElse: () => GameDifficulty.medium,
    );
    notifyListeners();
  }

  Future<void> setSound(bool value) async {
    soundOn = value;
    notifyListeners();
    await StorageService.setBool('soundOn', value);
  }

  Future<void> setMusic(bool value) async {
    musicOn = value;
    notifyListeners();
    await StorageService.setBool('musicOn', value);
  }

  Future<void> setTheme(bool value) async {
    darkTheme = value;
    notifyListeners();
    await StorageService.setBool('darkTheme', value);
  }

  Future<void> setDifficulty(GameDifficulty value) async {
    difficulty = value;
    notifyListeners();
    await StorageService.setString('difficulty', value.name);
  }
}
