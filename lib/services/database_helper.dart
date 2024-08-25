import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/player.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'coach_stats.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE players(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        position TEXT
      )
    ''');
  }

  Future<int> insertPlayer(Player player) async {
    Database db = await database;
    return await db.insert('players', player.toMap());
  }

  Future<List<Player>> getPlayers() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('players');
    return List.generate(maps.length, (i) {
      return Player(
        id: maps[i]['id'],
        name: maps[i]['name'],
        position: maps[i]['position'],
      );
    });
  }

  Future<int> deletePlayer(int id) async {
    Database db = await database;
    return await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }
}

