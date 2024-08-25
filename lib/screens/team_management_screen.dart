import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/database_helper.dart';

class TeamManagementScreen extends StatefulWidget {
  @override
  _TeamManagementScreenState createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  List<Player> players = [];
  final DatabaseHelper dbHelper = DatabaseHelper();

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

  void _addPlayer() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController playerController = TextEditingController();
        return AlertDialog(
          title: Text('Add New Player'),
          content: TextField(
            controller: playerController,
            decoration: InputDecoration(hintText: 'Enter player name'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Add'),
              onPressed: () async {
                Player newPlayer = Player(name: playerController.text);
                await dbHelper.insertPlayer(newPlayer);
                _loadPlayers(); // Reload the player list
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removePlayer(int id) async {
    await dbHelper.deletePlayer(id);
    _loadPlayers(); // Reload the player list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(players[index].name),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removePlayer(players[index].id!),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addPlayer,
              child: Text('Add Player'),
            ),
          ],
        ),
      ),
    );
  }
}
