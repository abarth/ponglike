import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Ball extends CircleComponent with CollisionCallbacks {
  static final _paint = Paint()..color = Colors.green.shade400;

  Vector2 velocity = Vector2.zero();

  Ball() : super(paint: _paint) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    velocity.negate();
  }
}

class Paddle extends RectangleComponent
    with CollisionCallbacks, KeyboardHandler {
  static final _paint = Paint()..color = Colors.orange.shade400;

  Vector2 velocity = Vector2.zero();

  Paddle() : super(paint: _paint) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    const kSpeed = 200.0;

    if (event is RawKeyDownEvent) {
      final logicalKey = event.logicalKey;
      if (logicalKey == LogicalKeyboardKey.arrowUp) {
        velocity.y = -kSpeed;
        return true;
      } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
        velocity.y = kSpeed;
        return true;
      }
    } else if (event is RawKeyUpEvent) {
      final logicalKey = event.logicalKey;
      if (logicalKey == LogicalKeyboardKey.arrowUp ||
          logicalKey == LogicalKeyboardKey.arrowDown) {
        velocity.y = 0.0;
        return true;
      }
    }
    return false;
  }
}

class ComputerPaddle extends RectangleComponent
    with CollisionCallbacks, HasGameRef<PongGame> {
  static final _paint = Paint()..color = Colors.orange.shade400;

  Vector2 velocity = Vector2.zero();

  ComputerPaddle() : super(paint: _paint) {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y = gameRef.ball.position.y;
  }
}

class PongGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late Ball ball;

  @override
  Future<void> onLoad() async {
    ball = Ball()
      ..velocity = Vector2(300.0, 200.0)
      ..position = size / 2
      ..width = 50
      ..height = 50
      ..anchor = Anchor.center;
    addAll([
      ScreenHitbox<PongGame>(),
      ball,
      Paddle()
        ..position = Vector2(size.x - 10, size.y / 2)
        ..width = 10
        ..height = size.y / 2.0
        ..anchor = Anchor.centerRight,
      ComputerPaddle()
        ..position = Vector2(10, size.y / 2)
        ..width = 10
        ..height = size.y / 2.0
        ..anchor = Anchor.centerLeft,
    ]);
  }
}

class PongView extends StatelessWidget {
  const PongView({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: PongGame());
  }
}
