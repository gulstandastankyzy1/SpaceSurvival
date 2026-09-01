import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool getBool(String key, {required bool fallback}) {
    return _prefs.getBool(key) ?? fallback;
  }

  static String getString(String key, {required String fallback}) {
    return _prefs.getString(key) ?? fallback;
  }

  static Future<void> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  static Future<void> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  static int bestScore() {
    final scores = topScores();
    return scores.isEmpty ? 0 : scores.first;
  }

  static List<int> topScores() {
    final saved = _prefs.getStringList('scores') ?? <String>[];
    final scores = saved.map((item) => int.tryParse(item) ?? 0).toList();
    scores.sort((a, b) => b.compareTo(a));
    return scores.take(5).toList();
  }

  static Future<void> saveScore(int score) {
    final scores = [...topScores(), score]..sort((a, b) => b.compareTo(a));
    final topFive = scores.take(5).map((item) => item.toString()).toList();
    return _prefs.setStringList('scores', topFive);
  }
}
