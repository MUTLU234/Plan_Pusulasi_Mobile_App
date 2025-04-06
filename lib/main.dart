import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isChecked = false;

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
          body: Column(
            children: [
              // Header
              Container(
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
              // Top Column Yukarıdaki
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(Icons.note_add_rounded, size: 50),
                                const Text(
                                  "Fonk. Prog. Görevi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                  ),
                                ),
                                Checkbox(
                                  value: isChecked,
                                  onChanged:
                                      (val) => {
                                        setState(() {
                                          isChecked = val!;
                                        }),
                                      },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(Icons.note_add_rounded, size: 50),
                                const Text(
                                  "Fonk. Prog. Görevi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                  ),
                                ),
                                Checkbox(
                                  value: isChecked,
                                  onChanged:
                                      (val) => {
                                        setState(() {
                                          isChecked = val!;
                                        }),
                                      },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(Icons.note_add_rounded, size: 50),
                                const Text(
                                  "Fonk. Prog. Görevi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                  ),
                                ),
                                Checkbox(
                                  value: isChecked,
                                  onChanged:
                                      (val) => {
                                        setState(() {
                                          isChecked = val!;
                                        }),
                                      },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Yaptıklarım Text'i
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Yaptıklarım",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              // Bottom Column Alttaki
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(Icons.note_add_rounded, size: 50),
                                const Text(
                                  "Fonk. Prog. Görevi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                  ),
                                ),
                                Checkbox(
                                  value: isChecked,
                                  onChanged:
                                      (val) => {
                                        setState(() {
                                          isChecked = val!;
                                        }),
                                      },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(Icons.note_add_rounded, size: 50),
                                const Text(
                                  "Fonk. Prog. Görevi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                  ),
                                ),
                                Checkbox(
                                  value: isChecked,
                                  onChanged:
                                      (val) => {
                                        setState(() {
                                          isChecked = val!;
                                        }),
                                      },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(Icons.note_add_rounded, size: 50),
                                const Text(
                                  "Fonk. Prog. Görevi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                  ),
                                ),
                                Checkbox(
                                  value: isChecked,
                                  onChanged:
                                      (val) => {
                                        setState(() {
                                          isChecked = val!;
                                        }),
                                      },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Yeni Görev Ekle"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
