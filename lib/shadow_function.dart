import 'dart:ui';

// This is basically sed to figure out what's actually visible right now...anything outside
// the light radius should stay hidden/unusable
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