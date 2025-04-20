import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/screens/add_task_screen.dart';

void main() {
  runApp(const MyApp());
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: HexColor(backgroundColor),
        body: Column(
          children: [
            // Header
            Container(
              width: deviceWidth,
              height: deviceHeight / 3,
              decoration: BoxDecoration(
                color: Colors.purple,
                image: const DecorationImage(
                  image: AssetImage("lib/assets/images/header.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "24 Mart 2025",
                    style: TextStyle(
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
                              color: Colors.grey[200],
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
                                      value:
                                          widget
                                              .completedTasks[index]
                                              .isCompleted,
                                      onChanged: (val) {
                                        setState(() {
                                          widget
                                              .completedTasks[index]
                                              .isCompleted = val!;
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
                  backgroundColor: Colors.purple,
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
