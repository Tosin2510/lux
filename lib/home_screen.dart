import 'package:flutter/material.dart';
import 'package:lux/completed_puzzles_screen.dart';
import 'package:lux/game_screen.dart';
import 'package:lux/progress_store.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Holds the saved game sessions gotten from local storage.
  Map<String, dynamic>? savedGameSession;

@override
void initState() {
  super.initState();
  // immediately checks local storage for an active game session when the screen loads
  checkIfSavedGameSession();
}

// The navigator push leads to the game screen.
void goToGame(int count, {Map<String, dynamic>? saved}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(letterCount: count, savedGameSession: saved)),
    ).then((_) => checkIfSavedGameSession()); // refresh so continue shows up / goes away
  }
// I added this function to build the screen for the diff. modes of the game.
   Widget gameModeButton(int count, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor:  Color(0xFFE8C46A),
            side: const BorderSide(color: Color(0xFFE8C46A), width: 1),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => goToGame(count),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

// checks if an active game session exists basically and updates the state pf wodget.
Future<void> checkIfSavedGameSession() async {
  final val = await Progress.loadSession();
  // Guard condition for when the screen is no longe there.
  if (!mounted) return;
  setState(() {
    savedGameSession = val;
  });
}

// The build method.
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
              const Text('lux',
                  style: TextStyle(color: Color(0xFFE8C46A), fontSize: 44, fontWeight: FontWeight.bold, letterSpacing: 6)),
              const SizedBox(height: 6),
              const Text('find the pieces in the dark',
                  style: TextStyle(color: Colors.white38, fontSize: 13)),
              const SizedBox(height: 40),

              if (savedGameSession != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0B0B12),
                      backgroundColor: Color(0xFFE8C46A),
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
                // Thid is where the game buttons are dislayed.
                const SizedBox(height: 24),
                gameModeButton(1, 'Monad'),
                gameModeButton(2, 'Dyad'),
                gameModeButton(3, 'Triad'),
                const SizedBox(height: 12),
                // Leads tp the completed/ solved pzzle history screen
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white54),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompletedPuzzleScreen()),
                ),
                child: const Text('my solved puzzles'),
              ),
              ],
            ]
          )
        )
      ),
    );
  }
}