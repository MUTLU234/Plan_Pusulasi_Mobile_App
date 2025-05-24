import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

class ColorMatchScreen extends StatefulWidget {
  const ColorMatchScreen({Key? key}) : super(key: key);

  @override
  State<ColorMatchScreen> createState() => _ColorMatchScreenState();
}

class _ColorMatchScreenState extends State<ColorMatchScreen> {
  int _score = 0;
  int _level = 1;
  int _timeLeft = 30;
  late Color _targetColor;
  late List<Color> _colorOptions;
  bool _isGameOver = false;

  final List<String> _colorNames = [
    'Kırmızı',
    'Mavi',
    'Yeşil',
    'Sarı',
    'Mor',
    'Turuncu',
    'Pembe',
    'Turkuaz',
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _generateNewColors();
    _startTimer();
  }

  void _generateNewColors() {
    final random = Random();
    _targetColor = _getRandomColor();

    // Renk seçeneklerini oluştur
    _colorOptions = [_targetColor];
    while (_colorOptions.length < 4) {
      final newColor = _getRandomColor();
      if (!_colorOptions.contains(newColor)) {
        _colorOptions.add(newColor);
      }
    }
    _colorOptions.shuffle();
  }

  Color _getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isGameOver) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
            _startTimer();
          } else {
            _isGameOver = true;
            _showGameOverDialog();
          }
        });
      }
    });
  }

  void _checkAnswer(Color selectedColor) {
    if (_isGameOver) return;

    if (selectedColor == _targetColor) {
      setState(() {
        _score += 10;
        if (_score % 50 == 0) {
          _level++;
        }
        _timeLeft = 30;
        _generateNewColors();
      });
    } else {
      setState(() {
        _isGameOver = true;
        _showGameOverDialog();
      });
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Oyun Bitti!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text('Skorunuz: $_score'), Text('Seviye: $_level')],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _score = 0;
                    _level = 1;
                    _timeLeft = 30;
                    _isGameOver = false;
                    _startGame();
                  });
                },
                child: const Text('Tekrar Oyna'),
              ),
            ],
          ),
    );
  }

  // Oyundan çıkış dialogu
  void _showExitDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Oyundan Çık'),
            content: const Text('Oyundan çıkmak istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hayır'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog'u kapat
                  Navigator.pop(context); // Oyun ekranından çık
                },
                child: const Text('Evet'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bgColor =
        themeProvider.isDarkMode ? Colors.grey[900] : HexColor(backgroundColor);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Skor ve Seviye
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Çıkış butonu
                  IconButton(
                    onPressed: _showExitDialog,
                    icon: const Icon(Icons.exit_to_app),
                    tooltip: 'Oyundan Çık',
                  ),
                  Text(
                    'Skor: $_score',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Seviye: $_level',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Kalan Süre
              LinearProgressIndicator(
                value: _timeLeft / 30,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _timeLeft > 10 ? Colors.green : Colors.red,
                ),
              ),
              Text(
                'Süre: $_timeLeft',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Hedef Renk
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _targetColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Hedef Renk',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Renk Seçenekleri
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _colorOptions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _checkAnswer(_colorOptions[index]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _colorOptions[index],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
