// lib/providers/auth_provider.dart

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/db_helper.dart';

class AuthProvider extends ChangeNotifier {
  String? _username;
  int? _userId;
  DateTime? _lastActivityTime;
  static const _sessionTimeout = Duration(hours: 24); // 24 saat oturum süresi

  bool get isLoggedIn => _username != null && _isSessionValid();
  String? get username => _username;
  int? get userId => _userId;

  // Şifreyi hash'le
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Oturum geçerli mi kontrol et
  bool _isSessionValid() {
    if (_lastActivityTime == null) return false;
    return DateTime.now().difference(_lastActivityTime!) < _sessionTimeout;
  }

  // Son aktivite zamanını güncelle
  void _updateLastActivity() {
    _lastActivityTime = DateTime.now();
    _saveSession();
  }

  // Oturum bilgilerini yükle
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('username');
      final savedUserId = prefs.getInt('userId');
      final savedLastActivity = prefs.getInt('lastActivity');

      if (savedUsername != null &&
          savedUserId != null &&
          savedLastActivity != null) {
        _username = savedUsername;
        _userId = savedUserId;
        _lastActivityTime = DateTime.fromMillisecondsSinceEpoch(
          savedLastActivity,
        );

        // Oturum süresi dolmuşsa çıkış yap
        if (!_isSessionValid()) {
          await logout();
          return;
        }

        _updateLastActivity(); // Oturum geçerliyse son aktivite zamanını güncelle
        notifyListeners();
      }
    } catch (e) {
      print('Error loading session: $e');
    }
  }

  // Oturum bilgilerini kaydet
  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_username != null && _userId != null && _lastActivityTime != null) {
        await prefs.setString('username', _username!);
        await prefs.setInt('userId', _userId!);
        await prefs.setInt(
          'lastActivity',
          _lastActivityTime!.millisecondsSinceEpoch,
        );
      } else {
        await prefs.remove('username');
        await prefs.remove('userId');
        await prefs.remove('lastActivity');
      }
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  /// Kullanıcı girişi: veritabanından kullanıcıyı sorgular, şifreyi kontrol eder
  Future<bool> login(String user, String pass) async {
    try {
      print('Login attempt for user: $user'); // Debug log

      // Veritabanı bağlantısını kontrol et
      final db = await DBHelper.instance.database;
      print('Database connection successful'); // Debug log

      final row = await DBHelper.instance.queryUser(user);
      print('Database query result: $row'); // Debug log

      if (row == null) {
        print('User not found in database'); // Debug log
        return false;
      }

      // Şifre kontrolü
      final hashedPassword = _hashPassword(pass);
      if (row['password'] == hashedPassword) {
        print('Password match successful'); // Debug log
        _username = user;
        _userId = row['id'] as int;
        _lastActivityTime = DateTime.now();
        await _saveSession(); // Oturum bilgilerini kaydet
        notifyListeners();
        print('Login successful for user: $user'); // Debug log
        return true;
      } else {
        print('Password mismatch'); // Debug log
        return false;
      }
    } catch (e) {
      print('Login error: $e'); // Debug log
      return false;
    }
  }

  /// Yeni kullanıcı kaydı: veritabanına ekler, benzersiz kullanıcı adı kısıtlaması otomatik
  Future<bool> register(String user, String pass) async {
    try {
      print('Register attempt for user: $user'); // Debug log

      // Veritabanı bağlantısını kontrol et
      final db = await DBHelper.instance.database;
      print('Database connection successful'); // Debug log

      // Önce kullanıcının var olup olmadığını kontrol et
      final existingUser = await DBHelper.instance.queryUser(user);
      if (existingUser != null) {
        print('User already exists'); // Debug log
        return false;
      }

      // Şifreyi hash'le
      final hashedPassword = _hashPassword(pass);
      final row = <String, dynamic>{
        'username': user,
        'password': hashedPassword,
      };

      final id = await DBHelper.instance.insertUser(row);
      print('User registered with ID: $id'); // Debug log

      _username = user;
      _userId = id;
      _lastActivityTime = DateTime.now();
      await _saveSession(); // Oturum bilgilerini kaydet
      notifyListeners();
      return true;
    } catch (e) {
      print('Register error: $e'); // Debug log
      return false;
    }
  }

  /// Çıkış yap: oturumu sıfırlar
  Future<void> logout() async {
    _username = null;
    _userId = null;
    _lastActivityTime = null;
    await _saveSession(); // Oturum bilgilerini temizle
    notifyListeners();
  }

  /// Oturum durumunu kontrol et ve gerekirse çıkış yap
  Future<void> checkSession() async {
    if (!_isSessionValid()) {
      await logout();
    } else {
      _updateLastActivity();
    }
  }
}
