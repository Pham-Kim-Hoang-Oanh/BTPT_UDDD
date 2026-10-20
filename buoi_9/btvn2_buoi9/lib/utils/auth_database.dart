import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AuthDatabase {
  AuthDatabase._init();

  static final AuthDatabase instance = AuthDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'auth.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<bool> register(String email, String password) async {
    final db = await database;

    final existingUsers = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUsers.isNotEmpty) {
      return false;
    }

    await db.insert(
      'users',
      {
        'email': email,
        'password': password,
      },
    );

    return true;
  }

  Future<bool> login(String email, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return result.isNotEmpty;
  }
}