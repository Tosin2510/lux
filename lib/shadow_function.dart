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
}