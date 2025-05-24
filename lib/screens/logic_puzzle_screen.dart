import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

class LogicPuzzleScreen extends StatefulWidget {
  const LogicPuzzleScreen({Key? key}) : super(key: key);

  @override
  State<LogicPuzzleScreen> createState() => _LogicPuzzleScreenState();
}

class _LogicPuzzleScreenState extends State<LogicPuzzleScreen> {
  List<Map<String, dynamic>> _puzzles = [];
  Map<String, dynamic>? _currentPuzzle;
  int? _lastPuzzleIndex;
  int _score = 0, _level = 1, _hintsLeft = 3;
  bool _showExplanation = false;

  @override
  void initState() {
    super.initState();
    _loadPuzzles();
  }

  Future<void> _loadPuzzles() async {
    final data = await rootBundle.loadString('lib/assets/sorular.json');
    _puzzles = List<Map<String, dynamic>>.from(json.decode(data));
    _startNewRound();
  }

  void _startNewRound() {
    if (_puzzles.isEmpty) return;

    int idx = Random().nextInt(_puzzles.length);
    // Aynı sorunun art arda seçilmesini önle
    while (_lastPuzzleIndex != null && idx == _lastPuzzleIndex) {
      idx = Random().nextInt(_puzzles.length);
    }
    _lastPuzzleIndex = idx;
    _currentPuzzle = _puzzles[idx];
    _showExplanation = false;
    setState(() {});
  }

  void _checkAnswer(String selected) {
    final correct = selected == _currentPuzzle?['answer'];
    setState(() {
      if (correct) {
        _score += 10;
        if (_score % 50 == 0) _level++;
      }
      _showExplanation = true;
    });

    if (correct) {
      // Doğruysa biraz bekleyip yeni tur başlat
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _startNewRound();
      });
    }
  }

  void _useHint() {
    if (_hintsLeft > 0) {
      setState(() {
        _hintsLeft--;
        _showExplanation = true;
      });
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Oyundan Çık'),
            content: const Text('Oyundan çıkmak istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hayır'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Evet'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final bgColor =
        theme.isDarkMode ? Colors.grey[900] : HexColor(backgroundColor);

    if (_currentPuzzle == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Skor, Seviye ve Çıkış Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _showExitDialog,
                    icon: const Icon(Icons.exit_to_app),
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
              const SizedBox(height: 20),
              // Soru Kartı
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
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _currentPuzzle!['question'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_showExplanation) ...[
                      const SizedBox(height: 20),
                      Text(
                        _currentPuzzle!['explanation'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Seçenekler
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children:
                      (List<String>.from(_currentPuzzle!['options'])..shuffle())
                          .map(
                            (opt) => ElevatedButton(
                              onPressed: () => _checkAnswer(opt),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(20),
                              ),
                              child: Text(
                                opt,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 16),
              // İpucu Butonu
              ElevatedButton.icon(
                onPressed: _useHint,
                icon: const Icon(Icons.lightbulb),
                label: Text('İpucu ($_hintsLeft)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
