import 'package:flutter/material.dart';
import 'package:lux/completed_puzzles_screen.dart';
import 'package:lux/game_screen.dart';
import 'package:lux/progress_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Holds the saved game session gotten from local storage.
  Map<String, dynamic>? savedGameSession;

  // slow pulse for the glow behind the title
  late AnimationController glowController;

  @override
  void initState() {
    super.initState();
    glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    // immediately checks local storage for an active game session when the screen loads
    checkIfSavedGameSession();
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  // The navigator push leads to the game screen.
  void goToGame(int count, {Map<String, dynamic>? saved}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(letterCount: count, savedGameSession: saved)),
    ).then((_) => checkIfSavedGameSession()); // refresh so continue shows up / goes away
  }

  // checks if an active game session exists and updates the state of the widget.
  Future<void> checkIfSavedGameSession() async {
    final val = await Progress.loadSession();
    // Guard condition for when the screen is no longer there.
    if (!mounted) return;
    setState(() {
      savedGameSession = val;
    });
  }

  // builds the button for each mode. sub is the small hint under the name
  Widget gameModeButton(int count, String label, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE8C46A),
            side: const BorderSide(color: Color(0xFFE8C46A), width: 1),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => goToGame(count),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 17, letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 11, color: Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }

  // the big title: glow behind + gold gradient letters on top
  Widget buildTitle() {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, _) {
        final pulse = glowController.value; // 0 to 1 and back
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 260 + 40 * pulse,
              height: 260 + 40 * pulse,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8C46A).withValues(alpha: 0.10 + 0.14 * pulse),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF1C9), Color(0xFFE8C46A), Color(0xFF8C6A2E)],
              ).createShader(bounds),
              child: const Text(
                'LUX',
                style: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 14,
                  color: Colors.white, // gets replaced by the gradient
                  height: 1,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTitle(),
              const SizedBox(height: 4),
              const Text(
                'find the pieces in the dark',
                style: TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 3),
              ),
              const SizedBox(height: 44),

              // only shows if there is a game to continue
              if (savedGameSession != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0B0B12),
                      backgroundColor: const Color(0xFFE8C46A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => goToGame(savedGameSession!['count'] as int, saved: savedGameSession),
                    child: Text(
                      'continue (${savedGameSession!['word']})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ], // <- the if block ends HERE, the buttons below are always shown

              // This is where the game buttons are displayed.
              gameModeButton(1, 'Monad', '1 letter'),
              gameModeButton(2, 'Dyad', '2 letters'),
              gameModeButton(3, 'Triad', '3 letters'),
              const SizedBox(height: 12),

              // Leads to the completed / solved puzzle history screen
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white54),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompletedPuzzleScreen()),
                ),
                child: const Text('my solved puzzles'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}