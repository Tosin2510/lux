import 'dart:math';
import 'dart:ui';

import 'package:lux/game_level.dart';

// full alphabet now instead of just a few letters - 4 wide x 5 tall blocky
// font. a handful of these (M, N, W, X) are rough approximations since
// diagonals don't render cleanly at this resolution, but they're all
// readable enough. '#' = a piece goes here, '.' = empty
const Map<String, List<String>> letterPatterns = {
  'A': ['.##.', '#..#', '####', '#..#', '#..#'],
  'B': ['###.', '#..#', '###.', '#..#', '###.'],
  'C': ['.###', '#...', '#...', '#...', '.###'],
  'D': ['###.', '#..#', '#..#', '#..#', '###.'],
  'E': ['####', '#...', '###.', '#...', '####'],
  'F': ['####', '#...', '###.', '#...', '#...'],
  'G': ['.###', '#...', '#.##', '#..#', '.###'],
  'H': ['#..#', '#..#', '####', '#..#', '#..#'],
  'I': ['####', '.##.', '.##.', '.##.', '####'],
  'J': ['...#', '...#', '...#', '#..#', '.##.'],
  'K': ['#..#', '#.#.', '##..', '#.#.', '#..#'],
  'L': ['#...', '#...', '#...', '#...', '####'],
  'M': ['#..#', '####', '#..#', '#..#', '#..#'],
  'N': ['#..#', '##.#', '#.##', '#..#', '#..#'],
  'O': ['.##.', '#..#', '#..#', '#..#', '.##.'],
  'P': ['###.', '#..#', '###.', '#...', '#...'],
  'Q': ['.##.', '#..#', '#..#', '.##.', '...#'],
  'R': ['###.', '#..#', '###.', '#.#.', '#..#'],
  'S': ['.###', '#...', '.##.', '...#', '###.'],
  'T': ['####', '.##.', '.##.', '.##.', '.##.'],
  'U': ['#..#', '#..#', '#..#', '#..#', '.##.'],
  'V': ['#..#', '#..#', '#..#', '.##.', '.##.'],
  'W': ['#..#', '#..#', '#..#', '####', '#..#'],
  'X': ['#..#', '.##.', '.##.', '.##.', '#..#'],
  'Y': ['#..#', '#..#', '.##.', '.##.', '.##.'],
  'Z': ['####', '...#', '.##.', '#...', '####'],
};

class GameLevelsData {
  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  static List<GameLevel> build(Size canvasSize) {
    return [pickRandomLetterLevel(canvasSize)];
  }

  // grabs a random letter and builds a level for it. pass avoid so we
  // don't roll the exact same letter twice in a row when moving on
  static GameLevel pickRandomLetterLevel(Size canvasSize, {String? avoid}) {
    final rand = Random();
    String letter;
    do {
      letter = _alphabet[rand.nextInt(_alphabet.length)];
    } while (letter == avoid && _alphabet.length > 1);

    return buildLetterLevel(canvasSize, letter, spotlightRadius: 60);
  }

  static GameLevel buildLetterLevel(Size canvasSize, String letter, {required double spotlightRadius}) {
    final pattern = letterPatterns[letter]!;
    final rows = pattern.length;
    final cols = pattern[0].length;

    // bigger now since it's just one letter at a time, not a whole word
    // crammed across the screen
    final cellSize = canvasSize.width * 0.16;

    final gridWidth = cols * cellSize;
    final startX = (canvasSize.width - gridWidth) / 2;
    const topYFraction = 0.14;

    bool filled(int rw, int col) {
      if (rw < 0 || rw >= rows || col < 0 || col >= cols) return false;
      return pattern[rw][col] == '#';
    }

    final rand = Random(letter.codeUnitAt(0)); // seeded per letter so its bumps stay consistent within a play
    final vertEdges = List.generate(rows, (_) => List.generate(cols - 1, (_) => rand.nextBool() ? 1 : -1));
    final horizEdges = List.generate(rows - 1, (_) => List.generate(cols, (_) => rand.nextBool() ? 1 : -1));

    final parts = <PuzzleParts>[];
    for (int rw = 0; rw < rows; rw++) {
      for (int col = 0; col < cols; col++) {
        if (!filled(rw, col)) continue;

        final correctPosition = Offset(
          startX + col * cellSize,
          canvasSize.height * topYFraction + rw * cellSize,
        );

        final scatterX = 20 + rand.nextDouble() * (canvasSize.width - 60 - cellSize);
        final scatterY = canvasSize.height * 0.42 + rand.nextDouble() * (canvasSize.height * 0.48 - cellSize);

        parts.add(PuzzleParts(
          id: '${letter}_${rw}_$col',
          color: Color.lerp(const Color(0xFF8C6A2E), const Color(0xFFE8C46A), rand.nextDouble())!,
          label: '',
          correctPosition: correctPosition,
          currentPosition: Offset(scatterX, scatterY),
          size: Size(cellSize - 6, cellSize - 6), // slightly bigger gap now that pieces themselves are bigger
          letterIndex: 0,
          topEdge: filled(rw - 1, col) ? -horizEdges[rw - 1][col] : 0,
          bottomEdge: filled(rw + 1, col) ? horizEdges[rw][col] : 0,
          leftEdge: filled(rw, col - 1) ? -vertEdges[rw][col - 1] : 0,
          rightEdge: filled(rw, col + 1) ? vertEdges[rw][col] : 0,
        ));
      }
    }

    return GameLevel(
      levelName: 'Form the letter',
      letter: letter,
      spotlightRadius: spotlightRadius,
      parts: parts,
    );
  }
}