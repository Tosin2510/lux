### Lux

Built this for PIXL's Blackout. the whole idea was "build something where light or darkness actually matters, not just a dark mode reskin" so here's my attempt at that.

## What it actually is?

Everything is basically pitch black. You drag your finger around the screen and it lights up a little circle wherever you're touching, that's the only way you can see anything. puzzle pieces are scattered around in the dark, hidden until your light finds them, and you have to drag them into their spot to spell out a letter (or a couple letters depending on the mode you pick). Once a piece is placed it stays lit permanently, so you can watch the letter slowly come together as you go.

Remove the light mechanic and there's literally no game left, you cannotnsee a single piece, nothing. that was basically my whole design constraint the entire time, everything else got built around making sure that stayed true.

## Game Modes
Monad - 1 letter, quick round
Dyad - 2 letters
Triad - 3 letters, this one's genuinely hard, pieces get small

pick whatever mode from the home screen. There's also a hint button (the lightbulb up at the top) if you're stuck, it'll flash one unplaced piece for a second so you at least know where it is though it doesn't solve it for you. You get a limited number per round and earn one back every time you finish a puzzle.

If you back out mid-puzzle it saves where you left off, so "continue" on the home screen picks up exactly where you quit (piece positions and all, not just progress numbers). There's also a little screen to see every letter/word you've solved so far, grouped by the length of words/letters.

## How each pieces get their shape?

Each piece is a rectangle that gets a bump or a notch cut into whichever edges touch a neighboring piece, neighboring pieces get matched values.

## Running it

flutter pub get
flutter run

No external packages beyond what's already in pubspec.yaml, the shadow/jigsaw shapes and everything are just raw dart:ui path math, no external library.

## why "Lux"

it's the actual unit of illuminance (lux, as in lumens per square meter) so it felt more honest than just calling it something generic. also just sounds good said out loud.

## The Limitation

It only works on android devices for now.