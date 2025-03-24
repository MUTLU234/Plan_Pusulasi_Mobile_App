import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        //SafeArea sayesinde üstteki bildirim panelini kapsamadık onun altından başladık.
        child: Scaffold(
          backgroundColor: HexColor(backgroundColor),
          body: Container(
            width: deviceWidth,
            height: deviceHeight / 3, //bölü 3 ekranın 3'te 1'i
            decoration: BoxDecoration(
              color: Colors.purple,
              image: DecorationImage(
                image: AssetImage("lib/assets/images/header.png"),
                fit:
                    BoxFit
                        .cover, //header.png görseli Header alanına yayıldı, kenarlarda boşluk kalmadı.
              ),
            ),
            child: const Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 20,
                  ), //tepeden 20 birim boşluk bıraktım.
                  child: Text(
                    "24 Mart 2025",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 40,
                  ), //Üstündeki nesneden 40 birim boşluk bıraktım.
                  child: Text(
                    "Yapılacak Aktiviteler",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
