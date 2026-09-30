import 'dart:math';
import 'dart:ui';

bool isPointLitUp(Offset point, Offset lightLocation, double radius) {
  return (point - lightLocation).distance <= radius;
}

Path buildDarknessOverlay(Offset lightLocation, double radius, Rect bounds) {
  final path = Path();
    path.fillType = PathFillType.evenOdd;
    path.addRect(bounds);
    path.addOval(Rect.fromCircle(center: lightLocation, radius: radius));
  return path;
}

Path buildPieceShape(
  Rect rect, {
  required int top,
  required int right,
  required int bottom,
  required int left,
}) {
  final bumpPart = min(rect.width, rect.height) * 0.22;

  final topLeft = rect.topLeft;
  final topRight = rect.topRight;
  final bottomRight = rect.bottomRight;
  final bottomLeft = rect.bottomLeft;

// This draws each side in a clockwise pattern...
  void drawSide(Path path, Offset start, Offset end, int code, Offset outward) {
    if (code == 0) {
      path.lineTo(end.dx, end.dy);
      return;
    }
    final val = end - start;
    final p1 = start + val * 0.35;
    final p2 = start + val * 0.5;
    final p3 = start + val * 0.65;
    final push = outward * (bumpPart * code);

    path.lineTo(p1.dx, p1.dy);
    path.quadraticBezierTo(p1.dx + push.dx, p1.dy + push.dy, p2.dx + push.dx, p2.dy + push.dy);
    path.quadraticBezierTo(p3.dx + push.dx, p3.dy + push.dy, p3.dx, p3.dy);
    path.lineTo(end.dx, end.dy);
  }

  final path = Path()..moveTo(topLeft.dx, topLeft.dy);
  drawSide(path, topLeft, topRight, top, const Offset(0, -1));
  drawSide(path, topRight, bottomRight, right, const Offset(1, 0));
  drawSide(path, bottomRight, bottomLeft, bottom, const Offset(0, 1));
  drawSide(path, bottomLeft, topLeft, left, const Offset(-1, 0));
  path.close();

  return path;
}