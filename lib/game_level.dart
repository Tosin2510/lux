import 'dart:ui';

// one puzzle piece. currentPosition starts scattered somewhere in the dark
// and moves toward correctPosition as you drag it around. once placed it
// glows on its own - solving the puzzle IS bringing the light back
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
  final String label; // not really used now that pieces just form letters, keeping it in case icons come back later
  final Offset correctPosition;
  Offset currentPosition;
  final Size size;
  final int letterIndex; // which letter of the word this piece belongs to

  // 0 = straight edge, 1 = bump out, -1 = notch in
  final int topEdge;
  final int rightEdge;
  final int bottomEdge;
  final int leftEdge;

  bool get isPlaced => (currentPosition - correctPosition).distance < 4;
}

class GameLevel {
  GameLevel({
    required this.levelName,
    required this.word,
    required this.parts,
    required this.spotlightRadius,
  });

  final String levelName;
  final String word; // the actual word being spelled, e.g. "COOK"
  final List<PuzzleParts> parts;
  final double spotlightRadius;
}

class ScoreResult {
  final double score;
  final bool isWin;

  ScoreResult({required this.score, required this.isWin});
}

// win condition is just "did every piece make it home"
ScoreResult score(List<PuzzleParts> parts) {
  final placedCount = parts.where((p) => p.isPlaced).length;
  final val = parts.isEmpty ? 0.0 : placedCount / parts.length;
  return ScoreResult(score: val, isWin: placedCount == parts.length);
}

// builds the "C _ _ K" style display - a letter only shows once every
// piece belonging to it has landed in place
String wordProgress(GameLevel level) {
  final buffer = StringBuffer();
  for (int i = 0; i < level.word.length; i++) {
    final letterParts = level.parts.where((p) => p.letterIndex == i);
    final solved = letterParts.isNotEmpty && letterParts.every((p) => p.isPlaced);
    buffer.write(solved ? level.word[i].toUpperCase() : '_');
    if (i != level.word.length - 1) buffer.write('  ');
  }
  return buffer.toString();
}