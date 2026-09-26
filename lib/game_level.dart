import 'dart:ui';

class GameLevel {
  GameLevel({
    required this.levelName,
    required this.parts,
    required this.lightRadius,
  });
 
  final String levelName;
  final List<PuzzleParts> parts;
  final double lightRadius;
}

class GetResult {
  final double score;
  final bool isWin;

  GetResult({required this.score, required this.isWin});
}

GetResult score(List<PuzzleParts> pieces) {
  final placedCount = pieces.where((val) => val.isPlaced).length;
  final score = pieces.isEmpty ? 0.0 : placedCount / pieces.length;
  return GetResult(score: score, isWin: placedCount == pieces.length);
}

class PuzzleParts {
  PuzzleParts({
    required this.id,
    required this.color,
    required this.label,
    required this.correctPosition,
    required this.currentPosition,
    required this.size,
  });
  final String id;
  final Color color;
  final String label; 
  final Offset correctPosition;
  Offset currentPosition;
  final Size size;
 
  bool get isPlaced => (currentPosition - correctPosition).distance < 4;
}

