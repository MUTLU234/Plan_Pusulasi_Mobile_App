import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({Key? key}) : super(key: key);

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<String> _emojis = ['🎮', '🎲', '🎯', '🎨', '🎭', '🎪', '🎢', '🎡'];
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  int? _firstCardIndex;
  int _moves = 0;
  int _pairsFound = 0;
  bool _canFlip = true;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _cards = [..._emojis, ..._emojis]..shuffle();
      _flipped = List.filled(_cards.length, false);
      _matched = List.filled(_cards.length, false);
      _firstCardIndex = null;
      _moves = 0;
      _pairsFound = 0;
      _canFlip = true;
    });
  }

  void _onCardTap(int index) {
    if (!_canFlip || _flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;

      if (_firstCardIndex == null) {
        _firstCardIndex = index;
      } else {
        _moves++;
        _canFlip = false;

        if (_cards[_firstCardIndex!] == _cards[index]) {
          _matched[_firstCardIndex!] = true;
          _matched[index] = true;
          _pairsFound++;
          _firstCardIndex = null;
          _canFlip = true;

          if (_pairsFound == _emojis.length) {
            _showGameCompleteDialog();
          }
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _flipped[_firstCardIndex!] = false;
                _flipped[index] = false;
                _firstCardIndex = null;
                _canFlip = true;
              });
            }
          });
        }
      }
    });
  }

  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Tebrikler!'),
            content: Text('Oyunu $_moves hamlede tamamladınız!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startNewGame();
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _showExitDialog,
                    icon: const Icon(Icons.exit_to_app),
                    tooltip: 'Oyundan Çık',
                  ),
                  Text(
                    'Hamle: $_moves',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Eşleşen: $_pairsFound/${_emojis.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: Card(
                      elevation: 4,
                      color:
                          _matched[index]
                              ? Colors.green[300]
                              : _flipped[index]
                              ? Colors.white
                              : Colors.orange[100],
                      child: Center(
                        child: Text(
                          _flipped[index] || _matched[index]
                              ? _cards[index]
                              : '?',
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
