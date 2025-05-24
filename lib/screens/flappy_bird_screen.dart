import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

class FlappyBirdScreen extends StatefulWidget {
  const FlappyBirdScreen({Key? key}) : super(key: key);

  @override
  _FlappyBirdScreenState createState() => _FlappyBirdScreenState();
}

class _FlappyBirdScreenState extends State<FlappyBirdScreen> {
  // ——— CONSTANTS ———
  static const Duration _frameDuration = Duration(milliseconds: 33); // ~30 FPS
  static const double _gravity = 1.0; // acceleration (normalized)
  static const double _jumpImpulse = -0.8; // initial jump velocity (normalized)
  static const double _barrierSpeed = 0.0065; // ↑ increased by ~30%
  static const double _barrierInterval =
      1.2; // distance between barriers (normalized)
  static const double _minGapY = -0.3; // min hole center (normalized)
  static const double _maxGapY = 0.3; // max hole center (normalized)
  static const double _birdRadius = 0.05; // normalized
  static const double _barrierHalfW = 0.1; // normalized
  static const double _holeHalfH = 0.2; // normalized

  // ——— STATE ———
  final Random _rng = Random();
  Timer? _gameTimer;

  double _birdY = 0.0;
  double _velocity = 0.0;
  late List<double> _barrierX;
  late List<double> _holeY;

  int _score = 0;
  int _highScore = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
    _startGame();
  }

  void _resetGame() {
    _gameTimer?.cancel();
    _birdY = 0.0;
    _velocity = 0.0;
    _score = 0;
    _isPlaying = false;
    // Place barriers off-screen at start
    _barrierX = List.generate(3, (i) => 1.5 + i * _barrierInterval);
    _holeY = List.generate(
      3,
      (_) => _rng.nextDouble() * (_maxGapY - _minGapY) + _minGapY,
    );
  }

  void _startGame() {
    _isPlaying = true;
    _gameTimer = Timer.periodic(_frameDuration, _updateGame);
  }

  void _updateGame(Timer timer) {
    final dt = _frameDuration.inMilliseconds / 1000; // ~0.033

    setState(() {
      // 1) Apply gravity
      _velocity += _gravity * dt;
      _birdY += _velocity * dt;

      // 2) Move & recycle barriers
      for (int i = 0; i < _barrierX.length; i++) {
        _barrierX[i] -= _barrierSpeed;
        if (_barrierX[i] < -1.0 - _barrierHalfW) {
          final maxX = _barrierX.reduce(max);
          _barrierX[i] = maxX + _barrierInterval;
          _holeY[i] = _rng.nextDouble() * (_maxGapY - _minGapY) + _minGapY;
          _score++;
        }
      }

      // 3) Check collision or out-of-bounds
      if (_checkCollision() || _birdY.abs() > 1.0) {
        _endGame();
      }
    });
  }

  bool _checkCollision() {
    for (int i = 0; i < _barrierX.length; i++) {
      final x = _barrierX[i], y = _holeY[i];
      if ((x).abs() < _barrierHalfW + _birdRadius) {
        if (_birdY + _birdRadius < y - _holeHalfH ||
            _birdY - _birdRadius > y + _holeHalfH) {
          return true;
        }
      }
    }
    return false;
  }

  void _endGame() {
    _gameTimer?.cancel();
    _isPlaying = false;
    if (_score > _highScore) _highScore = _score;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Oyun Bitti'),
            content: Text('Skorunuz: $_score\nRekor: $_highScore'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetGame();
                  _startGame();
                },
                child: const Text('Yeniden Başlat'),
              ),
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

  void _jump() {
    if (!_isPlaying) return;
    setState(() {
      _velocity = _jumpImpulse;
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final bgColor = theme.isDarkMode ? Colors.grey[900] : Colors.lightBlue[100];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _jump,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text('Flappy Kuş'),
          backgroundColor:
              theme.isDarkMode ? Colors.grey[900] : Colors.deepPurple,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // GAME AREA
            Expanded(
              flex: 3,
              child: LayoutBuilder(
                builder: (ctx, cons) {
                  return Stack(
                    children: [
                      // Bird
                      Align(
                        alignment: Alignment(0, _birdY),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Barriers
                      for (int i = 0; i < _barrierX.length; i++)
                        _buildBarrier(_barrierX[i], _holeY[i], cons),
                    ],
                  );
                },
              ),
            ),
            // SCORE PANEL
            Expanded(
              child: Container(
                color: Colors.green,
                child: Center(
                  child: Text(
                    'Skor: $_score',
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarrier(double x, double holeY, BoxConstraints cons) {
    const holeHeight = 150.0;
    final fullH = cons.maxHeight;
    final topH = (fullH / 2) + holeY * (fullH / 2) - holeHeight / 2;
    final bottomH = fullH - topH - holeHeight;
    final left = (x + 1) / 2 * cons.maxWidth;
    const barW = 60.0;

    return Stack(
      children: [
        Positioned(
          left: left,
          top: 0,
          width: barW,
          height: topH.clamp(0.0, fullH),
          child: Container(color: Colors.green[700]),
        ),
        Positioned(
          left: left,
          top: topH + holeHeight,
          width: barW,
          height: bottomH.clamp(0.0, fullH),
          child: Container(color: Colors.green[700]),
        ),
      ],
    );
  }
}
