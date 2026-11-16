import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: DodgeGame()));
}

class DodgeGame extends FlameGame with PanDetector, TapCallbacks {
  final Random _rng = Random();
  late RectangleComponent player;
  final List<RectangleComponent> blocks = [];

  double spawnTimer = 0;
  double spawnInterval = 0.75;
  int score = 0;
  bool isGameOver = false;

  @override
  Color backgroundColor() => const Color(0xFF0E131F);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _setupWorld();
  }

  void _setupWorld() {
    removeAll(children);
    blocks.clear();
    score = 0;
    spawnTimer = 0;
    spawnInterval = 0.75;
    isGameOver = false;

    player = RectangleComponent(
      size: Vector2(54, 54),
      position: Vector2((size.x - 54) / 2, size.y - 120),
      paint: Paint()..color = const Color(0xFF38BDF8),
    );
    add(player);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver) return;
    player.position.x = (player.position.x + info.delta.global.x)
        .clamp(0.0, size.x - player.size.x);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) {
      _setupWorld();
      return;
    }
    if (event.localPosition.x < size.x / 2) {
      player.position.x = (player.position.x - 45).clamp(0.0, size.x - player.size.x);
    } else {
      player.position.x = (player.position.x + 45).clamp(0.0, size.x - player.size.x);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    spawnTimer += dt;
    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;
      final w = 36 + _rng.nextDouble() * 44;
      final x = _rng.nextDouble() * max(1.0, size.x - w);
      final block = RectangleComponent(
        size: Vector2(w, 28),
        position: Vector2(x, -30),
        paint: Paint()..color = const Color(0xFFF43F5E),
      );
      blocks.add(block);
      add(block);
    }

    final speed = 240.0 + score * 8.0;
    final toRemove = <RectangleComponent>[];

    for (final b in blocks) {
      b.position.y += speed * dt;

      if (b.toRect().overlaps(player.toRect())) {
        isGameOver = true;
      }

      if (b.position.y > size.y + 40) {
        toRemove.add(b);
        score += 1;
        spawnInterval = max(0.32, 0.75 - score * 0.01);
      }
    }

    for (final b in toRemove) {
      blocks.remove(b);
      b.removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final hud = TextPainter(
      text: TextSpan(
        text: isGameOver
            ? 'GAME OVER\nScore: $score\nTap to retry'
            : 'Score: $score',
        style: TextStyle(
          color: isGameOver ? const Color(0xFFFDE047) : Colors.white,
          fontSize: isGameOver ? 28 : 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    hud.paint(
      canvas,
      Offset(
        (size.x - hud.width) / 2,
        isGameOver ? (size.y - hud.height) / 2 : 48,
      ),
    );
  }
}
