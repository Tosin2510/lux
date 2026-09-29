import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressStore {
  final String word;
  final int timeDone;

  ProgressStore(this.word, this.timeDone);

  Map<String, dynamic> toJson() => {'word': word, 'time': timeDone};

  factory ProgressStore.fromJson(Map<String, dynamic> j) =>
      ProgressStore(j['word'] as String, j['time'] as int);
}

class Progress {
  // This part basically holds the keys.
  // I made it static to avoid errors when using the keys.
  static const _completedKey = 'completed';
  static const _savedUserSessionKey = 'savedUserSession';

  // called after a win so that continue does not bring up a completed puzzle again.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedUserSessionKey);
  }

  // saves the game that is currently in progress (word, piece positions, hints left)
  // under the _savedUserSessionKey key.
  static Future<void> saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedUserSessionKey, jsonEncode(data));
  }

  // gets the saved game back, null if there isn't one
  static Future<Map<String, dynamic>?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_savedUserSessionKey);
    if (rawData == null) return null;
    try {
      return jsonDecode(rawData) as Map<String, dynamic>;
    } catch (_) {
      // If the data is not good or is in a wrong format.
      return null;
    }
  }

  // Basically adds completed puzzles.
  static Future<void> addCompletedPuzzles(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_completedKey) ?? [];
    raw.add(jsonEncode(ProgressStore(word, DateTime.now().millisecondsSinceEpoch).toJson()));
    await prefs.setStringList(_completedKey, raw);
  }

  // gets every completed puzzle back as a list, it is empty if there isnone
  static Future<List<ProgressStore>> loadCompletedPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_completedKey) ?? [];
    return raw.map((s) => ProgressStore.fromJson(jsonDecode(s))).toList();
  }
}