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
  
  static const _completedKey = 'completed';
  static const _savedUserSessionKey = 'savedUserSession';

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedUserSessionKey);
  }

  
  static Future<void> saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedUserSessionKey, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_savedUserSessionKey);
    if (rawData == null) return null;
    try {
      return jsonDecode(rawData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> addCompletedPuzzles(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_completedKey) ?? [];
    raw.add(jsonEncode(ProgressStore(word, DateTime.now().millisecondsSinceEpoch).toJson()));
    await prefs.setStringList(_completedKey, raw);
  }

  static Future<List<ProgressStore>> loadCompletedPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_completedKey) ?? [];
    return raw.map((s) => ProgressStore.fromJson(jsonDecode(s))).toList();
  }
}