import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

class MathRaceScreen extends StatefulWidget {
  const MathRaceScreen({Key? key}) : super(key: key);

  @override
  State<MathRaceScreen> createState() => _MathRaceScreenState();
}

class _MathRaceScreenState extends State<MathRaceScreen> {
  int _score = 0;
  int _level = 1;
  int _timeLeft = 30;
  late int _num1;
  late int _num2;
  late String _operator;
  late int _correctAnswer;
  late List<int> _options;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _generateNewQuestion();
    _startTimer();
  }

  void _generateNewQuestion() {
    final random = Random();
    _num1 = random.nextInt(10 * _level) + 1;
    _num2 = random.nextInt(10 * _level) + 1;

    // Operatör seçimi
    final operators = ['+', '-', '×'];
    _operator = operators[random.nextInt(operators.length)];

    // Doğru cevabı hesapla
    switch (_operator) {
      case '+':
        _correctAnswer = _num1 + _num2;
        break;
      case '-':
        // Negatif sonuç olmaması için
        if (_num1 < _num2) {
          final temp = _num1;
          _num1 = _num2;
          _num2 = temp;
        }
        _correctAnswer = _num1 - _num2;
        break;
      case '×':
        _correctAnswer = _num1 * _num2;
        break;
    }

    // Yanlış cevapları oluştur
    _options = [_correctAnswer];
    while (_options.length < 4) {
      final wrongAnswer = _correctAnswer + random.nextInt(10) - 5;
      if (wrongAnswer > 0 && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }
    _options.shuffle();
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

  void _checkAnswer(int selectedAnswer) {
    if (_isGameOver) return;

    if (selectedAnswer == _correctAnswer) {
      setState(() {
        _score += 10;
        if (_score % 50 == 0) {
          _level++;
        }
        _timeLeft = 30;
        _generateNewQuestion();
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
              // Soru
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                child: Text(
                  '$_num1 $_operator $_num2 = ?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Cevap Seçenekleri
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    return ElevatedButton(
                      onPressed: () => _checkAnswer(_options[index]),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.purple[100],
                      ),
                      child: Text(
                        _options[index].toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
