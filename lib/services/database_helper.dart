import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

import 'package:stats_coach/models/player.dart';
import 'package:stats_coach/models/shot.dart';
import 'package:stats_coach/models/training_set.dart';

class DatabaseHelper {
  static final _databaseName = "AppDatabase.db";
  static final _databaseVersion = 1;

  static final tablePlayers = 'players';
  static final tableShots = 'shots';
  static final tableTeams = 'teams';
  static final tablePositions = 'positions';
  static final tableGames = 'games';
  static final tableTrainingSessions = 'training_sessions';
  static final tableTrainingCamps = 'training_camps';
  static final tableCoaches = 'coaches';
  static final tableSeasons = 'seasons';
  static final tableSessions = 'sessions';
  static final tableSets = 'sets';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<void> clearDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    await deleteDatabase(path);
    _database = null; // Reset the _database variable to force reinitialization
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablePlayers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL,
        jerseyNumber INTEGER,
        position VARCHAR(255),
        height REAL,
        weight REAL,
        age INTEGER,
        teamId INTEGER,
        photo VARCHAR(255),
        FOREIGN KEY (teamId) REFERENCES $tableTeams(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableShots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playerId INTEGER NOT NULL,
        timestamp VARCHAR(255) NOT NULL,
        gameId INTEGER,
        sessionId INTEGER,
        category VARCHAR(60), -- e.g., Two Ball, Three Ball, Free Throw
        drill VARCHAR(150), -- e.g., Catch & Shoot, Pick & Pop
        position VARCHAR(30), -- e.g., Guard, Wing, Big
        courtLocation VARCHAR(60), -- e.g., Right Wing, Left Corner
        shotType VARCHAR(30), -- e.g., 2pt, 3pt, Free Throw        
        xLocation REAL,
        yLocation REAL,
        wasBlocked INTEGER,
        involvedDribble INTEGER,
        success INTEGER,
        FOREIGN KEY (playerId) REFERENCES $tablePlayers(id) ON DELETE CASCADE,
        FOREIGN KEY (gameId) REFERENCES $tableGames(id) ON DELETE SET NULL,
        FOREIGN KEY (sessionId) REFERENCES $tableTrainingSessions(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTeams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePositions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableGames (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        homeTeamName VARCHAR(255),
        awayTeamName VARCHAR(255),
        date VARCHAR(255)
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTrainingSessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        campId INTEGER,
        date VARCHAR(255),
        FOREIGN KEY (campId) REFERENCES $tableTrainingCamps(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTrainingCamps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255),
        startDate VARCHAR(255),
        endDate VARCHAR(255)
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCoaches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255),
        teamId INTEGER,
        FOREIGN KEY (teamId) REFERENCES $tableTeams(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSeasons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255),
        startDate VARCHAR(255),
        endDate VARCHAR(255)
      )
    ''');

      await db.execute('''
        CREATE TABLE $tableSessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          playerId INTEGER NOT NULL,
          startTime TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE $tableSets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sessionId INTEGER NOT NULL,
          madeShots INTEGER NOT NULL,
          missedShots INTEGER NOT NULL,
          FOREIGN KEY (sessionId) REFERENCES sessions (id) ON DELETE CASCADE
        )
      ''');

    await db.execute('''
    CREATE TABLE TrainingSet (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      campId INTEGER,
      playerId INTEGER,
      playerName VARCHAR(255),
      isDummyName INTEGER DEFAULT 0,
      startTimestamp VARCHAR(255),
      endTimestamp VARCHAR(255),
      position VARCHAR(255),
      shotCategory VARCHAR(255),
      drill VARCHAR(255),
      location VARCHAR(255),
      madeShots INTEGER,
      totalShots INTEGER
    );
  ''');

  }

  Future<void> addSamplePlayers() async {
    final db = await database;

    // List of real basketball player names
    List<String> playerNames = [
      'LeBron James',
      'Stephen Curry',
      'Kevin Durant',
      'Giannis Antetokounmpo',
      'James Harden',
      'Kawhi Leonard',
      'Anthony Davis',
      'Luka Dončić',
      'Nikola Jokić',
      'Damian Lillard',
      'Joel Embiid',
      'Chris Paul',
      'Jimmy Butler',
      'Jayson Tatum',
      'Devin Booker',
      'Donovan Mitchell',
      'Zion Williamson',
      'Trae Young',
      'Bradley Beal',
      'Paul George',
      'Rudy Gobert',
      'Kyrie Irving',
      'Klay Thompson',
      'Russell Westbrook',
      'Jrue Holiday'
    ];

    // Random number generator
    final random = Random();

    // Loop through each name and create a player
    for (String name in playerNames) {
      Player player = Player(
        name: name,
        jerseyNumber: random.nextInt(99) + 1, // Random jersey number between 1 and 99
        position: ['Guard', 'Forward', 'Center'][random.nextInt(3)], // Random position
        height: 180 + random.nextDouble() * 30, // Random height between 180 cm and 210 cm
        weight: 80 + random.nextDouble() * 40, // Random weight between 80 kg and 120 kg
        age: 19 + random.nextInt(20), // Random age between 19 and 39
        teamId: null, // Assuming no team is assigned, or you can set it as per your logic
        photo: null, // Assuming no photo, or you can add random images
      );

      await db.insert(
        'players',
        player.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print('25 sample players added to the database.');
  }

  Future<void> recordTrainingSets(List<TrainingSet> sets) async {
    final db = await instance.database;
    Batch batch = db.batch();

    debugPrint('recording shots: $sets');
    for (TrainingSet set in sets) {
      debugPrint('${set.toMap()}');
      batch.insert('TrainingSet', set.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> recordTrainingSet(TrainingSet set) async {
    final db = await instance.database;
    Batch batch = db.batch();
    debugPrint('recording shots: $set');
    debugPrint('${set.toMap()}');
    batch.insert('TrainingSet', set.toMap());
    await batch.commit(noResult: true);
  }



  Future<int> insertShot(Shot shot) async {
    final db = await instance.database;
    return await db.insert('shots', shot.toMap());
  }

  Future<List<Map<String, dynamic>>> getShots() async {
    final db = await instance.database;
    return await db.query('shots');
  }

  Future<void> recordSet(List<Shot> shots) async {
    final db = await instance.database;
    Batch batch = db.batch();

    debugPrint('recording shots: ${shots}');
    for (Shot shot in shots) {
      debugPrint('${shot.toMap()}');
      batch.insert('shots', shot.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<int> deleteAllShots() async {
    final db = await instance.database;
    return await db.delete('shots');
  }

  getPlayers() {}
}


/*
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
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < newVersion) {
          // Handle migrations or drop and recreate tables
          db.execute('DROP TABLE IF EXISTS shots');
          db.execute('DROP TABLE IF EXISTS players');
          _onCreate(db, newVersion);
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE players(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255),
        position VARCHAR(255)
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
        shotType VARCHAR(255),
        wasBlocked INTEGER,
        involvedDribble INTEGER,
        xLocation REAL,
        yLocation REAL,
        timestamp VARCHAR(255),
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
*/