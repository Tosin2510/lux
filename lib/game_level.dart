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
  final int letterIndex; // always 0 now - only one letter per level, this is leftover plumbing from when it was a whole word

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
    required this.letter,
    required this.parts,
    required this.spotlightRadius,
  });

  final String levelName;
  final String letter; // the single letter you're forming right now, e.g. "Q" - NOT a word, just one letter at a time
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

// shows the letter once every piece has landed in place, blank otherwise -
// shows each letter of the word once ALL of its pieces are placed,
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