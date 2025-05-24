import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

class EmojiPuzzleScreen extends StatefulWidget {
  const EmojiPuzzleScreen({Key? key}) : super(key: key);

  @override
  State<EmojiPuzzleScreen> createState() => _EmojiPuzzleScreenState();
}

class _EmojiPuzzleScreenState extends State<EmojiPuzzleScreen> {
  final List<Map<String, String>> _puzzles = [
    {'emojis': '🎬 🎭 🎪', 'answer': 'SİRK', 'category': 'Eğlence'},
    {'emojis': '🌙 ⭐ 🌠', 'answer': 'GECE', 'category': 'Doğa'},
    {'emojis': '🎨 🖌️ 🖼️', 'answer': 'RESİM', 'category': 'Sanat'},
    {'emojis': '🎮 🎲 🎯', 'answer': 'OYUN', 'category': 'Eğlence'},
    {'emojis': '🌞 🏖️ 🌊', 'answer': 'YAZ', 'category': 'Mevsim'},
    {'emojis': '🎵 🎸 🎹', 'answer': 'MÜZİK', 'category': 'Sanat'},
    {'emojis': '🍕 🍔 🍟', 'answer': 'FAST FOOD', 'category': 'Yemek'},
    {'emojis': '🏃 🏃‍♀️ 🏃‍♂️', 'answer': 'KOŞU', 'category': 'Spor'},
    {'emojis': '☕ 🥐 🍞', 'answer': 'KAHVALTI', 'category': 'Yemek'},
    {'emojis': '🚗 🛣️ ⛽', 'answer': 'ARABA', 'category': 'Taşıt'},
    {'emojis': '🏥 💉 🩺', 'answer': 'HASTANE', 'category': 'Yer'},
    {'emojis': '📚 📝 🎓', 'answer': 'EĞİTİM', 'category': 'Faaliyet'},
    {'emojis': '🛌 💭 😴', 'answer': 'UYKU', 'category': 'İhtiyaç'},
    {'emojis': '☔ 🌂 🌧️', 'answer': 'YAĞMUR', 'category': 'Hava Durumu'},
    {'emojis': '🔥 🍛 🍲', 'answer': 'YEMEK', 'category': 'Yemek'},
    {'emojis': '🚀 🌌 🪐', 'answer': 'UZAY', 'category': 'Doğa'},
    {'emojis': '🖥️⌨️🖱️', 'answer': 'BİLGİSAYAR', 'category': 'Teknoloji'},
    {'emojis': '📱 💬 🔔', 'answer': 'TELEFON', 'category': 'Teknoloji'},
    {'emojis': '👨‍🍳 🍳 🥘', 'answer': 'AŞÇI', 'category': 'Meslek'},
    {'emojis': '🐶 🐱 🐰', 'answer': 'EV HAYVANI', 'category': 'Hayvan'},
    {'emojis': '🎬 🍿 🎥', 'answer': 'SİNEMA', 'category': 'Eğlence'},
    {'emojis': '🎂 🎉 🎁', 'answer': 'DOĞUM GÜNÜ', 'category': 'Kutlama'},
    {'emojis': '⚽ 🥅 🏟️', 'answer': 'FUTBOL', 'category': 'Spor'},
    {'emojis': '🏄‍♂️ 🌊 🏖️', 'answer': 'SÖRF', 'category': 'Spor'},
    {'emojis': '🏝️ 🏊‍♂️ 🌅', 'answer': 'TATİL', 'category': 'Faaliyet'},
    {'emojis': '🚌 🚏 🗺️', 'answer': 'OTOBÜS', 'category': 'Taşıt'},
    {'emojis': '📷 📸 🎞️', 'answer': 'FOTOĞRAF', 'category': 'Sanat'},
    {'emojis': '📺 📡 🎞️', 'answer': 'TELEVİZYON', 'category': 'Teknoloji'},
    {'emojis': '💡 🕯️ 🔦', 'answer': 'AYDINLATMA', 'category': 'Nesne'},
    {'emojis': '🌳 🏞️ 🌿', 'answer': 'ORMAN', 'category': 'Doğa'},
  ];

  late Map<String, String> _currentPuzzle;
  int _score = 0;
  int _level = 1;
  int _hintsLeft = 3;
  bool _isCorrect = false;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startNewRound() {
    _currentPuzzle = _puzzles[Random().nextInt(_puzzles.length)];
    _controller.clear();
    _isCorrect = false;
    setState(() {});
  }

  /// Türkçe karakterleri ASCII karşılıklarına dönüştürüp
  /// büyük harfe çevirir.
  String _normalize(String input) {
    const Map<String, String> map = {
      'Ç': 'C',
      'ç': 'C',
      'Ğ': 'G',
      'ğ': 'G',
      'İ': 'I',
      'ı': 'I',
      'Ö': 'O',
      'ö': 'O',
      'Ş': 'S',
      'ş': 'S',
      'Ü': 'U',
      'ü': 'U',
    };
    final buffer = StringBuffer();
    for (var rune in input.runes) {
      final ch = String.fromCharCode(rune);
      if (map.containsKey(ch)) {
        buffer.write(map[ch]);
      } else {
        buffer.write(ch.toUpperCase());
      }
    }
    return buffer.toString();
  }

  void _checkAnswer() {
    final user = _normalize(_controller.text.trim());
    final answer = _normalize(_currentPuzzle['answer']!);
    if (user == answer && !_isCorrect) {
      setState(() {
        _score += 10;
        _isCorrect = true;
        if (_score % 50 == 0) _level++;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _startNewRound();
      });
    }
  }

  void _useHint() {
    if (_hintsLeft > 0 && !_isCorrect) {
      setState(() {
        _hintsLeft--;
        _controller.text = _currentPuzzle['answer']!;
      });
      _checkAnswer();
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bgColor =
        themeProvider.isDarkMode ? Colors.grey[900] : HexColor(backgroundColor);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.amber[700],
        title: const Text('Emoji Bulmaca'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: _showExitDialog,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Skor & Seviye
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
            // Kategori
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Kategori: ${_currentPuzzle['category']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Emojiler
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
                _currentPuzzle['emojis']!,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 20),
            // Kullanıcı Girişi
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Cevabı buraya yazın',
                filled: true,
                fillColor: _isCorrect ? Colors.green[50] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _checkAnswer(),
            ),
            const SizedBox(height: 20),
            // Kontrol Et butonu
            ElevatedButton(
              onPressed: _checkAnswer,
              child: const Text('Kontrol Et', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const Spacer(),
            // İpucu Butonu
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
