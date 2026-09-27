import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lux/game_level.dart';
import 'package:lux/game_levels_data.dart';
import 'package:lux/paint_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<GameLevel>? levels;
  int gameLevelIndex = 0;
  double matchScore = 0.0;
  bool didWin = false;
  Offset? spotLightPosition;
  PuzzleParts? dragger;
  Offset dragOffset = Offset.zero; // where inside the piece you grabbed it, so it doesn't snap to your finger
  Size? lastCanvasSize; // stashed so we can build a fresh letter after a win, outside of build()
  int lettersSolved = 0;

  GameLevel? get currentLevel => levels?[gameLevelIndex];

  void initializeGameLevels(Size size) {
    lastCanvasSize = size;
    if (currentLevel == null) {
      levels = GameLevelsData.build(size);
    }
  }

  void takeScore() {
    final result = score(currentLevel!.parts);
    matchScore = result.score;

    if (result.isWin && !didWin) {
      didWin = true;
      HapticFeedback.mediumImpact(); // a bigger buzz for the actual win, not just a piece snap
      WidgetsBinding.instance.addPostFrameCallback((_) => showDialogUponWin());
    } else if (!result.isWin) {
      didWin = false;
    }
  }

  void showDialogUponWin() {
    lettersSolved++;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        title: const Text('Yaaayyyy....you formed it', style: TextStyle(color: Colors.white)),
        content: Text('Letter "${currentLevel!.letter}" done. $lettersSolved so far.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                // roll a fresh random letter instead of cycling a fixed list -
                // this is what makes it keep going instead of stopping at one letter
                levels = [GameLevelsData.pickRandomLetterLevel(lastCanvasSize!, avoid: currentLevel!.letter)];
                gameLevelIndex = 0;
                didWin = false;
                matchScore = 0;
                spotLightPosition = null;
              });
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  // touching the screen is what turns the light on in the first place
  void startDrag(DragStartDetails details) {
    spotLightPosition = details.localPosition;
    // check topmost piece first in case any overlap
    for (final piece in currentLevel!.parts.reversed) {
      final rectVal = piece.currentPosition & piece.size;
      if (rectVal.contains(details.localPosition) && !piece.isPlaced) {
        dragger = piece;
        dragOffset = details.localPosition - piece.currentPosition;
        break;
      }
    }
  }

  void updateDrag(DragUpdateDetails details) {
    spotLightPosition = details.localPosition;
    if (dragger != null) {
      dragger!.currentPosition = details.localPosition - dragOffset;
    }
    takeScore();
    setState(() {});
  }

  void endDrag(DragEndDetails details) {
    // snap it home if it landed close enough
    if (dragger != null && (dragger!.currentPosition - dragger!.correctPosition).distance < 30) {
      dragger!.currentPosition = dragger!.correctPosition;
      HapticFeedback.lightImpact(); // little buzz so placing a piece actually feels like something
      takeScore();
      setState(() {});
    }
    dragger = null;
  }

  @override
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'solved: $lettersSolved',
                        style: const TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 0.5),
                      ),
                      Text(
                        letterDisplay(currentLevel!),
                        style: const TextStyle(
                          color: Color(0xFFE8C46A),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                // where all the actual game stuff happens
                Expanded(
                  child: GestureDetector(
                    onPanStart: startDrag,
                    onPanUpdate: updateDrag,
                    onPanEnd: endDrag,
                    child: CustomPaint(
                      size: Size(canvasSize.width, canvasSize.height - 64),
                      painter: PaintGame(
                        currentLevel: currentLevel!,
                        spotLightPosition: spotLightPosition,
                        isWin: didWin,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}