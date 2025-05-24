import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

import 'bubble_pop_screen.dart';
import 'color_match_screen.dart';
import 'emoji_puzzle_screen.dart';
import 'flappy_bird_screen.dart';
import 'logic_puzzle_screen.dart';
import 'math_race_screen.dart';
import 'memory_game_screen.dart';
import 'snake_game_screen.dart';
import 'word_puzzle_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bgColor =
        themeProvider.isDarkMode ? Colors.grey[900] : HexColor(backgroundColor);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.deepPurple,
        title: const Text('Oyunlar'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            // Yılan Oyunu
            _buildGameCard(
              context,
              'Yılan Oyunu',
              Icons.videogame_asset,
              Colors.green[700]!,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SnakeGameScreen()),
              ),
            ),
            // Kelime Oyunu
            _buildGameCard(
              context,
              'Kelime Oyunu',
              Icons.text_fields,
              Colors.blue[700]!,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WordPuzzleScreen()),
              ),
            ),
            // Hafıza Kartları
            _buildGameCard(
              context,
              'Hafıza Kartları',
              Icons.grid_view,
              Colors.orange[700]!,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemoryGameScreen()),
              ),
            ),
            // Matematik Yarışması
            _buildGameCard(
              context,
              'Matematik Yarışması',
              Icons.calculate,
              Colors.purple[700]!,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MathRaceScreen()),
              ),
            ),
            // Renk Eşleştirme
            _buildGameCard(
              context,
              'Renk Eşleştirme',
              Icons.color_lens,
              Colors.pink[700]!,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ColorMatchScreen()),
              ),
            ),
            // Emoji Bulmaca
            _buildGameCard(
              context,
              'Emoji Bulmaca',
              Icons.emoji_emotions,
              Colors.amber[700]!,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmojiPuzzleScreen()),
              ),
            ),
            // Mantık Bulmacaları
            _buildGameCard(
              context,
              'Mantık Bulmacaları',
              Icons.psychology,
              Colors.teal[700]!,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LogicPuzzleScreen()),
              ),
            ),
            // Balon Patlatma
            _buildGameCard(
              context,
              'Balon Patlatma',
              Icons.bubble_chart,
              Colors.red[400]!,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BubblePopScreen()),
              ),
            ),
            // Flappy Kuş
            _buildGameCard(
              context,
              'Flappy Kuş',
              Icons.flight,
              Colors.lightGreen[400]!,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FlappyBirdScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
