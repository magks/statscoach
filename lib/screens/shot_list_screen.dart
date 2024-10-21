import 'package:flutter/material.dart';
import '../models/shot.dart';  // Import the updated Shot model
import '../services/database_helper.dart'; // Import the DatabaseHelper to access data

class ShotListScreen extends StatefulWidget {
  @override
  _ShotListScreenState createState() => _ShotListScreenState();
}

class _ShotListScreenState extends State<ShotListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Shot> shots = [];

  @override
  void initState() {
    super.initState();
    _loadShots();
  }

  Future<void> _loadShots() async {
    final db = await _dbHelper.database; // First, await the database instance
    final List<Map<String, dynamic>> shotMaps = await db.query('shots'); // Then perform the query

    debugPrint(
        'number of shots loaded: $shotMaps'
    );
    setState(() {
      shots = shotMaps.map((map) => Shot.fromMap(map)).toList();
      debugPrint(
        'number of shots loaded: $shots'
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shot List'),
      ),
      body: shots.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: shots.length,
              itemBuilder: (context, index) {
                final shot = shots[index];
                return ListTile(
                  title: Text('Shot ID: ${shot.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Player ID: ${shot.playerId}'),
                      Text('Shot Type: ${shot.shotType ?? 'Unknown'}'),
                      Text('Blocked: ${shot.wasBlocked == true ? "Yes" : "No"}'),
                      Text('Involved Dribble: ${shot.involvedDribble == true ? "Yes" : "No"}'),
                      Text('Success: ${shot.success == true ? "Yes" : "No"}'),
                      Text('Timestamp: ${shot.timestamp.toIso8601String()}'),
                    ],
                  ),
                  onTap: () {
                    // Handle tap event if needed, e.g., navigate to shot details screen
                  },
                );
              },
            ),
    );
  }
}
