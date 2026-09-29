import 'dart:math';

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
  int progress = 0; // resets every 5 - this is what the progress bar tracks
  bool endSession = false;
  bool showTutorial = true; // shows once when the screen opens so people actually know what to do

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

  // just a few random lines so it's not the same popup every time lol
  final winTitles = ['omgg yes', 'LETS GOOO', 'yesss', 'okay that was clean', 'nice one', 'yoo nice'];
  final winSubs = ['next one lets go', 'ok next', 'easy', 'onto the next letter', 'lets keep going', 'again'];

  void showDialogUponWin() {
    lettersSolved++;
    progress++;

    if (progress  >= 5) {
      showMilestoneReached();
      return;
    }

    final pick = Random().nextInt(winTitles.length);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE8C46A), width: 1),
        ),
        title: Text(
          winTitles[pick],
          style: const TextStyle(color: Color(0xFFE8C46A), fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${winSubs[pick]} - "${currentLevel!.letter}" done, $lettersSolved so far',
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE8C46A)),
            onPressed: () {
              Navigator.pop(context);
              nextPartOfGame();
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  // every 5 solves you get this instead of the normal popup - a little
  // checkpoint so it's not just an endless grind with no structure
  void showMilestoneReached() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE8C46A), width: 1),
        ),
        title: const Text('good job', style: TextStyle(color: Color(0xFFE8C46A), fontSize: 24, fontWeight: FontWeight.bold)),
        content: Text('5 letters done, $lettersSolved total. keep playing?', style: const TextStyle(color: Colors.white70, fontSize: 15)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white54),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                progress = 0;
                endSession  = true;
              });
            },
            child: const Text("i'm done"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE8C46A)),
            onPressed: () {
              Navigator.pop(context);
              setState(() => progress = 0);
              nextPartOfGame();
            },
            child: const Text('keep playing'),
          ),
        ],
      ),
    );
  }

  // picks a new random letter and resets the board - shared by the normal
  // Next button and the "keep playing" milestone button
  void nextPartOfGame() {
    setState(() {
      levels = [GameLevelsData.pickRandomLetterLevel(lastCanvasSize!, avoid: currentLevel!.letter)];
      gameLevelIndex = 0;
      didWin = false;
      matchScore = 0;
      spotLightPosition = null;
    });
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
            final gameContent = Column(
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: buildProgressBar(),
                ),
                const SizedBox(height: 12),
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

            // stack the tutorial on top so it's the first thing you see -
            // once dismissed it stays gone for the rest of this session
            return Stack(
              children: [
                gameContent,
                if (showTutorial) buildTutorial(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildProgressBar() {
    final progressBar = (progress / 5).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          border: Border.all(color: const Color(0xFFE8C46A).withValues(alpha: 0.25), width: 1),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progressBar),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              builder: (context, value, child) => FractionallySizedBox(
                widthFactor: value,
                alignment: Alignment.centerLeft,
                child: child,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF8C6A2E), Color(0xFFE8C46A)]),
                ),
              ),
            ),
            // little glossy strip near the top so it doesn't look flat
            Positioned(
              top: 2,
              left: 6,
              right: 6,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Center(
              child: Text(
                '$progress/5',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTutorial() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.88),
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'everything is dark right now',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              const Text(
                'touch and drag around the screen to light things up. pieces are hidden in the dark - find one, drag it into its glowing outline to lock it in. do that for every piece and the letter is done.',
                style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0B0B12),
                  backgroundColor: const Color(0xFFE8C46A),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => setState(() => showTutorial = false),
                child: const Text('got it', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}