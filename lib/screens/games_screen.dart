import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

import 'snake_game_screen.dart';

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
            // Yılan Oyunu Kartı
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SnakeGameScreen()),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color:
                    themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.games, size: 50, color: Colors.green[700]),
                    const SizedBox(height: 10),
                    const Text(
                      'Yılan Oyunu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Gelecekte eklenecek oyunlar için boş kart
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Yakında',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
