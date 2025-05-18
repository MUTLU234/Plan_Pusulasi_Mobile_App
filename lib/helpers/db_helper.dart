// lib/helpers/db_helper.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _dbName = 'app_db.db';
  static const _dbVersion = 1;
  static const userTable = 'users';

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
    return _database!;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $userTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(userTable, row);
  }

  Future<Map<String, dynamic>?> queryUser(String username) async {
    final db = await database;
    final result = await db.query(
      userTable,
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(userTable, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(userTable, where: 'id = ?', whereArgs: [id]);
  }
}
