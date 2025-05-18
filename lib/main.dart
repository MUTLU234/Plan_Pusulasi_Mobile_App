import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/providers/auth_provider.dart';
import 'package:plan_pusulasi/screens/add_task_screen.dart';
import 'package:plan_pusulasi/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
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
      foregroundColor: Colors.black,
    ),
  );

  static final MaterialColor _customPurple =
      MaterialColor(0xFF25052B, <int, Color>{
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
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF212121),
      foregroundColor: Colors.white,
    ),
  );
}

enum TaskType { personal, work, study, other }

class Task {
  String title;
  TaskType type;
  DateTime dueDate;
  bool isCompleted;

  Task({
    required this.title,
    required this.type,
    required this.dueDate,
    this.isCompleted = false,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Consumer<AuthProvider>(
      builder: (ctx, auth, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: auth.isLoggedIn ? HomeScreenContainer() : const LoginScreen(),
        );
      },
    );
  }
}

/// Burası eski HomeScreen içeriğinizin ayrı bir dosyada olduğu varsayımıyla
/// Eğer HomeScreen kodunuz bu dosyada ise bunu da aşağı ya da başka bir
/// dosyadan çağırabilirsiniz.
class HomeScreenContainer extends StatefulWidget {
  @override
  State<HomeScreenContainer> createState() => _HomeScreenContainerState();
}

class _HomeScreenContainerState extends State<HomeScreenContainer> {
  final List<Task> _tasks = [
    Task(
      title: "Fonk. Prog. Görevi",
      type: TaskType.study,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    Task(
      title: "Ana Ekran Düzenini İncele",
      type: TaskType.work,
      dueDate: DateTime.now().add(const Duration(days: 2)),
    ),
    Task(
      title: "Boşluk ve Margin Ayarları",
      type: TaskType.work,
      dueDate: DateTime.now().add(const Duration(days: 3)),
    ),
  ];

  final List<Task> _completedTasks = [
    Task(
      title: "Eski Görev 1",
      type: TaskType.personal,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      isCompleted: true,
    ),
    Task(
      title: "Eski Görev 2",
      type: TaskType.personal,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      isCompleted: true,
    ),
  ];

  void _addNewTask(Task newTask) {
    setState(() {
      _tasks.add(newTask);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor:
            themeProvider.isDarkMode
                ? Colors.grey[900]
                : HexColor(backgroundColor),
        body: Column(
          children: [
            // HEADER
            Stack(
              children: [
                Container(
                  width: deviceWidth,
                  height: deviceHeight * 0.30,
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
                        DateFormat('dd MMMM yyyy').format(DateTime.now()),
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
                // Theme toggle butonu
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[800]
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
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
                      onPressed: themeProvider.toggleTheme,
                    ),
                  ),
                ),
              ],
            ),

            // Yapılacaklar
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
                        itemCount: _tasks.length,
                        itemBuilder: (ctx, i) {
                          final t = _tasks[i];
                          return Card(
                            elevation: 4,
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: t.isCompleted,
                                onChanged: (_) {
                                  setState(() {
                                    t.isCompleted = !t.isCompleted;
                                    if (t.isCompleted) {
                                      _completedTasks.add(t);
                                      _tasks.removeAt(i);
                                    }
                                  });
                                },
                              ),
                              title: Text(
                                t.title,
                                style: TextStyle(
                                  decoration:
                                      t.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                ),
                              ),
                              subtitle: Text(
                                '${t.type.name.toUpperCase()} - ${DateFormat('dd.MM.yyyy').format(t.dueDate)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() => _tasks.removeAt(i));
                                },
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

            // Tamamlananlar
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
                        itemCount: _completedTasks.length,
                        itemBuilder: (ctx, i) {
                          final t = _completedTasks[i];
                          return Card(
                            elevation: 2,
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.check_circle,
                                size: 40,
                                color: Colors.green,
                              ),
                              title: Text(
                                t.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              subtitle: Text(
                                '${t.type.name.toUpperCase()} - ${DateFormat('dd.MM.yyyy').format(t.dueDate)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() => _completedTasks.removeAt(i));
                                },
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
          ],
        ),

        // Yeni görev ekle butonu
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => AddTaskScreen(onTaskAdded: _addNewTask),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
