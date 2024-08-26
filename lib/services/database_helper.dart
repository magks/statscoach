import 'package:csv/csv.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/player.dart';
import '../models/shot.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Convenience function to clear the database
  Future<void> clearDatabase() async {
    Database db = await database;
    await db.execute('DROP TABLE IF EXISTS shots');
    await db.execute('DROP TABLE IF EXISTS players');
    await _onCreate(db, 1); // Recreate the tables
  }

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
      /*onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < newVersion) {
          // Handle migrations or drop and recreate tables
          db.execute('DROP TABLE IF EXISTS shots');
          db.execute('DROP TABLE IF EXISTS players');
          _onCreate(db, newVersion);
        }
      },*/
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

    // Create the shots table
    await createShotTable(db);
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

  Future<void> createShotTable(Database db) async {
    await db.execute('''
      CREATE TABLE shots(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playerId INTEGER,
        shotType TEXT,
        wasBlocked INTEGER,
        involvedDribble INTEGER,
        xLocation REAL,
        yLocation REAL,
        timestamp TEXT,
        FOREIGN KEY (playerId) REFERENCES players(id)
      )
    ''');
  }

  Future<int> insertShot(Shot shot) async {
    Database db = await database;
    return await db.insert('shots', shot.toMap());
  }

  Future<List<Shot>> getShots() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('shots');
    return List.generate(maps.length, (i) {
      return Shot(
        id: maps[i]['id'],
        playerId: maps[i]['playerId'],
        shotType: maps[i]['shotType'],
        wasBlocked: maps[i]['wasBlocked'] == 1,
        involvedDribble: maps[i]['involvedDribble'] == 1,
        xLocation: maps[i]['xLocation'],
        yLocation: maps[i]['yLocation'],
        timestamp: DateTime.parse(maps[i]['timestamp']),
      );
    });
  }

  Future<int> deleteShot(int id) async {
    Database db = await database;
    return await db.delete('shots', where: 'id = ?', whereArgs: [id]);
  }
  Future<String> exportShotsToCSV() async {
    List<Shot> shots = await getShots();
    List<List<String>> csvData = [
      // Headers
      ['Player Name', 'Shot Type', 'Blocked', 'Dribble', 'X Location', 'Y Location', 'Timestamp']
    ];

    for (Shot shot in shots) {
      String playerName = (await getPlayerById(shot.playerId))?.name ?? 'Unknown';
      csvData.add([
        playerName,
        shot.shotType,
        shot.wasBlocked ? 'Yes' : 'No',
        shot.involvedDribble ? 'Yes' : 'No',
        shot.xLocation.toString(),
        shot.yLocation.toString(),
        shot.timestamp.toIso8601String(),
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);

    final directory = await getApplicationDocumentsDirectory();
    //final path = '/data/data/com.example.example.stats_coach/shots_data1.csv';
    final path = '${directory.path}/shots_data_snapshot.csv';
    final file = File(path);

    await file.writeAsString(csv);

    return path;
  }

  Future<Player?> getPlayerById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('players', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Player(
        id: maps.first['id'],
        name: maps.first['name'],
        position: maps.first['position'],
      );
    }
    return null;
  }
}

