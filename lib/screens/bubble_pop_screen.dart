import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

class BubblePopScreen extends StatefulWidget {
  const BubblePopScreen({Key? key}) : super(key: key);

  @override
  _BubblePopScreenState createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends State<BubblePopScreen> {
  static const int rows = 10, cols = 6;
  static const Duration spawnInterval = Duration(milliseconds: 700);
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  late List<List<Color?>> grid;
  Timer? spawnTimer, countdownTimer;
  bool isPaused = false;
  bool showTutorial = true;
  Point<int>? tappedCell;
  int score = 0, timeLeft = 60;

  @override
  void initState() {
    super.initState();
    grid = List.generate(rows, (_) => List.filled(cols, null));
    // Show tutorial for 3 seconds
    Timer(const Duration(seconds: 3), () {
      setState(() => showTutorial = false);
    });
    _startTimers();
  }

  void _startTimers() {
    spawnTimer = Timer.periodic(spawnInterval, (_) => _spawnBubble());
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeLeft <= 0) {
        _endGame();
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void _pauseTimers() {
    spawnTimer?.cancel();
    countdownTimer?.cancel();
  }

  void _spawnBubble() {
    final col = Random().nextInt(cols);
    // Shift down only if there's at least one bubble
    if (grid.any((row) => row[col] != null)) {
      for (var r = 0; r < rows - 1; r++) {
        grid[r][col] = grid[r + 1][col];
      }
    }
    grid[rows - 1][col] = colors[Random().nextInt(colors.length)];
    setState(() {});
  }

  void _popAt(int r, int c) {
    final target = grid[r][c];
    if (target == null) return;

    // record tapped cell for feedback
    setState(() => tappedCell = Point(r, c));
    Timer(
      const Duration(milliseconds: 200),
      () => setState(() => tappedCell = null),
    );

    // gather positions to remove
    final toRemove = <Point<int>>[];

    // vertical
    int up = r, down = r;
    while (up - 1 >= 0 && grid[up - 1][c] == target) up--;
    while (down + 1 < rows && grid[down + 1][c] == target) down++;
    if (down - up + 1 >= 3) {
      for (var i = up; i <= down; i++) {
        toRemove.add(Point(i, c));
      }
    }

    // horizontal
    int left = c, right = c;
    while (left - 1 >= 0 && grid[r][left - 1] == target) left--;
    while (right + 1 < cols && grid[r][right + 1] == target) right++;
    if (right - left + 1 >= 3) {
      for (var j = left; j <= right; j++) {
        toRemove.add(Point(r, j));
      }
    }

    if (toRemove.isEmpty) return;

    // clear and compress each affected column
    final affectedCols = toRemove.map((p) => p.y).toSet();
    for (var p in toRemove) {
      grid[p.x][p.y] = null;
    }
    for (var c2 in affectedCols) {
      final column = <Color?>[];
      for (var i = 0; i < rows; i++) {
        if (grid[i][c2] != null) column.add(grid[i][c2]);
      }
      final empties = rows - column.length;
      for (var i = 0; i < empties; i++) grid[i][c2] = null;
      for (var i = 0; i < column.length; i++) {
        grid[empties + i][c2] = column[i];
      }
    }

    score += toRemove.length;
    setState(() {});
  }

  void _endGame() {
    _pauseTimers();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Oyun Bitti'),
            content: Text('Skorunuz: $score'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
                child: const Text('Çıkış'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _pauseTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final bg = theme.isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Balon Patlatma'),
        backgroundColor:
            theme.isDarkMode ? Colors.grey[900] : Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              setState(() {
                if (isPaused) {
                  _startTimers();
                } else {
                  _pauseTimers();
                }
                isPaused = !isPaused;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _pauseTimers();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Skor: $score', style: const TextStyle(fontSize: 20)),
                    Text(
                      'Süre: $timeLeft',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: cols / rows,
                  child: GestureDetector(
                    onTapUp: (tap) {
                      if (isPaused || showTutorial) return;
                      final box = context.findRenderObject() as RenderBox;
                      final local = box.globalToLocal(tap.globalPosition);
                      final c = (local.dx / (box.size.width / cols)).floor();
                      final r = (local.dy / (box.size.height / rows)).floor();
                      if (r >= 0 && r < rows && c >= 0 && c < cols) {
                        _popAt(r, c);
                      }
                    },
                    child: Container(
                      color: Colors.black,
                      child: CustomPaint(
                        painter: _BubblePainter(grid, tappedCell),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Tutorial overlay
          if (showTutorial)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Nasıl oynanır?\n\nAynı renkten en az 3 balonu dikey veya yatay hizalayın ve dokunarak patlatın!',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final List<List<Color?>> grid;
  final Point<int>? tappedCell;
  _BubblePainter(this.grid, this.tappedCell);

  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()..style = PaintingStyle.fill;
    final paintBorder =
        Paint()
          ..color = Colors.grey[700]!
          ..style = PaintingStyle.stroke;
    final paintTap =
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    final rows = grid.length, cols = grid[0].length;
    final w = size.width / cols, h = size.height / rows;

    // draw grid and bubbles
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(c * w, r * h, w, h);
        canvas.drawRect(rect, paintBorder);

        final col = grid[r][c];
        if (col != null) {
          paintFill.color = col;
          canvas.drawCircle(
            Offset(c * w + w / 2, r * h + h / 2),
            min(w, h) * 0.4,
            paintFill,
          );
        }

        // tapped feedback
        if (tappedCell != null && tappedCell!.x == r && tappedCell!.y == c) {
          canvas.drawRect(rect.deflate(w * 0.1), paintTap);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
