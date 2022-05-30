import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameRef<PongGame> {
  static final _paint = Paint()..color = Colors.green.shade400;

  Vector2 velocity = Vector2.zero();

  Ball() : super(paint: _paint) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    final rect = toRect();
    if (rect.right > gameRef.size.x) {
      gameRef.score.scoreComputer();
      gameRef.nextPoint();
    } else if (rect.left < 0.0) {
      gameRef.score.scorePlayer();
      gameRef.nextPoint();
    } else if (rect.bottom > gameRef.size.y || rect.top < 0) {
      velocity.y = -velocity.y;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    velocity.x = -velocity.x;
  }
}

class Paddle extends RectangleComponent
    with HasGameRef<PongGame>, CollisionCallbacks {
  static final _paint = Paint()..color = Colors.orange.shade400;

  Vector2 velocity = Vector2.zero();

  Paddle() : super(paint: _paint) {
    add(RectangleHitbox());
  }

  void constraintToBoard() {
    final halfHeight = size.y / 2.0;
    position.y = position.y.clamp(halfHeight, gameRef.size.y - halfHeight);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    constraintToBoard();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), paint);
  }
}

class PlayerPaddle extends Paddle with KeyboardHandler {
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

class ComputerPaddle extends Paddle {
  @override
  void update(double dt) {
    super.update(dt);
    // position.y = gameRef.ball.position.y;
    constraintToBoard();
  }
}

class PongScore extends ChangeNotifier {
  int playerScore = 0;
  int computerScore = 0;

  void scorePlayer() {
    playerScore += 1;
    notifyListeners();
  }

  void scoreComputer() {
    computerScore += 1;
    notifyListeners();
  }
}

class PongGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final score = PongScore();
  final random = Random();
  late Ball ball;

  Vector2 initialBallVelocity() {
    final velocity = Vector2(0.0, 400.0)
      ..rotate(random.nextDouble() * pi * 0.5 + 0.25 * pi);
    if (random.nextBool()) {
      velocity.rotate(pi);
    }
    return velocity;
  }

  @override
  Future<void> onLoad() async {
    ball = Ball()
      ..velocity = initialBallVelocity()
      ..position = size / 2
      ..width = 50
      ..height = 50
      ..anchor = Anchor.center;
    addAll([
      ball,
      PlayerPaddle()
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

  void nextPoint() {
    ball
      ..velocity = initialBallVelocity()
      ..position = size / 2;
  }
}

class ScoreBoard extends AnimatedWidget {
  final PongScore score;

  const ScoreBoard({super.key, required this.score}) : super(listenable: score);

  @override
  Widget build(BuildContext context) {
    return Text(
      "Computer: ${score.computerScore}, Player: ${score.playerScore}",
    );
  }
}

class PongView extends StatefulWidget {
  const PongView({super.key});

  @override
  State<PongView> createState() => _PongViewState();
}

class _PongViewState extends State<PongView> {
  final game = PongGame();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScoreBoard(score: game.score),
        SizedBox(
          width: 400.0,
          height: 400.0,
          child: GameWidget(game: game),
        ),
      ],
    );
  }
}
