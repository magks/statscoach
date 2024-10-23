import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:stats_coach/blocs/session_bloc.dart';
import 'package:stats_coach/models/player.dart';
import 'package:stats_coach/services/database_helper.dart';
import 'package:stats_coach/viewmodels/training_set_view_model.dart';

class SetInfoForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TrainingSetViewModel currentSet;
  final Function updateTrainingSet;
  final Function dedupPlayerNames;
  final ExpansionTileController expansionTileController;
  List<Player> players = [];
  SetInfoForm({
    required this.formKey,
    required this.currentSet,
    required this.updateTrainingSet,
    required this.expansionTileController,
    required this.dedupPlayerNames,
  });

  @override
  _SetInfoFormState createState() => _SetInfoFormState();
}

class _SetInfoFormState extends State<SetInfoForm> {
  // Controllers and variables
  late TextEditingController _typeAheadController;
  Player? _selectedPlayer;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;


  @override
  void initState() {
    super.initState();
    _typeAheadController = TextEditingController(text: widget.currentSet.playerName ?? '');
    _loadPlayers();
    _typeAheadController.addListener(() {
      if (_typeAheadController.text != _selectedPlayer?.name) {
        setState(() {
          _selectedPlayer = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _typeAheadController.dispose();
    super.dispose();
  }

  void _loadPlayers() async {
    final db = await _dbHelper.database;
    widget.players = await db.query('players').then((playerMaps) =>
        playerMaps.map((map) => Player.fromMap(map)).toList()
    );
  }



  Future<List<Player>> _getSuggestions_delete(String pattern) async {
    // Implement your logic to fetch suggestions
    // For example:
    // return await fetchPlayerSuggestions(pattern);
    return Future.value();
  }

  int _sortPlayers(Player a, Player b) {
    // Split the names into first and last name parts
    List<String> nameA = a.name.split(' ');
    List<String> nameB = b.name.split(' ');

    String lastNameA = nameA.last.toLowerCase();
    String lastNameB = nameB.last.toLowerCase();

    // Compare by last name
    int lastNameComparison = lastNameA.compareTo(lastNameB);

    if (lastNameComparison != 0) {
      return lastNameComparison; // Return comparison of last names
    } else {
      // If last names are the same, compare by first name
      String firstNameA = nameA.first.toLowerCase();
      String firstNameB = nameB.first.toLowerCase();
      return firstNameA
          .compareTo(firstNameB); // Return comparison of first names
    }
  }

  List<Player> _getSuggestions(String query) {
    if (query.isEmpty) {
      return widget.players;
    }

    String queryLower = query.toLowerCase();
    // Filter widget.player whose first or last name begins with the query
    List<Player> beginsWithPlayers = widget.players.where((player) {
      return player.name.toLowerCase().startsWith(queryLower) ||
          player.name.split(' ').last.toLowerCase().startsWith(queryLower);
    }).toList();

    // Get the rest of of the players
    var restPlayers = widget.players.toSet().difference(beginsWithPlayers.toSet());
    // Filter the rest of the players based on the query
    var containsPlayers = restPlayers.where((player) {
      return player.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Sort the filtered players by their last name, and tie-break by first name
    beginsWithPlayers.sort(_sortPlayers);
    containsPlayers.sort(_sortPlayers);

    return beginsWithPlayers; // + containsPlayers;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // TypeAheadField
          TypeAheadField<Player>(
            controller: _typeAheadController,
            builder: (context, controller, focusNode) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: "Search Player",
                  prefixIcon: Icon(Icons.search),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a player";
                  } else if (_selectedPlayer == null || _selectedPlayer!.name != value) {
                    return "Please select a valid player from the suggestions";
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUnfocus,
              );
            },
            suggestionsCallback: _getSuggestions,
            itemBuilder: (context, Player suggestion) {
              return ListTile(
                title: Text(suggestion.name),
              );
            },
            onSelected: (Player suggestion) {
              setState(() {
                debugPrint("${suggestion.name} selected with id ${suggestion.id}");
                _selectedPlayer = suggestion;
                _typeAheadController.text = suggestion.name;
                widget.updateTrainingSet(
                  playerId: suggestion.id,
                  playerName: suggestion.name,
                  playerDisplayName: suggestion.name,
                  isDummyName: false,
                );
                widget.dedupPlayerNames(suggestion.name, suggestion.id);

              });
            },
            emptyBuilder: (context) => const ListTile(
              title: Text('No players found'),
            ),
          ),
          // Position Dropdown
          DropdownButtonFormField<String>(
            value: widget.currentSet.position,
            hint: const Text(' Select Position'),
            onChanged: (String? newPosition) {
              widget.updateTrainingSet(position: newPosition);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please select a position";
              }
              return null;
            },
            items: <String>['Guard', 'Wing', 'Big'].map((String position) {
              return DropdownMenuItem<String>(
                value: position,
                child: Text(" $position"),
              );
            }).toList(),
          ),
          // Shot Category Dropdown
          DropdownButtonFormField<String>(
            value: widget.currentSet.shotCategory,
            hint: const Text(' Select Shot Category'),
            onChanged: (String? newCategory) {
              widget.updateTrainingSet(shotCategory: newCategory);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please select a shot category";
              }
              return null;
            },
            items: <String>['Two Ball', 'Three Ball', 'Free Throw'].map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(" $category"),
              );
            }).toList(),
          ),
          // Drill Dropdown
          DropdownButtonFormField<String>(
            value: widget.currentSet.drill,
            hint: const Text(' Select Drill'),
            onChanged: (String? newDrill) {
              widget.updateTrainingSet(drill: newDrill);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please select a drill";
              }
              return null;
            },
            items: _getDrillsForPositionAndCategory(
              widget.currentSet.position,
              widget.currentSet.shotCategory,
            ).map((String drill) {
              return DropdownMenuItem<String>(
                value: drill,
                child: Text(" $drill"),
              );
            }).toList(),
          ),
          // Location Dropdown
          DropdownButtonFormField<String>(
            value: widget.currentSet.location,
            hint: const Text(' Select Location'),
            onChanged: (String? newLocation) {
              widget.updateTrainingSet(location: newLocation);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please select a location";
              }
              return null;
            },
            items: _getLocationsForDrill(widget.currentSet.drill).map((String location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(" $location"),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Helper methods for getting drills and locations
  // These methods retrieve drills/locations based on position/category (placeholder implementation)
  List<String> _getDrillsForPositionAndCategory(
      String? position, String? category) {
    // Logic to fetch drills based on position and shot category
    return ['Drill 1', 'Drill 2', 'Drill 3'];
  }

  List<String> _getLocationsForDrill(String? drill) {
    // Logic to fetch locations based on the selected drill
    return ['Location 1', 'Location 2', 'Location 3'];
  }
}
