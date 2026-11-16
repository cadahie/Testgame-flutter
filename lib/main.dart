import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: SimpleTapGame()));
}

class SimpleTapGame extends FlameGame with TapCallbacks {
  int score = 0;

  @override
  Color backgroundColor() => const Color(0xFF141824);

  @override
  void onTapDown(TapDownEvent event) {
    score += 1;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Score: $score\nTap anywhere!',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }
}
