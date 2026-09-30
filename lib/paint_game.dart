import 'package:flutter/material.dart';
import 'package:lux/game_level.dart';
import 'package:lux/shadow_function.dart';

class PaintGame extends CustomPainter {
  
  PaintGame({
    required this.currentLevel,
    required this.spotLightPosition,
    required this.isWin,
    this.hintPiece,
    this.hintGlow = 0,
  });

  final GameLevel currentLevel;
  final Offset? spotLightPosition;
  final bool isWin; 
  final PuzzleParts? hintPiece; 
  final double hintGlow;

  @override
  void paint(Canvas canvas, Size size) {
    // Basically draws a dark filled rectange that covers the canvas area.
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
      } else {
        canvas.drawRect(rectBox, Paint()..color = const Color(0xFF0B0B12));
      }

      if (hintPiece != null && hintGlow > 0) {
        drawHint(canvas, hintPiece!);
      }

      
      for (final piece in currentLevel.parts) {
        if (!piece.isPlaced) continue;
        final rect = piece.currentPosition & piece.size;
        final haloGlow = Paint();
          haloGlow.shader = RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.35), Colors.transparent],
          ).createShader(Rect.fromCircle(center: rect.center, radius: rect.longestSide));
        canvas.drawCircle(rect.center, rect.longestSide, haloGlow);
        drawPiece(canvas, piece);
      }
    }

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

  void drawHint(Canvas canvas, PuzzleParts piece) {
    final rect = piece.currentPosition & piece.size;
    final shape = buildPieceShape(
      rect,
      top: piece.topEdge,
      right: piece.rightEdge,
      bottom: piece.bottomEdge,
      left: piece.leftEdge,
    );

    final halo = Paint()
      ..color = piece.color.withValues(alpha: 0.9 * hintGlow)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 * hintGlow);
    canvas.drawPath(shape, halo);

    canvas.saveLayer(
      rect.inflate(rect.longestSide * 0.4),
      Paint()..color = Colors.white.withValues(alpha: hintGlow),
    );
    drawPiece(canvas, piece);
    canvas.restore();
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
    if (piece.label.isEmpty) return; 

    final textPainter = TextPainter(
      text: TextSpan(text: piece.label, style: const TextStyle(fontSize: 26)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, rect.center - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant PaintGame oldDelegate) => true;
}