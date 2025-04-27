import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Function(String) onTaskAdded;

  const AddTaskScreen({super.key, required this.onTaskAdded});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      print('Görev formu doğrulandı: ${_taskController.text}');
      widget.onTaskAdded(_taskController.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode
              ? Colors.grey[900]
              : HexColor(backgroundColor),
      appBar: AppBar(
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.deepPurple,
        title: const Text('Yeni Görev Ekle'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _taskController,
                decoration: InputDecoration(
                  hintText: 'Görev başlığını girin',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor:
                      themeProvider.isDarkMode
                          ? Colors.grey[800]
                          : Colors.white,
                  hintStyle: TextStyle(
                    color:
                        themeProvider.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                  ),
                ),
                style: TextStyle(
                  fontSize: 18,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir görev başlığı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      themeProvider.isDarkMode
                          ? Colors.deepPurple[800]
                          : Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Görevi Ekle',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
