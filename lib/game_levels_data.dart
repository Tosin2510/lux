import 'dart:ui';

import 'package:lux/game_level.dart';
import 'package:lux/shadow_function.dart';

class GameLevelsData {
  static List<GameLevel> build(Size canvasSize) {
    Offset val(double xVal, double yVal) => Offset(xVal * canvasSize.width, yVal * canvasSize.height);

    Path rectTargetPath(Offset topLeft, Offset size) {
      final path = Path();
      path.addRect(Rect.fromLTWH(topLeft.dx, topLeft.dy, size.dx, size.dy));
      return path;
    }

    // The blocker part is the part that actually blocks the light.

    LightBlocker blocker(String stringId, Offset centerVal, double width, double height) {
      return LightBlocker(
       stringId: stringId,
       vertices: [
          centerVal + Offset(-width / 2, -height / 2),
          centerVal + Offset(width / 2, -height / 2),
          centerVal + Offset(width / 2, height / 2),
          centerVal + Offset(-width / 2, height / 2),
        ],
      );
    }

     return [
      // Level 1: single block, single rectangular target — teaches the
      // core idea: drag the blocker so its projected shadow fills the box.
      GameLevel(
        levelName: 'Warm Up',
        lightLocation: val(0.5, 0.08),
        expectedShape: rectTargetPath(val(0.30, 0.65), val(0.40, 0.18)),
        blockers: [blocker('b1', val(0.5, 0.35), 60, 40)],
      ),
 
      // Level 2: two blockers, one wide target — player must position both
      // blockers so their shadows union covers the whole target.
      GameLevel(
        levelName: 'Double Trouble',
        lightLocation: val(0.5, 0.08),
        expectedShape: rectTargetPath(val(0.15, 0.68), val(0.70, 0.15)),
        blockers: [
          blocker('b1', val(0.35, 0.35), 50, 35),
          blocker('b2', val(0.65, 0.4), 50, 35),
        ],
      ),
 
      // Level 3: off-center light forces angled thinking, not just
      // directly-below dragging.
      GameLevel(
        levelName: 'Side Step',
        lightLocation: val(0.15, 0.1),
        expectedShape: rectTargetPath(val(0.45, 0.62), val(0.35, 0.2)),
        blockers: [blocker('b1', val(0.4, 0.32), 55, 45)],
      ),
    ];
  }
}