// lib/helpers/db_helper.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _dbName = 'app_db.db';
  // Bump this whenever you change the schema
  static const _dbVersion = 2;

  // Table names
  static const String userTable = 'users';
  static const String taskTable = 'tasks';

  // Make this a singleton class
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Get the default database location
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    // Open or create the database at the given path
    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  // Called only when creating the database for the first time
  Future _onCreate(Database db, int version) async {
    // 1) Users table
    await db.execute('''
      CREATE TABLE $userTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // 2) Tasks table
    await db.execute('''
      CREATE TABLE $taskTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        due_date INTEGER NOT NULL,
        is_completed INTEGER NOT NULL
      )
    ''');

    // 3) Optional indexes for performance
    await db.execute('CREATE INDEX idx_tasks_due_date ON $taskTable(due_date)');
    await db.execute('CREATE INDEX idx_tasks_type ON $taskTable(type)');
  }

  // Called when you bump _dbVersion to migrate existing databases
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the tasks table if it didn't exist
      await db.execute('''
        CREATE TABLE $taskTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          type TEXT NOT NULL,
          due_date INTEGER NOT NULL,
          is_completed INTEGER NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_tasks_due_date ON $taskTable(due_date)',
      );
      await db.execute('CREATE INDEX idx_tasks_type ON $taskTable(type)');
    }
    // Future migrations go here...
  }

  /* ===== USER CRUD ===== */

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

  /* ===== TASK CRUD ===== */

  Future<int> insertTask(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(taskTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllTasks() async {
    final db = await database;
    return await db.query(taskTable);
  }

  Future<int> updateTask(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(taskTable, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(taskTable, where: 'id = ?', whereArgs: [id]);
  }

  /// Returns all tasks whose `due_date` (in milliseconds since epoch) equals [dateEpoch].
  Future<List<Map<String, dynamic>>> queryTasksByDate(int dateEpoch) async {
    final db = await database;
    return await db.query(
      taskTable,
      where: 'due_date = ?',
      whereArgs: [dateEpoch],
    );
  }
}
