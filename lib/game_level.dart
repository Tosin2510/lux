import 'dart:ui';

import 'package:lux/shadow_function.dart';

class GameLevel {
  GameLevel({
  required this.levelName,
  required this.lightLocation,
  required this.expectedShape,
  required this.blockers,
});
  final String levelName;
  Offset lightLocation;
  final Path expectedShape;
  final List<LightBlocker> blockers;
}

class GetResult {
  final double score;
  final bool didWin;

  GetResult({required this.score, required this.didWin});
} 

GetResult scoreCalcOfShadowAgainstTarget({
  required Path shadowPath,
  required Path targetPath,
  required Rect targetBounds,
  double winPercentageMatch = 0.92,
  int gridStep = 12,
}) {
  int totalPoints = 0;
  int matchedPoints = 0;

  for (double xVal = targetBounds.left; xVal < targetBounds.right; xVal += gridStep) {
    for (double yVal = targetBounds.top; yVal < targetBounds.bottom; yVal += gridStep) {
      final val = Offset(xVal, yVal);
      final valInTarget = targetPath.contains(val);
      final valInShadow = shadowPath.contains(val);
      if (valInShadow || valInTarget) {
        totalPoints++;
        if (valInShadow == valInTarget) {
          matchedPoints++;
        }
      }
    }
  }
  final score = totalPoints > 0 ? matchedPoints / totalPoints : 0.0;
  return GetResult(score: score, didWin: score >= winPercentageMatch);
}