import 'dart:ui';

import 'package:lux/game_level.dart';

class GameLevelsData {
  static List<GameLevel> build(Size canvasSize) {
      // This should be responsive to diff screen sizes.
    Offset val(double xVal, double yVal) => Offset(xVal * canvasSize.width, yVal * canvasSize.height);
    
    List<PuzzleParts> buildGameGrid({
      required int rows,
      required int columns,
      required Offset topLeftPartOfGrid,
      required double sizeOfEachPiece,
      required List<Offset> scatterSpots,
      required List<Color> colors,
    }) {
      final pieces = <PuzzleParts>[];
      int index = 0;
      for (int rw = 0; rw < rows; rw++) {
        for (int col = 0; col < columns; col++) {
          final correctPosition = topLeftPartOfGrid + Offset(col * sizeOfEachPiece, rw * sizeOfEachPiece);
          pieces.add(PuzzleParts(
            id: 'p$index',
            color: colors[index % colors.length],
            label: String.fromCharCode(65 + index), // A, B, C...
            correctPosition: correctPosition,
            currentPosition: scatterSpots[index],
            size: Size(sizeOfEachPiece - 4, sizeOfEachPiece - 4), // tiny gap so pieces read as separate, not glued together
          ));
          index++;
        }
      }
      return pieces;
    }

  final gameColors = [
      const Color(0xFFE8C46A),
      const Color(0xFF6AA9E8),
      const Color(0xFFE86A6A),
      const Color(0xFF6AE89B),
      const Color(0xFFCB8CE8),
      const Color(0xFFE8A46A),
    ];
 
    return [
      GameLevel(
        levelName: 'First Spark',
        lightRadius: 70,
        parts: buildGameGrid(
          rows: 2,
          columns: 2,
          topLeftPartOfGrid: val(0.30, 0.55),
          sizeOfEachPiece: canvasSize.width * 0.2,
          scatterSpots: [
            val(0.15, 0.15),
            val(0.65, 0.12),
            val(0.10, 0.75),
            val(0.70, 0.80),
          ],
          colors: gameColors,
        ),
      ),
 
      GameLevel(
        levelName: 'Six Pieces',
        lightRadius: 60,
        parts: buildGameGrid(
          rows: 2,
          columns: 3,
          topLeftPartOfGrid: val(0.18, 0.55),
          sizeOfEachPiece: canvasSize.width * 0.16,
          scatterSpots: [
            val(0.10, 0.10),
            val(0.45, 0.08),
            val(0.80, 0.12),
            val(0.10, 0.85),
            val(0.45, 0.90),
            val(0.85, 0.85),
          ],
          colors: gameColors,
        ),
      ),
    ];
  }
}