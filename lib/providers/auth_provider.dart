// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';

import '../helpers/db_helper.dart';

class AuthProvider extends ChangeNotifier {
  String? _username;
  bool get isLoggedIn => _username != null;
  String? get username => _username;

  /// Kullanıcı girişi: veritabanından kullanıcıyı sorgular, şifreyi kontrol eder
  Future<bool> login(String user, String pass) async {
    try {
      final row = await DBHelper.instance.queryUser(user);
      if (row != null && row['password'] == pass) {
        _username = user;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Hata yönetimi (isteğe bağlı: loglama, kullanıcıya bildirim vb.)
    }
    return false;
  }

  /// Yeni kullanıcı kaydı: veritabanına ekler, benzersiz kullanıcı adı kısıtlaması otomatik
  Future<bool> register(String user, String pass) async {
    try {
      final row = <String, dynamic>{'username': user, 'password': pass};
      await DBHelper.instance.insertUser(row);
      _username = user;
      notifyListeners();
      return true;
    } catch (e) {
      // Örneğin UNIQUE constraint ihlali: kullanıcı zaten kayıtlı
    }
    return false;
  }

  /// Çıkış yap: oturumu sıfırlar
  void logout() {
    _username = null;
    notifyListeners();
  }
}
