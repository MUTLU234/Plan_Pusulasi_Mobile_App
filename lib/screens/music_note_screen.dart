import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

const int rowCount = 20;
const int columnCount = 20;
const double squareSize = 20.0;

enum Direction { up, down, left, right }

class StarTrailScreen extends StatefulWidget {
  const StarTrailScreen({Key? key}) : super(key: key);

  @override
  _StarTrailScreenState createState() => _StarTrailScreenState();
}

class _StarTrailScreenState extends State<StarTrailScreen> {
  List<Point<int>> trail = [];
  late Point<int> star;
  Direction direction = Direction.up;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Başlangıç konumu: ortada
    trail = [Point(rowCount ~/ 2, columnCount ~/ 2)];
    _spawnStar();
    timer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _updateGame(),
    );
  }

  void _spawnStar() {
    final rand = Random();
    do {
      star = Point(rand.nextInt(rowCount), rand.nextInt(columnCount));
    } while (trail.contains(star));
  }

  void _updateGame() {
    setState(() {
      final head = trail.first;
      Point<int> newHead;
      switch (direction) {
        case Direction.up:
          newHead = Point(head.x, head.y - 1);
          break;
        case Direction.down:
          newHead = Point(head.x, head.y + 1);
          break;
        case Direction.left:
          newHead = Point(head.x - 1, head.y);
          break;
        case Direction.right:
          newHead = Point(head.x + 1, head.y);
          break;
      }
      // Kenarlardan geçiş (wrap-around)
      if (newHead.x < 0) newHead = Point(rowCount - 1, newHead.y);
      if (newHead.x >= rowCount) newHead = Point(0, newHead.y);
      if (newHead.y < 0) newHead = Point(newHead.x, columnCount - 1);
      if (newHead.y >= columnCount) newHead = Point(newHead.x, 0);

      // Kendi üzerine çarpma → oyun biter
      if (trail.contains(newHead)) {
        timer?.cancel();
        _showGameOver();
        return;
      }
      trail.insert(0, newHead);

      // Yıldızı topladı mı?
      if (newHead == star) {
        _spawnStar();
      } else {
        trail.removeLast();
      }
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Oyun Bitti'),
            content: Text('Skorunuz: ${trail.length - 1}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                    ..pop() // dialog'u kapat
                    ..pop(); // oyun ekranından çık
                },
                child: const Text('Çıkış'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yıldız Toplama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: GestureDetector(
        // Swipe ile yön değiştirme
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < 0 && direction != Direction.down) {
            direction = Direction.up;
          } else if (details.delta.dy > 0 && direction != Direction.up) {
            direction = Direction.down;
          }
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx < 0 && direction != Direction.right) {
            direction = Direction.left;
          } else if (details.delta.dx > 0 && direction != Direction.left) {
            direction = Direction.right;
          }
        },
        child: Center(
          child: Container(
            width: rowCount * squareSize,
            height: columnCount * squareSize,
            color: Colors.black,
            child: CustomPaint(painter: _StarTrailPainter(trail, star)),
          ),
        ),
      ),
    );
  }
}

class _StarTrailPainter extends CustomPainter {
  final List<Point<int>> trail;
  final Point<int> star;

  _StarTrailPainter(this.trail, this.star);

  @override
  void paint(Canvas canvas, Size size) {
    final paintTrail = Paint()..color = Colors.lightBlue;
    final paintStar = Paint()..color = Colors.yellow;
    final cellSize = size.width / rowCount;

    // Kuyruğu çiz
    for (var p in trail) {
      final rect = Rect.fromLTWH(
        p.x * cellSize,
        p.y * cellSize,
        cellSize,
        cellSize,
      );
      canvas.drawRect(rect, paintTrail);
    }
    // Yıldızı çiz
    final starRect = Rect.fromLTWH(
      star.x * cellSize,
      star.y * cellSize,
      cellSize,
      cellSize,
    );
    canvas.drawOval(starRect, paintStar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
