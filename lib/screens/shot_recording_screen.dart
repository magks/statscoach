import 'package:flutter/material.dart';
import '../models/shot.dart';
import '../services/database_helper.dart';
import '../models/player.dart';

class ShotRecordingScreen extends StatefulWidget {
  @override
  _ShotRecordingScreenState createState() => _ShotRecordingScreenState();
}

class _ShotRecordingScreenState extends State<ShotRecordingScreen> {
  String? _selectedPlayer;
  String? _shotType;
  bool _wasBlocked = false;
  bool _involvedDribble = false;
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    List<Player> playerList = await dbHelper.getPlayers();
    setState(() {
      players = playerList;
    });
  }

  void _recordShot(Offset location) async {
    if (_selectedPlayer != null && _shotType != null) {
      Player player = players.firstWhere((player) => player.name == _selectedPlayer);

      Shot newShot = Shot(
        playerId: player.id!,
        shotType: _shotType!,
        wasBlocked: _wasBlocked,
        involvedDribble: _involvedDribble,
        xLocation: location.dx,
        yLocation: location.dy,
        timestamp: DateTime.now(),
      );

      await dbHelper.insertShot(newShot);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shot recorded for $_selectedPlayer')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a player and shot type')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Shot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              hint: Text('Select Player'),
              value: _selectedPlayer,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPlayer = newValue;
                });
              },
              items: players.map((Player player) {
                return DropdownMenuItem<String>(
                  value: player.name,
                  child: Text(player.name),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              hint: Text('Select Shot Type'),
              value: _shotType,
              onChanged: (String? newValue) {
                setState(() {
                  _shotType = newValue;
                });
              },
              items: <String>['2pt', '3pt', 'Free-throw'].map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            CheckboxListTile(
              title: Text('Was Blocked'),
              value: _wasBlocked,
              onChanged: (bool? value) {
                setState(() {
                  _wasBlocked = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Involved Dribble'),
              value: _involvedDribble,
              onChanged: (bool? value) {
                setState(() {
                  _involvedDribble = value!;
                });
              },
            ),
            Expanded(
              child: GestureDetector(
                onTapDown: (TapDownDetails details) {
                  _recordShot(details.localPosition);
                },
                child: Container(
                  color: Colors.orange[100],
                  child: Center(child: Text('Tap to record shot location')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

