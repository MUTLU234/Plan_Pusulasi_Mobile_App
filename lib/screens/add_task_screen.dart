// lib/screens/add_task_screen.dart

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

class AddTaskScreen extends StatefulWidget {
  final void Function(Task) onTaskAdded;
  const AddTaskScreen({Key? key, required this.onTaskAdded}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  TaskType? _selectedType;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tarih seçmelisiniz')));
        return;
      }
      final newTask = Task(
        title: _taskController.text.trim(),
        type: _selectedType!,
        dueDate: _selectedDate!,
      );
      widget.onTaskAdded(newTask);
      Navigator.of(context).pop();
    }
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
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.deepPurple,
        title: const Text('Yeni Görev Ekle'),
        centerTitle: true,
      ),
      // Kaydırılabilir + tam ekran yükseklik
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
          ),
          child: IntrinsicHeight(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Görev Başlığı
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
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Lütfen bir görev başlığı girin';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Görev Tipi Seçimi
                      DropdownButtonFormField<TaskType>(
                        decoration: InputDecoration(
                          labelText: 'Görev Tipi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor:
                              themeProvider.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                        ),
                        items:
                            TaskType.values
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.name.toUpperCase()),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => _selectedType = val),
                        validator:
                            (val) =>
                                val == null
                                    ? 'Lütfen bir görev tipi seçin'
                                    : null,
                      ),

                      const SizedBox(height: 20),

                      // Tarih Seçimi
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Bitiş Tarihi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor:
                                themeProvider.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.white,
                          ),
                          child: Text(
                            _selectedDate == null
                                ? 'Tarih seçin'
                                : DateFormat(
                                  'dd.MM.yyyy',
                                ).format(_selectedDate!),
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Kaydet Butonu
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
                          'Görevi Kaydet',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
