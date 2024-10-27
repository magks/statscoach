//import 'dart:ffi' as dart_ffi;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stats_coach/blocs/session_bloc.dart';
import 'package:stats_coach/blocs/session_events.dart';
import 'package:stats_coach/blocs/stats_bloc.dart';
import 'package:stats_coach/blocs/stats_events.dart';
import '../models/player.dart'; // Import the Player model
import '../services/database_helper.dart'; // Import the DatabaseHelper to access data

class TrainingManagementScreen extends StatefulWidget {
  @override
  _TrainingManagementScreenState createState() => _TrainingManagementScreenState();
}

class _TrainingManagementScreenState extends State<TrainingManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Player> players = [];
  final TextEditingController _playerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> playerMaps = await db.query('players');
    setState(() {
      players = playerMaps.map((map) => Player.fromMap(map)).toList();
    });
  }

  void _showAddPlayerModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            // Make sure the modal screen adjusts with the keyboard
            child: AddPlayerForm(onSubmit: (Player newPlayer) async {
              await _addPlayer(newPlayer);
            }),
          );
        });
  }

  Future<void> _addPlayer(Player player) async {
    if (player.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Player name cannot be empty')),
      );
      return;
    }

    final db = await _dbHelper.database;
    int playerId = await db.insert(
      'players',
      player.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Player added successfully')),
    );

    // Refresh the player list after adding
    _loadPlayers();

    context.read<StatsBloc>().add(AddNewPlayerToStats(player.copyWith(id: playerId)));
  }

  // todo don't reload from db, just update player list in place
  Future<void> _deletePlayer(Player player) async {
    final db = await _dbHelper.database;
    context.read<StatsBloc>().add(RemovePlayerFromStats(player));
    await db.delete('players', where: 'id = ?', whereArgs: [player.id!]);
    _loadPlayers();
  }

  Future<void> _updatePlayer(Player player) async {
    final db = await _dbHelper.database;
    await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );

    //if the player is part a training-session,
    //the update to her name should reflect in her current training-set
    if (context.mounted) {
      context.read<SessionBloc>().add(UpdatePlayerInSession(player));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Player updated successfully')),
    );

    _loadPlayers();
  }

  SnackBar getToastySnackBar(String msg) => SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    dismissDirection: DismissDirection.down,
    padding: EdgeInsets.zero,
    margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height*0.1
    ),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 1, milliseconds: 300),
    content: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Color(0xe8000000),
        ),
        child: Text(msg),
      ),
    ),
  );


  void _addPlayerToSession(Player player) {

    // Ensure that SessionBloc is accessible from this context
    context.read<SessionBloc>().add(SendPlayerToSession(player));
    context.read<SessionBloc>().add(DedupPlayerDisplayNames(player));
/*    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${player.name} added to session')),
    );*/
        ScaffoldMessenger.of(context).showSnackBar(
            getToastySnackBar('${player.name} added to session')

        );
  }

  void _showEditPlayerModal(Player player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: EditPlayerForm(
            player: player,
            onSubmit: (Player updatedPlayer) async {
              await _updatePlayer(updatedPlayer);
            },
          ),
        );
      },
    );
  }

  Widget _buildPlayerItem(Player player) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          player.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Position: ${player.position ?? 'Unknown'}'),
        onTap: () {
          _showEditPlayerModal(player);
        },
        trailing: Wrap(
          spacing: 8, // space between two icons
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.group_add),
              tooltip: 'Add to Session ',
              onPressed: () {
                _addPlayerToSession(player);
                //GoRouter.of(context).go('/training_session');
              },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              tooltip: 'Add to Session and Go to Training Session Screen',
              onPressed: () {
                _addPlayerToSession(player);
                GoRouter.of(context).go('/training_session');
              },
            ),
            IconButton(
              icon: Icon(Icons.bar_chart),
              tooltip: 'View Stats',
              onPressed: () {
                // View player's stats (placeholder)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Feature coming soon!')),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Delete Player',
              onPressed: () {
                _deletePlayer(player);
              },
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<SessionBloc>(context),
      child:
      Scaffold(
        appBar: AppBar(
          title: Text('Player Management'),
        ),
        body: Column(
          children: [
            Expanded(
              child: players.isEmpty
                  ? Center(child: Text('No players available'))
                  : Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return _buildPlayerItem(player);
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddPlayerModal(context),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }
}

class AddPlayerForm extends StatefulWidget {
  final Function(Player) onSubmit;

  AddPlayerForm({required this.onSubmit});

  @override
  _AddPlayerFormState createState() => _AddPlayerFormState();
}

class _AddPlayerFormState extends State<AddPlayerForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jerseyNumberController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the player\'s name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _jerseyNumberController,
              decoration: InputDecoration(labelText: 'Jersey Number'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _positionController,
              decoration: InputDecoration(labelText: 'Position'),
            ),
            TextFormField(
              controller: _heightController,
              decoration: InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final Player newPlayer = Player(
                    //id: DateTime.now().millisecondsSinceEpoch,
                    name: _nameController.text.trim(),
                    jerseyNumber: int.tryParse(_jerseyNumberController.text),
                    position: _positionController.text.trim(),
                    height: double.tryParse(_heightController.text),
                    weight: double.tryParse(_weightController.text),
                    age: int.tryParse(_ageController.text),
                  );

                  widget.onSubmit(newPlayer);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add Player'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jerseyNumberController.dispose();
    _positionController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}

class EditPlayerForm extends StatefulWidget {
  final Player player;
  final Function(Player) onSubmit;

  EditPlayerForm({required this.player, required this.onSubmit});

  @override
  _EditPlayerFormState createState() => _EditPlayerFormState();
}

class _EditPlayerFormState extends State<EditPlayerForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _jerseyNumberController;
  late TextEditingController _positionController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
    _jerseyNumberController = TextEditingController(
        text: widget.player.jerseyNumber?.toString() ?? '');
    _positionController =
        TextEditingController(text: widget.player.position ?? '');
    _heightController =
        TextEditingController(text: widget.player.height?.toString() ?? '');
    _weightController =
        TextEditingController(text: widget.player.weight?.toString() ?? '');
    _ageController =
        TextEditingController(text: widget.player.age?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        // Ensure content scrolls if necessary
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Player',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the player\'s name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _jerseyNumberController,
                decoration: InputDecoration(labelText: 'Jersey Number'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(labelText: 'Position'),
              ),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final Player updatedPlayer = Player(
                      id: widget.player.id,
                      name: _nameController.text.trim(),
                      jerseyNumber:
                      int.tryParse(_jerseyNumberController.text),
                      position: _positionController.text.trim(),
                      height: double.tryParse(_heightController.text),
                      weight: double.tryParse(_weightController.text),
                      age: int.tryParse(_ageController.text),
                    );

                    widget.onSubmit(updatedPlayer);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Update Player'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jerseyNumberController.dispose();
    _positionController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
