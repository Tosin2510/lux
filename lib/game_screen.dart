import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lux/game_level.dart';
import 'package:lux/game_levels_data.dart';
import 'package:lux/paint_game.dart';
import 'package:lux/progress_store.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.letterCount = 1, this.savedGameSession});

  final int letterCount;
  final Map<String, dynamic>? savedGameSession; // if this isn't null we're continuing an old game

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin { // For the hint animation.
  static const maxHints = 5; //Maximum number of hints.
  static const topAreaHeight = 86.0;

  List<GameLevel>? levels;
  int gameLevelIndex = 0;
  bool didWin = false;
  Offset? spotLightPosition;
  PuzzleParts? dragger;
  Offset dragOffset = Offset.zero;
  Size? lastCanvasSize;
  int lettersSolved = 0;
  int batchProgress = 0;
  bool tutorial = true;

// This part handles the hint basically.
  late AnimationController hintController;
  PuzzleParts? hintPiece;
  int hintsLeft = 3;
  bool hintBusy = false;
  int hintRun = 0; // bumps every time a hint starts/cancels so old ones stop themselves

  GameLevel? get currentLevel => levels?[gameLevelIndex];

// Initialize the hint controller.
  @override
  void initState() {
    super.initState();
    hintController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))
      ..addListener(() => setState(() {}));

    final saved = widget.savedGameSession;
    if (saved != null) {
      lettersSolved = saved['lettersSolved'] ?? 0;
      batchProgress = saved['batchProgress'] ?? 0;
      hintsLeft = saved['hintsLeft'] ?? 3;
      tutorial = false; // they've played before, no need
    }
  }

// Dispose of the hint animation controller.
  @override
  void dispose() {
    hintController.dispose();
    super.dispose();
  }

// Build levels once the screen size is known
  void initializeGameLevels(Size size) {
    lastCanvasSize = size;
    if (currentLevel != null) return;

    final saved = widget.savedGameSession;
    if (saved != null) {
      final level = GameLevelsData.buildWordLevel(size, saved['word'] as String, spotlightRadius: 60);
      final pos = saved['positions'] as Map<String, dynamic>;
      for (final val in level.parts) {
        final vals = pos[val.id];
        if (vals == null) continue;
        val.currentPosition = Offset(
          (vals[0] as num).toDouble() * size.width,
          (vals[1] as num).toDouble() * size.height,
        );
      }
      levels = [level];
    } else {
      levels = GameLevelsData.build(size, letterCount: widget.letterCount);
    }
  }

  // positions are saved as fractions of the canvas so it still works regardless of screen size.
  void saveSession() {
    if (didWin || currentLevel == null || lastCanvasSize == null) return;
    final size = lastCanvasSize!;
    final positions = <String, List<double>>{};
    for (final val in currentLevel!.parts) {
      positions[val.id] = [val.currentPosition.dx / size.width, val.currentPosition.dy / size.height];
    }
    // Save the current game session to local storage.
    Progress.saveSession({
      'count': widget.letterCount,
      'word': currentLevel!.letter,
      'lettersSolved': lettersSolved,
      'batchProgress': batchProgress,
      'hintsLeft': hintsLeft,
      'positions': positions,
    });
  }

// Calculate score and check if the user won the game.
  void takeScore() {
    final result = score(currentLevel!.parts);

    if (result.isWin && !didWin) {
      didWin = true;
      HapticFeedback.mediumImpact();
      WidgetsBinding.instance.addPostFrameCallback((_) => showDialogUponWin());
    } else if (!result.isWin) {
      didWin = false;
    }
  }

  final winTitles = ['omgg yes', 'LETS GOOO', 'yesss', 'okay that was clean', 'nice one', 'yoo nice'];
  final winSubs = ['next one lets go', 'ok next', 'easy', 'onto the next one', 'lets keep going', 'again'];

// Displays a dialog when the user wins.
  void showDialogUponWin() {
    lettersSolved++;
    batchProgress++;

    // Update the progress and clear the session when the user wins.
    Progress.addCompletedPuzzles(currentLevel!.letter);
    Progress.clearSession();

    if (batchProgress >= 5) {
      showMilestoneReached();
      return;
    }

// Show a dialog with a random win title and subtitle when the user wins.
    final pick = Random().nextInt(winTitles.length);
    showDialog(
      context: context,
      barrierDismissible: false, // otherwise tapping outside leaves you on a solved board
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

// Displays a dialog when the user reaches a milestone.
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
        title: const Text('good job',
            style: TextStyle(color: Color(0xFFE8C46A), fontSize: 24, fontWeight: FontWeight.bold)),
        content: Text('5 done, $lettersSolved total. keep playing?',
            style: const TextStyle(color: Colors.white70, fontSize: 15)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white54),
            onPressed: () {
              Navigator.pop(context); // closes the dialog
              if (mounted) Navigator.pop(context); // back to home
            },
            child: const Text("i'm done"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE8C46A)),
            onPressed: () {
              Navigator.pop(context);
              setState(() => batchProgress = 0);
              nextPartOfGame();
            },
            child: const Text('keep playing'),
          ),
        ],
      ),
    );
  }

// Moves on to the nest part of the game, reset necessary variables and all...
  void nextPartOfGame() {
    hintRun++; // kills any hint that's still mid-animation
    hintController.value = 0;
    setState(() {
      levels = [
        GameLevelsData.pickRandomLevel(lastCanvasSize!, widget.letterCount, wordToAvoid: currentLevel!.letter)
      ];
      gameLevelIndex = 0;
      didWin = false;
      spotLightPosition = null;
      hintPiece = null;
      hintBusy = false;
      hintsLeft = min(hintsLeft + 1, maxHints); // fresh hints for the new puzzle
    });
    saveSession();
  }

  // pick a random piece that isn't home yet, glow it, then fade it back out
  Future<void> useHint() async {
    if (hintsLeft <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('no hints left. solve a puzzle to earn one')),
    );
    return;
  }
    if (hintBusy || hintsLeft <= 0 || didWin || currentLevel == null) return;
    final loose = currentLevel!.parts.where((p) => !p.isPlaced).toList();
    if (loose.isEmpty) return;

    final run = ++hintRun;
    hintBusy = true;
    hintsLeft--;
    hintPiece = loose[Random().nextInt(loose.length)];
    HapticFeedback.selectionClick();
    setState(() {});
    saveSession(); // save right away so quitting mid-hint doesn't give it back

    await hintController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted || run != hintRun) return;
    await hintController.reverse();
    if (!mounted || run != hintRun) return;

    setState(() {
      hintPiece = null;
      hintBusy = false;
    });
  }

  // Handles the start of a drag operation.

  void startDrag(DragStartDetails details) {
    spotLightPosition = details.localPosition;
    for (final piece in currentLevel!.parts.reversed) {
      final rectVal = piece.currentPosition & piece.size;
      if (rectVal.contains(details.localPosition) && !piece.isPlaced) {
        dragger = piece;
        dragOffset = details.localPosition - piece.currentPosition;
        break;
      }
    }
  }

// Handles the update of a drag operation.
  void updateDrag(DragUpdateDetails details) {
    spotLightPosition = details.localPosition;
    if (dragger != null) {
      dragger!.currentPosition = details.localPosition - dragOffset;
    }
    takeScore();
    setState(() {});
  }
// Handles the end of a drag operation.
  void endDrag(DragEndDetails details) {
    if (dragger != null) {
      // scales with piece size so 4-letter puzzles aren't too forgiving
      final snapRange = dragger!.size.width * 0.7;
      if ((dragger!.currentPosition - dragger!.correctPosition).distance < snapRange) {
        dragger!.currentPosition = dragger!.correctPosition;
        HapticFeedback.lightImpact();
        takeScore();
        setState(() {});
      }
      saveSession();
    }
    dragger = null;
  }

// The build.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, values) {
            // only the area under the header is the real play area
            final canvasSize = Size(values.maxWidth, values.maxHeight - topAreaHeight);
            initializeGameLevels(canvasSize);
            final gameContent = Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white54),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              'solved: $lettersSolved',
                              style: const TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: hintsLeft > 0 ? const Color(0xFFE8C46A) : Colors.white24,
                              ),
                              onPressed: useHint,
                              icon: const Icon(Icons.lightbulb_outline, size: 18),
                              label: Text('$hintsLeft', style: const TextStyle(fontSize: 13)),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              letterDisplay(currentLevel!),
                              style: const TextStyle(
                                color: Color(0xFFE8C46A),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: buildProgressBar(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GestureDetector(
                    onPanStart: startDrag,
                    onPanUpdate: updateDrag,
                    onPanEnd: endDrag,
                    onPanCancel: () => dragger = null, // OS interrupted the touch
                    child: CustomPaint(
                      size: canvasSize,
                      painter: PaintGame(
                        currentLevel: currentLevel!,
                        spotLightPosition: spotLightPosition,
                        isWin: didWin,
                        hintPiece: hintPiece,
                        hintGlow: hintController.value,
                      ),
                    ),
                  ),
                ),
              ],
            );

            return Stack(
              children: [
                gameContent,
                if (tutorial) buildTutorial(),
              ],
            );
          },
        ),
      ),
    );
  }

// Builds the progress bar widget.
  Widget buildProgressBar() {
    final progress = (batchProgress / 5).clamp(0.0, 1.0);
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
              tween: Tween(begin: 0, end: progress),
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
                '$batchProgress/5',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Build the overlay widget that shows the tutorial instructions.
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
                'touch and drag around the screen to light things up. pieces are hidden in the dark - find one, drag it into its glowing outline to lock it in. do that for every piece and the word is done. stuck? the bulb up top shows you a piece.',
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
                onPressed: () => setState(() => tutorial = false),
                child: const Text('got it', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}