import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';
import '../providers/auth_provider.dart';

enum Direction { up, down, left, right }

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int squaresPerRow = 20;
  static const int squaresPerCol = 40;

  final Random randomGen = Random();

  List<List<int>> snake = <List<int>>[];
  List<int> food = <int>[0, 0];
  Direction direction = Direction.right;

  bool isPlaying = false;
  bool isPaused = false;

  int score = 0;
  int? highScore;
  int gameTime = 0;

  Timer? moveTimer;
  Timer? timeTimer;
  Timer? obstacleTimer;

  List<List<List<int>>> obstacles = <List<List<int>>>[];

  String difficulty = 'Orta';
  int gameSpeed = 225; // ms

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  @override
  void dispose() {
    moveTimer?.cancel();
    timeTimer?.cancel();
    obstacleTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId != null) {
      final hs = await DBHelper.instance.getHighScore(userId, 'snake');
      setState(() {
        highScore = hs;
      });
    }
  }

  void _setDifficulty(String level) {
    setState(() {
      difficulty = level;
      switch (level) {
        case 'Çok Zor':
          gameSpeed = 75;
          break;
        case 'Zor':
          gameSpeed = 150;
          break;
        case 'Orta':
          gameSpeed = 225;
          break;
        case 'Kolay':
          gameSpeed = 300;
          break;
      }
      // Zorluk değiştiğinde moveTimer'ı iptal edip yeni hızla tekrar başlat
      if (moveTimer != null) {
        moveTimer?.cancel();
        moveTimer = Timer.periodic(Duration(milliseconds: gameSpeed), (t) {
          if (isPlaying && !isPaused) {
            moveSnake();
          }
        });
      }
    });
  }

  void startGame() {
    moveTimer?.cancel();
    timeTimer?.cancel();
    obstacleTimer?.cancel();

    snake = <List<int>>[
      [0, 0],
    ];
    direction = Direction.right;
    score = 0;
    gameTime = 0;
    obstacles = <List<List<int>>>[];
    generateNewFood();

    isPlaying = true;
    isPaused = false;

    timeTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (isPlaying && !isPaused) {
        setState(() => gameTime++);
      }
    });

    obstacleTimer = Timer.periodic(const Duration(seconds: 30), (t) {
      if (isPlaying && !isPaused && obstacles.length < 5) {
        addObstacle();
      }
    });

    moveTimer = Timer.periodic(Duration(milliseconds: gameSpeed), (t) {
      if (isPlaying && !isPaused) {
        moveSnake();
      }
    });

    setState(() {});
  }

  void addObstacle() {
    if (obstacles.length >= 5) return;
    int attempts = 0;
    while (attempts < 100) {
      final int x = randomGen.nextInt(squaresPerRow - 1);
      final int y = randomGen.nextInt(squaresPerCol - 1);
      final newObs = <List<int>>[
        [x, y],
        [(x + 1) % squaresPerRow, y],
        [x, (y + 1) % squaresPerCol],
        [(x + 1) % squaresPerRow, (y + 1) % squaresPerCol],
      ];
      var valid = true;
      for (final pos in newObs) {
        if (snake.any((s) => s[0] == pos[0] && s[1] == pos[1]) ||
            obstacles.any(
              (o) => o.any((p) => p[0] == pos[0] && p[1] == pos[1]),
            ) ||
            (pos[0] == food[0] && pos[1] == food[1])) {
          valid = false;
          break;
        }
      }
      if (valid) {
        setState(() => obstacles.add(newObs));
        break;
      }
      attempts++;
    }
  }

  void moveSnake() {
    final head = snake.first;
    int newX = head[0], newY = head[1];
    switch (direction) {
      case Direction.up:
        newY = (head[1] - 1 + squaresPerCol) % squaresPerCol;
        break;
      case Direction.down:
        newY = (head[1] + 1) % squaresPerCol;
        break;
      case Direction.left:
        newX = (head[0] - 1 + squaresPerRow) % squaresPerRow;
        break;
      case Direction.right:
        newX = (head[0] + 1) % squaresPerRow;
        break;
    }

    if (snake.any((s) => s[0] == newX && s[1] == newY) ||
        obstacles.any((o) => o.any((p) => p[0] == newX && p[1] == newY))) {
      endGame();
      return;
    }

    setState(() {
      snake.insert(0, <int>[newX, newY]);
      if (newX == food[0] && newY == food[1]) {
        score++;
        generateNewFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void generateNewFood() {
    bool valid = false;
    int x = 0, y = 0;
    while (!valid) {
      x = randomGen.nextInt(squaresPerRow);
      y = randomGen.nextInt(squaresPerCol);
      valid =
          !(snake.any((s) => s[0] == x && s[1] == y) ||
              obstacles.any((o) => o.any((p) => p[0] == x && p[1] == y)));
    }
    setState(() => food = <int>[x, y]);
  }

  Future<void> _updateHighScore() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId != null) {
      final isNew = await DBHelper.instance.updateHighScore(
        userId,
        'snake',
        score,
      );
      if (isNew) setState(() => highScore = score);
    }
  }

  void endGame() {
    isPlaying = false;
    isPaused = false;
    moveTimer?.cancel();
    timeTimer?.cancel();
    obstacleTimer?.cancel();

    _updateHighScore();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (c) => AlertDialog(
            title: const Text('Oyun Bitti!'),
            content: Text('Skorunuz: $score'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(c).pop();
                  startGame();
                },
                child: const Text('Tekrar Oyna'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(c).pop();
                  Navigator.of(c).pop();
                },
                child: const Text('Oyundan Çık'),
              ),
            ],
          ),
    );
  }

  void _showExitDialog() {
    showDialog<void>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Oyundan Çık'),
            content: const Text('Oyundan çıkmak istediğinize emin misiniz?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Hayır'),
              ),
              TextButton(
                onPressed: () {
                  moveTimer?.cancel();
                  timeTimer?.cancel();
                  obstacleTimer?.cancel();
                  Navigator.pop(c);
                  Navigator.pop(c);
                },
                child: const Text('Evet'),
              ),
            ],
          ),
    );
  }

  void _showDifficultyDialog() {
    showDialog<void>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Zorluk Seviyesi'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: const Text('Çok Zor'),
                  onTap: () {
                    _setDifficulty('Çok Zor');
                    Navigator.pop(c);
                  },
                ),
                ListTile(
                  title: const Text('Zor'),
                  onTap: () {
                    _setDifficulty('Zor');
                    Navigator.pop(c);
                  },
                ),
                ListTile(
                  title: const Text('Orta'),
                  onTap: () {
                    _setDifficulty('Orta');
                    Navigator.pop(c);
                  },
                ),
                ListTile(
                  title: const Text('Kolay'),
                  onTap: () {
                    _setDifficulty('Kolay');
                    Navigator.pop(c);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: _showExitDialog,
                      icon: const Icon(Icons.exit_to_app, color: Colors.white),
                      tooltip: 'Oyundan Çık',
                    ),
                    IconButton(
                      onPressed: _showDifficultyDialog,
                      icon: const Icon(Icons.settings, color: Colors.white),
                      tooltip: 'Zorluk Seviyesi',
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'Zorluk: $difficulty',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Süre: ${gameTime}s',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'Skor: $score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'En Yüksek: ${highScore ?? 0}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0 && direction != Direction.up) {
                  direction = Direction.down;
                } else if (details.delta.dy < 0 &&
                    direction != Direction.down) {
                  direction = Direction.up;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 && direction != Direction.left) {
                  direction = Direction.right;
                } else if (details.delta.dx < 0 &&
                    direction != Direction.right) {
                  direction = Direction.left;
                }
              },
              child: AspectRatio(
                aspectRatio: squaresPerRow / (squaresPerCol + 5),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: squaresPerRow,
                  ),
                  itemCount: squaresPerRow * squaresPerCol,
                  itemBuilder: (context, index) {
                    final x = index % squaresPerRow;
                    final y = index ~/ squaresPerRow;
                    Color color = const Color(0xFF2C2C2C);

                    for (int i = 0; i < snake.length; i++) {
                      if (snake[i][0] == x && snake[i][1] == y) {
                        color =
                            (i == 0)
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF81C784);
                      }
                    }

                    for (final obs in obstacles) {
                      for (final pos in obs) {
                        if (pos[0] == x && pos[1] == y) {
                          color = const Color(0xFFE57373);
                        }
                      }
                    }

                    if (food[0] == x && food[1] == y) {
                      color = const Color(0xFFFFD700);
                    }

                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (!isPlaying) {
                    startGame();
                  } else {
                    setState(() => isPaused = !isPaused);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  !isPlaying ? 'Başlat' : (isPaused ? 'Devam Et' : 'Durdur'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
