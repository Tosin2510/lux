import 'package:flutter/material.dart';
import 'package:lux/game_level.dart';
import 'package:lux/shadow_function.dart';

class PaintGame extends CustomPainter {
  PaintGame({
    required this.currentLevel,
    required this.spotLightPosition,
    required this.isWin,
  });

  final GameLevel currentLevel;
  final Offset? spotLightPosition;
  final bool isWin; // once true, we stop hiding anything - the whole board lights up

  @override
  void paint(Canvas canvas, Size size) {
    final rectBox = Offset.zero & size;

    canvas.drawRect(rectBox, Paint()..color = const Color(0xFF0B0B12));

    for (final piece in currentLevel.parts) {
      drawPiece(canvas, piece);
    }

    if (!isWin) {
      if (spotLightPosition != null) {
        final overlay = buildDarknessOverlay(spotLightPosition!, currentLevel.spotlightRadius, rectBox);
        canvas.drawPath(overlay, Paint()..color = const Color(0xFF0B0B12));

        final glow = Paint();
          glow.shader = RadialGradient(
            colors: [Colors.transparent, const Color(0xFF0B0B12)],
            stops: const [0.75, 1.0],
          ).createShader(Rect.fromCircle(center: spotLightPosition!, radius: currentLevel.spotlightRadius));
        canvas.drawCircle(spotLightPosition!, currentLevel.spotlightRadius, glow);
      }

      // placed pieces stay lit even outside the spotlight - watching each
      // letter slowly light up as you go is kind of the whole point
      for (final piece in currentLevel.parts) {
        if (!piece.isPlaced) continue;
        final rect = piece.currentPosition & piece.size;
        final haloGlow = Paint();
          haloGlow.shader = RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.35), Colors.transparent],
          ).createShader(Rect.fromCircle(center: rect.center, radius: rect.longestVal));
        canvas.drawCircle(rect.center, rect.longestVal, haloGlow);
        drawPiece(canvas, piece);
      }
    }
    // isWin == true -> nothing painted on top, the full board just stays visible

    // slot outlines drawn LAST, on top of everything - these stay visible
    // no matter what, so you always know the shape you're building even
    // while the actual pieces are still hidden in the dark
    final slotPaint = Paint();
      slotPaint.color = Colors.white.withValues(alpha: 0.28);
      slotPaint.style = PaintingStyle.stroke;
      slotPaint.strokeWidth = 1.5;
    for (final piece in currentLevel.parts) {
      final slotShape = buildPieceShape(
        piece.correctPosition & piece.size,
        top: piece.topEdge,
        right: piece.rightEdge,
        bottom: piece.bottomEdge,
        left: piece.leftEdge,
      );
      canvas.drawPath(slotShape, slotPaint);
    }
  }

  void drawPiece(Canvas canvas, PuzzleParts piece) {
    final rect = piece.currentPosition & piece.size;
    final shape = buildPieceShape(
      rect,
      top: piece.topEdge,
      right: piece.rightEdge,
      bottom: piece.bottomEdge,
      left: piece.leftEdge,
    );
    canvas.drawPath(shape, Paint()..color = piece.color);
      final paint = Paint();
        paint.color = Colors.black.withValues(alpha: 0.4);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;
        
    canvas.drawPath(shape, paint);
    if (piece.label.isEmpty) return; // plain jigsaw blocks now, no icon needed

    final textPainter = TextPainter(
      text: TextSpan(text: piece.label, style: const TextStyle(fontSize: 26)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, rect.center - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant PaintGame oldDelegate) => true;
}

extension on Rect {
  double get longestVal => width > height ? width : height;
}