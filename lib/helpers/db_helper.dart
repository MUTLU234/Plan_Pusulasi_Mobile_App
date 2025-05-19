// lib/helpers/db_helper.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _dbName = 'app_db.db';
  // Bump this whenever you change the schema
  static const _dbVersion = 5;

  // Table names
  static const String userTable = 'users';
  static const String taskTable = 'tasks';
  static const String gameScoreTable = 'game_scores';

  // Make this a singleton class
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  // Veritabanını silme metodu
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

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

    // 2) Tasks table with user_id foreign key and soft delete
    await db.execute('''
      CREATE TABLE $taskTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        due_date INTEGER NOT NULL,
        is_completed INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $userTable (id) ON DELETE CASCADE
      )
    ''');

    // 3) Game scores table
    await db.execute('''
      CREATE TABLE $gameScoreTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        game_name TEXT NOT NULL,
        score INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $userTable (id) ON DELETE CASCADE
      )
    ''');

    // 4) Indexes for performance
    await db.execute('CREATE INDEX idx_tasks_user_id ON $taskTable(user_id)');
    await db.execute('CREATE INDEX idx_tasks_due_date ON $taskTable(due_date)');
    await db.execute('CREATE INDEX idx_tasks_type ON $taskTable(type)');
    await db.execute(
      'CREATE INDEX idx_tasks_is_deleted ON $taskTable(is_deleted)',
    );
    await db.execute(
      'CREATE INDEX idx_game_scores_user_id ON $gameScoreTable(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_game_scores_game_name ON $gameScoreTable(game_name)',
    );
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

    if (oldVersion < 3) {
      // Add user_id column and foreign key
      await db.execute(
        'ALTER TABLE $taskTable ADD COLUMN user_id INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute('CREATE INDEX idx_tasks_user_id ON $taskTable(user_id)');
    }

    if (oldVersion < 4) {
      // Add soft delete and timestamp columns
      await db.execute(
        'ALTER TABLE $taskTable ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $taskTable ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $taskTable ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'CREATE INDEX idx_tasks_is_deleted ON $taskTable(is_deleted)',
      );
    }

    if (oldVersion < 5) {
      // Add game scores table
      await db.execute('''
        CREATE TABLE $gameScoreTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          game_name TEXT NOT NULL,
          score INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES $userTable (id) ON DELETE CASCADE
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_game_scores_user_id ON $gameScoreTable(user_id)',
      );
      await db.execute(
        'CREATE INDEX idx_game_scores_game_name ON $gameScoreTable(game_name)',
      );
    }
  }

  /* ===== USER CRUD ===== */

  Future<int> insertUser(Map<String, dynamic> row) async {
    try {
      print('Inserting user: ${row['username']}'); // Debug log
      final db = await database;
      final id = await db.insert(userTable, row);
      print('User inserted with ID: $id'); // Debug log
      return id;
    } catch (e) {
      print('Error inserting user: $e'); // Debug log
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> queryUser(String username) async {
    try {
      print('Querying user: $username'); // Debug log
      final db = await database;
      final result = await db.query(
        userTable,
        where: 'username = ?',
        whereArgs: [username],
      );
      print('Query result: $result'); // Debug log
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error querying user: $e'); // Debug log
      rethrow;
    }
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
    final now = DateTime.now().millisecondsSinceEpoch;
    row['created_at'] = now;
    row['updated_at'] = now;
    return await db.insert(taskTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllTasks(int userId) async {
    final db = await database;
    return await db.query(
      taskTable,
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
    );
  }

  Future<int> updateTask(int id, Map<String, dynamic> row) async {
    final db = await database;
    row['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update(taskTable, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> softDeleteTask(int id) async {
    final db = await database;
    return await db.update(
      taskTable,
      {'is_deleted': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hardDeleteTask(int id) async {
    final db = await database;
    return await db.delete(taskTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryTasksByDate(
    int userId,
    int dateEpoch,
  ) async {
    final db = await database;
    return await db.query(
      taskTable,
      where: 'user_id = ? AND due_date = ? AND is_deleted = 0',
      whereArgs: [userId, dateEpoch],
    );
  }

  /* ===== GAME SCORES ===== */

  Future<int> insertGameScore(int userId, String gameName, int score) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.insert(gameScoreTable, {
      'user_id': userId,
      'game_name': gameName,
      'score': score,
      'created_at': now,
    });
  }

  Future<int?> getHighScore(int userId, String gameName) async {
    final db = await database;
    final result = await db.query(
      gameScoreTable,
      where: 'user_id = ? AND game_name = ?',
      whereArgs: [userId, gameName],
      orderBy: 'score DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first['score'] as int : null;
  }

  Future<bool> updateHighScore(
    int userId,
    String gameName,
    int newScore,
  ) async {
    final currentHighScore = await getHighScore(userId, gameName);
    if (currentHighScore == null || newScore > currentHighScore) {
      await insertGameScore(userId, gameName, newScore);
      return true;
    }
    return false;
  }
}
