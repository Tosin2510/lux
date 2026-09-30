import 'dart:ui';

class PuzzleParts {
  PuzzleParts({
    required this.id,
    required this.color,
    required this.label,
    required this.correctPosition,
    required this.currentPosition,
    required this.size,
    required this.letterIndex,
    this.topEdge = 0,
    this.rightEdge = 0,
    this.bottomEdge = 0,
    this.leftEdge = 0,
  });

  final String id;
  final Color color;
  final String label; 
  final Offset correctPosition;
  Offset currentPosition;
  final Size size;
  final int letterIndex;

  final int topEdge;
  final int rightEdge;
  final int bottomEdge;
  final int leftEdge;

// This boolean checks if the piece is close enough to the correct position.
  bool get isPlaced => (currentPosition - correctPosition).distance < 4;
}

class GameLevel {
  GameLevel({
    required this.levelName,
    required this.letter,
    required this.parts,
    required this.spotlightRadius,
  });

  final String levelName;
  final String letter; // the single letter beung formed right now, not a word yet, just one letter at a time
  final List<PuzzleParts> parts;
  final double spotlightRadius;
}

class ScoreResult {
  final double score;
  final bool isWin;

  ScoreResult({required this.score, required this.isWin});
}

ScoreResult score(List<PuzzleParts> parts) {
  final placedCount = parts.where((p) => p.isPlaced).length;
  final val = parts.isEmpty ? 0.0 : placedCount / parts.length;
  return ScoreResult(score: val, isWin: placedCount == parts.length);
}

// shows each letter of the word once every pieces are placed,
// otherwise, an underscore is displayed.
String letterDisplay(GameLevel level) {
  final word = level.letter;
  final value = <String>[];
  for (int i = 0; i < word.length; i++) {
    final mine = level.parts.where((p) => p.letterIndex == i);
    final done = mine.isNotEmpty && mine.every((p) => p.isPlaced);
    value.add(done ? word[i] : '_');
  }
  return value.join(' ');
}