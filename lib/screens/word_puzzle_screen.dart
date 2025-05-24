import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

class WordPuzzleScreen extends StatefulWidget {
  const WordPuzzleScreen({Key? key}) : super(key: key);

  @override
  State<WordPuzzleScreen> createState() => _WordPuzzleScreenState();
}

class _WordPuzzleScreenState extends State<WordPuzzleScreen> {
  // Data pools
  List<String> _words = [];
  List<String> _skippedWords = [];

  // Current round state
  String _currentWord = '';
  List<String> _shuffledLetters = [];
  String _userInput = '';

  // Game state
  int _score = 0;
  int _level = 1;
  int _hintsLeft = 3;
  bool _isCorrect = false;
  bool _isLoading = true;

  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/assets/puzzles.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        _words = List<String>.from(jsonData['words']);
        _startNewRound();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading words: $e');
      setState(() {
        _words = ['FLUTTER', 'DART', 'MOBILE', 'GAME', 'PUZZLE'];
        _startNewRound();
        _isLoading = false;
      });
    }
  }

  void _startNewRound() {
    if (_words.isEmpty) {
      if (_skippedWords.isEmpty) {
        _showGameCompletedDialog();
        return;
      }
      _words = List.from(_skippedWords);
      _skippedWords.clear();
    }

    _currentWord = _words.removeAt(_rng.nextInt(_words.length));
    _shuffledLetters = _currentWord.split('')..shuffle(_rng);
    _userInput = '';
    _isCorrect = false;
  }

  void _skipWord() {
    setState(() {
      _skippedWords.add(_currentWord);
      _startNewRound();
    });
  }

  void _showGameCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Tebrikler!'),
            content: Text('Tüm kelimeleri tamamladınız!\nToplam Puan: $_score'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Tamam'),
              ),
            ],
          ),
    );
  }

  void _checkWord() {
    if (_userInput.toUpperCase() == _currentWord) {
      setState(() {
        _score += 10;
        _isCorrect = true;
        if (_score % 50 == 0) _level++;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _startNewRound();
          });
        }
      });
    }
  }

  void _useHint() {
    if (_hintsLeft > 0) {
      setState(() {
        _hintsLeft--;
        _userInput = _currentWord;
        _checkWord();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bgColor =
        themeProvider.isDarkMode ? Colors.grey[900] : HexColor(backgroundColor);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor:
              themeProvider.isDarkMode ? Colors.grey[900] : Colors.blue[700],
          title: const Text('İngilizce Kelime Oyunu'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.blue[700],
        title: const Text('İngilizce Kelime Oyunu'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Skor ve Seviye
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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

            // Karışık Harfler
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children:
                  _shuffledLetters.map((letter) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),

            // Kullanıcı Girişi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCorrect ? Colors.green[100] : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _userInput.isEmpty ? 'Kelimeyi yazın...' : _userInput,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Harf Butonları
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _shuffledLetters.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userInput += _shuffledLetters[index];
                        _checkWord();
                      });
                    },
                    child: Text(
                      _shuffledLetters[index],
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                },
              ),
            ),

            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _hintsLeft > 0 ? _useHint : null,
                  icon: const Icon(Icons.lightbulb),
                  label: Text('İpucu ($_hintsLeft)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _skipWord,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Pas Geç'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
