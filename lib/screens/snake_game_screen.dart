import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';
import '../providers/auth_provider.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int squaresPerRow = 20;
  static const int squaresPerCol = 40;
  final randomGen = Random();

  var snake = [
    [0, 0],
  ];
  var food = [0, 0];
  var direction = 'right';
  var isPlaying = false;
  var score = 0;
  int? highScore;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId != null) {
      final score = await DBHelper.instance.getHighScore(userId, 'snake');
      setState(() {
        highScore = score;
      });
    }
  }

  void startGame() {
    const duration = Duration(milliseconds: 300);
    snake = [
      [0, 0],
    ];
    direction = 'right';
    score = 0;
    generateNewFood();
    isPlaying = true;
    timer = Timer.periodic(duration, (Timer t) {
      moveSnake();
    });
  }

  void moveSnake() {
    setState(() {
      switch (direction) {
        case 'up':
          snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          break;
        case 'down':
          snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          break;
        case 'left':
          snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          break;
        case 'right':
          snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          break;
      }

      if (snake.first[1] < 0) {
        snake.first[1] = squaresPerCol - 1;
      } else if (snake.first[1] > squaresPerCol - 1) {
        snake.first[1] = 0;
      }

      if (snake.first[0] < 0) {
        snake.first[0] = squaresPerRow - 1;
      } else if (snake.first[0] > squaresPerRow - 1) {
        snake.first[0] = 0;
      }

      if (snake.first[0] == food[0] && snake.first[1] == food[1]) {
        generateNewFood();
        score++;
        _updateHighScore();
      } else {
        snake.removeLast();
      }

      for (var i = 1; i < snake.length; i++) {
        if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
          endGame();
        }
      }
    });
  }

  void generateNewFood() {
    food = [randomGen.nextInt(squaresPerRow), randomGen.nextInt(squaresPerCol)];
  }

  Future<void> _updateHighScore() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId != null) {
      final isNewHighScore = await DBHelper.instance.updateHighScore(
        userId,
        'snake',
        score,
      );
      if (isNewHighScore) {
        setState(() {
          highScore = score;
        });
      }
    }
  }

  void endGame() {
    timer?.cancel();
    isPlaying = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oyun Bitti!'),
          content: Text('Skorunuz: $score'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tekrar Oyna'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
            TextButton(
              child: const Text('Oyundan Çık'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: AspectRatio(
                aspectRatio: squaresPerRow / (squaresPerCol + 5),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: squaresPerRow,
                  ),
                  itemCount: squaresPerRow * squaresPerCol,
                  itemBuilder: (BuildContext context, int index) {
                    var color = Colors.grey[900];
                    var x = index % squaresPerRow;
                    var y = (index / squaresPerRow).floor();

                    for (var pos in snake) {
                      if (pos[0] == x && pos[1] == y) {
                        color = Colors.green;
                      }
                    }

                    if (food[0] == x && food[1] == y) {
                      color = Colors.red;
                    }

                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.rectangle,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  child: Text(
                    isPlaying ? 'Durdur' : 'Başlat',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      timer?.cancel();
                      isPlaying = false;
                    } else {
                      startGame();
                    }
                  },
                ),
                Text(
                  'Skor: $score',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  'En Yüksek: ${highScore ?? 0}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
