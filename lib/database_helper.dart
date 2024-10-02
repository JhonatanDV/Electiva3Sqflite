import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'recipes.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        ingredients TEXT,
        instructions TEXT,
        category TEXT
      )
    ''');
  }

  Future<int> insertRecipe(Map<String, dynamic> recipe) async {
    final db = await database;
    return await db.insert('recipes', recipe);
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await database;
    return await db.query('recipes');
  }

  Future<int> updateRecipe(Map<String, dynamic> recipe) async {
    final db = await database;
    return await db.update(
      'recipes',
      recipe,
      where: 'id = ?',
      whereArgs: [recipe['id']],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await database;
    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
