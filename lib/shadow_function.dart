import 'dart:math';
import 'dart:ui';

// Basically defines the shape that can actually block light.
class LightBlocker {
  LightBlocker({required this.stringId, required this.vertices});

  final String stringId; // Added this so i can differentiate between the blockers if the need arises.
  List<Offset> vertices; // For the cornerpoints basically.

// This function basically adds all the corners x and y values....
// Then, it divides by the total number of corners thereis...
  Offset get centerVal {
    double xval = 0, yval = 0;
    for (final ver in vertices) {
      xval += ver.dx;
      yval += ver.dy;
    }
    return Offset(xval / vertices.length, yval / vertices.length);
  }

// Hmm...i added this so taht when the user drags the blocker, it moves by a specific amount
// But, the form should not change.
  void moveBy(Offset delta) {
    vertices = vertices.map((val) => val + delta).toList();
  }

// This function basically shows how a shadow works...
  Path shadowCalculation({
    required Offset lightLocation,
    required Rect rectBox,
  }) {
    final vertice = vertices;
    if (vertice.length < 3) return Path();

// angles calculates the direction or angle of each corner
// i.e Angle from the light source to that particular corner...
    final angles = vertice
        .map((v) => atan2(v.dy - lightLocation.dy, v.dx - lightLocation.dx))
        .toList();

// This part actually finds the important corners
// What i meant by important corners is the place where the biggest angle jump happens.
    int leftIndexval = 0, rightIndexval = 0;
    double maximumGap = -1;
    for (int i = 0; i < vertice.length; i++) {
      final j = (i + 1) % vertice.length;
      double gap = (angles[j] - angles[i]) % (2 * pi);
      if (gap < 0) gap += 2 * pi;
      if (gap > maximumGap) {
        maximumGap = gap;
        leftIndexval = j;
        rightIndexval = i;
      }
    }

    final darkOutlineA = vertice[rightIndexval];
    final darkOutlineB = vertice[leftIndexval];

// 
    final farDist =
        max(rectBox.width, rectBox.height) * 2 + (rectBox.center - lightLocation).distance;
    Offset pushOut(Offset v) {
      final dir = v - lightLocation;
      final len = dir.distance;
      if (len == 0) return v;
      return lightLocation + (dir / len) * farDist;
    }

    final farA = pushOut(darkOutlineA);
    final farB = pushOut(darkOutlineB);

  // Connecting the dots to draw the shadow shape.
    final path = Path()..moveTo(darkOutlineA.dx, darkOutlineA.dy);
    int i = rightIndexval;
    while (i != leftIndexval) {
      final next = (i + 1) % vertice.length;
      path.lineTo(vertice[next].dx, vertice[next].dy);
      i = next;
    }
    path.lineTo(farB.dx, farB.dy);
    path.lineTo(farA.dx, farA.dy);
    path.close();

    return path;
  }
}

// I added this so that the shadow can be combined into one shape
// The reason for this is because, what we care about at the end of the day is the total shape of the shadow.
Path totalCombinedShadowArea({
  required Offset lightLocation,
  required List<LightBlocker> blockers,
  required Rect rectBox,
}) {
  Path combinedShadow = Path();
  for (final blocker in blockers) {
    final shadow = blocker.shadowCalculation(
      lightLocation: lightLocation,
      rectBox: rectBox,
    );
    combinedShadow = Path.combine(PathOperation.union, combinedShadow, shadow);
  }
  return combinedShadow;
}