import 'package:flutter/material.dart';
import 'package:lux/game_level.dart';
import 'package:lux/game_levels_data.dart';
import 'package:lux/shadow_function.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<GameLevel>? gamelevels;
  int gameLevelIndex = 0;
  double matchScore = 0.0;
  bool didWin = false;
  LightBlocker? dragger; // Basically holds the shape(blocker) the user is dragging.

// The dialog that shows when the user wins.
  void showDialogUponWin() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        title: const Text('Yaaayyyy....match found', style: TextStyle(color: Colors.white)),
        content: Text('${currentLevel!.levelName} solved.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                gameLevelIndex = (gameLevelIndex + 1) % levels!.length;
                didWin = false;
                matchScore = 0;
              });
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

// 
  void scoreNote(Size size) {
    final rectBox = Offset.zero & size;
    // Calculates the shadow shape on the screen based on the rectangular blockers, light and all...
    final shadow = totalCombinedShadowArea(
      lightLocation: currentLevel!.lightLocation,
      blockers: currentLevel!.blockers,
      rectBox: rectBox,
    );
    final result = scoreCalcOfShadowAgainstTarget(
      shadowPath: shadow,
      targetPath: currentLevel!.expectedShape,
      targetBounds: rectBox,
    );
    matchScore = result.score;
 
 // If the user wins and it hasn't been shown, the popup is shown.
    if (result.isWin && !didWin) {
      didWin = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => showDialogUponWin());
    } else if (!result.isWin) {
      didWin = false;
    }
  }

// This gives the current level based on the gameLevlIndex.
  GameLevel? get currentLevel => levels?[gameLevelIndex]; 

  // This initialize the game level
  // I added the null check so that the build doesn't keep on rebuilding and clear the user progress.
  void initializeGameLevels(Size size) {
    if (currentLevel == null) {
      levels = GameLevelsData.build(size);
    }
  }

  List<GameLevel>? levels = [];
  @override
  // The build.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, values) {
            final canvasSize = Size(values.maxWidth, values.maxHeight);
            initializeGameLevels(canvasSize);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${currentLevel?.levelName}  >>>  ${gameLevelIndex + 1}/${levels!.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${(matchScore * 100).clamp(0, 100).toStringAsFixed(0)}% matched',
                        style: TextStyle(
                          color: Color.lerp(Colors.white38, const Color(0xFFE8C46A), matchScore),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // To be done......
                /*Expanded(
                  child: GestureDetector(
                    onPanStart: onDragStart,
                    onPanUpdate: (d) => onDragUpdate(d, canvasSize),
                    onPanEnd: (_) => dragger = null,
                    child: CustomPaint(
                      size: Size(canvasSize.width, canvasSize.height - 64),
                      painter: // TBC,
                    ),
                  ),
                ),*/
              ],
            );
          },
        ),
      ),
    );
  }

// checks if the user has clicked on any blocker and drags it....
  void onDragStart(DragStartDetails d) {
    // check topmost blocker first in case they overlap
    for (final b in currentLevel!.blockers.reversed) {
      final path = Path()..addPolygon(b.vertices, true);
      if (path.contains(d.localPosition)) {
        dragger = b;
        break;
      }
    }
  }

  void onDragUpdate(DragUpdateDetails d, Size size) {
    if (dragger == null) return;
    dragger!.moveBy(d.delta);
    scoreNote(size);
    setState(() {});
  }
}