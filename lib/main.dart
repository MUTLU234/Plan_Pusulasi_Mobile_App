import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/screens/add_task_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  static final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.white,
    ),
  );

  static final MaterialColor _customPurple =
      MaterialColor(0xFF25052B, const <int, Color>{
        50: Color(0xFFE8E0E9),
        100: Color(0xFFC5B3C8),
        200: Color(0xFFA080A3),
        300: Color(0xFF7A4D7E),
        400: Color(0xFF5F2663),
        500: Color(0xFF25052B),
        600: Color(0xFF210426),
        700: Color(0xFF1B0321),
        800: Color(0xFF16021B),
        900: Color(0xFF0D0110),
      });

  static final ThemeData _darkTheme = ThemeData(
    primarySwatch: _customPurple,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.grey[800],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Task> tasks = [
    Task("Fonk. Prog. Görevi", false),
    Task("Ana Ekran Düzenini İncele", false),
    Task("Boşluk ve Margin Ayarları", false),
  ];

  List<Task> completedTasks = [
    Task("Fonk. Prog. Görevi", true),
    Task("Fonk. Prog. Görevi", true),
  ];

  void _addNewTask(String taskTitle) {
    setState(() {
      tasks.add(Task(taskTitle, false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      home: HomeScreen(
        tasks: tasks,
        completedTasks: completedTasks,
        onTaskAdded: _addNewTask,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final List<Task> tasks;
  final List<Task> completedTasks;
  final Function(String) onTaskAdded;

  const HomeScreen({
    super.key,
    required this.tasks,
    required this.completedTasks,
    required this.onTaskAdded,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor:
            themeProvider.isDarkMode
                ? Colors.grey[900]
                : HexColor(backgroundColor),
        body: Column(
          children: [
            // Header
            Stack(
              children: [
                Container(
                  width: deviceWidth,
                  height: deviceHeight / 3,
                  decoration: BoxDecoration(
                    color:
                        themeProvider.isDarkMode
                            ? Colors.grey[900]
                            : const Color.fromARGB(255, 60, 8, 69),
                    image: const DecorationImage(
                      image: AssetImage("lib/assets/images/header.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${DateTime.now().day} ${DateTime.now().month == 3 ? 'Mart' : DateTime.now().month == 4 ? 'Nisan' : 'Mayıs'} ${DateTime.now().year}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Yapılacak Aktiviteler",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[800]
                              : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color:
                            themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                      ),
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Top Column - Active Tasks
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Yapılacaklar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.tasks.length,
                        itemBuilder: (context, index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              elevation: 4,
                              color:
                                  themeProvider.isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.note_add_rounded,
                                          size: 40,
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          widget.tasks[index].title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: widget.tasks[index].isCompleted,
                                          onChanged: (val) {
                                            setState(() {
                                              widget.tasks[index].isCompleted =
                                                  val!;
                                              if (val) {
                                                widget.completedTasks.add(
                                                  widget.tasks[index],
                                                );
                                                widget.tasks.removeAt(index);
                                              }
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              widget.tasks.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
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
            ),
            // Bottom Column - Completed Tasks
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Yaptıklarım",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.completedTasks.length,
                        itemBuilder: (context, index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              elevation: 2,
                              color:
                                  themeProvider.isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          size: 40,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          widget.completedTasks[index].title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Checkbox(
                                      value: widget.completedTasks[index].isCompleted,
                                      onChanged: (val) {
                                        setState(() {
                                          widget.completedTasks[index].isCompleted = val!;
                                          if (!val) {
                                            widget.tasks.add(
                                              widget.completedTasks[index],
                                            );
                                            widget.completedTasks.removeAt(
                                              index,
                                            );
                                          }
                                        });
                                      },
                                    ),
                                  ],
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
            ),
            // Add Task Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              AddTaskScreen(onTaskAdded: widget.onTaskAdded),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      themeProvider.isDarkMode
                          ? Colors.deepPurple[800]
                          : Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Yeni Görev Ekle",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Task {
  String title;
  bool isCompleted;

  Task(this.title, this.isCompleted);
}
