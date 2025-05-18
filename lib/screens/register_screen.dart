// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:plan_pusulasi/constants/color.dart';
import 'package:plan_pusulasi/main.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    final success = await context.read<AuthProvider>().register(
      _userCtrl.text.trim(),
      _passCtrl.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kayıt başarılı')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarısız, farklı bir kullanıcı adı deneyin'),
        ),
      );
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
        title: const Text('Kayıt Ol'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Kullanıcı Adı
                TextFormField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
                  validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null,
                ),
                const SizedBox(height: 12),

                // Şifre
                TextFormField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(labelText: 'Şifre'),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null,
                ),
                const SizedBox(height: 24),

                // Kayıt Butonu / Yükleniyor İndikatörü
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            themeProvider.isDarkMode
                                ? Colors.deepPurple[800]
                                : Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Kayıt Ol'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
