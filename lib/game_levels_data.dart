import 'dart:math';
import 'dart:ui';

import 'package:lux/game_level.dart';

// full alphabet now instead of just a few letters 
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
  static const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

// Store lists of 2, 3 and 4 letter words.
  static const Map<int, List<String>> wordBank = {
    2: ['GO', 'UP', 'ME', 'NO', 'SO', 'HI', 'BE', 'WE', 'IT', 'ON', 'AT', 'IN', 'BY', 'MY', 'TO', 'DO', 'AN', 'AS', 'IF', 'OR', 'IS', 'OF', 'US', 'HE', 'AM', 'OH', 'OK', 'PI', 'EX', 'AX', 'OX', 'ED', 'AD', 'AW', 'YE', 'MA', 'PA', 'LA', 'RE', 'AL', 'EL'],
    3: ['CAT', 'DOG', 'SUN', 'MAP', 'BOX', 'FUN', 'JAM', 'ZIP', 'KEY', 'OWL', 'PEN', 'CAR', 'HAT', 'BEE', 'ANT', 'BAT', 'CUP', 'RAT', 'PIG', 'FOX', 'HEN', 'COW', 'BUG', 'SKY', 'SEA', 'ICE', 'OIL', 'EYE', 'EAR', 'LEG', 'ARM', 'TOY', 'GUN', 'BAG', 'NET', 'LOG', 'TAP', 'VAN', 'WAX', 'YAK'],
    4: ['LAMP', 'MOON', 'JUMP', 'GAME', 'FISH', 'WAVE', 'QUIZ', 'DARK', 'GLOW', 'LUCK', 'TREE', 'STAR', 'BIRD', 'FIRE', 'SNOW', 'RAIN', 'WIND', 'ROCK', 'SAND', 'CAVE', 'FROG', 'BEAR', 'LION', 'WOLF', 'DEER', 'DUCK', 'GOAT', 'SWAN', 'CRAB', 'SEAL', 'THEN', 'MULE', 'HARE', 'MOTH', 'TOAD', 'FOWL', 'PUMA'],
  };

// A list that contains a single Game level, which is a word picked at random.
  static List<GameLevel> build(Size canvasSize, {int letterCount = 1}) {
    return [pickRandomLevel(canvasSize, letterCount)];
  }

  // avoiding the last word so we don't get the same one twice in a row
  static GameLevel pickRandomLevel(Size canvasSize, int letterCount, {String? wordToAvoid}) {
    final rand = Random();
    String word;

    if (letterCount == 1) {
      do {
        word = alphabet[rand.nextInt(alphabet.length)];
      } while (word == wordToAvoid);
    } else {
      final bank = wordBank[letterCount]!;
      do {
        word = bank[rand.nextInt(bank.length)];
      } while (word == wordToAvoid && bank.length > 1);
    }

    return buildWordLevel(canvasSize, word, spotlightRadius: 60);
  }

  static GameLevel buildWordLevel(Size canvasSize, String word, {required double spotlightRadius}) {
    const cols = 4;
    const rows = 5;
    const gapCells = 0.5; // space between letters, in cells
    final val = word.length;

// shrinking the cells so the whole word fits across the screen regardless of the word length.
final maxiCell = min(canvasSize.width * 0.16, canvasSize.height * 0.1);    final fitCell = (canvasSize.width - 32) / (val * cols + (val - 1) * gapCells);
    final cellSize = min(maxiCell, fitCell);
    final pad = cellSize > 40 ? 6.0 : 3.0; // tiny cells need a tiny gap

    final totalWidth = (val * cols + (val - 1) * gapCells) * cellSize;
    final startAtX = (canvasSize.width - totalWidth) / 2;
    const topFractionAtY = 0.14;

// Calculates the random position of each piece
// Aalso creates an object for each piece,
    final rand = Random(word.hashCode); // bumps stay the same for a given word
    final scatterRand = Random(); // scatter should be different every time though
    final parts = <PuzzleParts>[];

// Basically loops through every letter in the word as well as every grid.
    for (int a = 0; a < val; a++) {
      final pattern = letterPatterns[word[a]]!;
      final letterX = startAtX + a * (cols + gapCells) * cellSize;

      bool filled(int rw, int col) {
        if (rw < 0 || rw >= rows || col < 0 || col >= cols) return false;
        return pattern[rw][col] == '#';
      }

      final verticalEdges = List.generate(rows, (_) => List.generate(cols - 1, (_) => rand.nextBool() ? 1 : -1));
      final horizEdges = List.generate(rows - 1, (_) => List.generate(cols, (_) => rand.nextBool() ? 1 : -1));

      for (int rw = 0; rw < rows; rw++) {
        for (int col = 0; col < cols; col++) {
          if (!filled(rw, col)) continue;

          final correctPosition = Offset(
            letterX + col * cellSize,
            canvasSize.height * topFractionAtY + rw * cellSize,
          );

          final scatterX = 20 + scatterRand.nextDouble() * (canvasSize.width - 60 - cellSize);
          final scatterY = canvasSize.height * 0.42 + scatterRand.nextDouble() * (canvasSize.height * 0.48 - cellSize);

// adds the piece to the list of pieces.
          parts.add(PuzzleParts(
            id: '${word}_${a}_${rw}_$col',
            color: Color.lerp(const Color(0xFF8C6A2E), const Color(0xFFE8C46A), rand.nextDouble())!,
            label: '',
            correctPosition: correctPosition,
            currentPosition: Offset(scatterX, scatterY),
            size: Size(cellSize - pad, cellSize - pad),
            letterIndex: a ,
            topEdge: filled(rw - 1, col) ? -horizEdges[rw - 1][col] : 0,
            bottomEdge: filled(rw + 1, col) ? horizEdges[rw][col] : 0,
            leftEdge: filled(rw, col - 1) ? -verticalEdges[rw][col - 1] : 0,
            rightEdge: filled(rw, col + 1) ? verticalEdges[rw][col] : 0,
          ));
        }
      }
    }

    return GameLevel(
      levelName: 'Form the word',
      letter: word, // its a word now or a single letter.
      spotlightRadius: spotlightRadius,
      parts: parts,
    );
  }
}