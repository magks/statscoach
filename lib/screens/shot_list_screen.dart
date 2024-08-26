import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/shot.dart';
import '../models/player.dart';

class ShotListScreen extends StatefulWidget {
  @override
  _ShotListScreenState createState() => _ShotListScreenState();
}

class _ShotListScreenState extends State<ShotListScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Shot> shots = [];
  Map<int, String> playerNames = {};

  @override
  void initState() {
    super.initState();
    _loadShots();
  }

  Future<void> _loadShots() async {
    List<Shot> shotList = await dbHelper.getShots();
    List<Player> playerList = await dbHelper.getPlayers();
    setState(() {
      shots = shotList;
      playerNames = {for (var player in playerList) player.id!: player.name};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recorded Shots'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: shots.isEmpty
            ? Center(child: Text('No shots recorded'))
            : ListView.builder(
                itemCount: shots.length,
                itemBuilder: (context, index) {
                  final shot = shots[index];
                  return ListTile(
                    title: Text('Player: ${playerNames[shot.playerId]}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shot Type: ${shot.shotType}'),
                        Text(
                            'Location: (${shot.xLocation.toStringAsFixed(2)}, ${shot.yLocation.toStringAsFixed(2)})'),
                        Text('Blocked: ${shot.wasBlocked ? "Yes" : "No"}'),
                        Text(
                            'Involved Dribble: ${shot.involvedDribble ? "Yes" : "No"}'),
                        Text('Time: ${shot.timestamp}'),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

