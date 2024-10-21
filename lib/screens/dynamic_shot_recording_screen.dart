import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stats_coach/blocs/session_bloc.dart';
import 'package:stats_coach/blocs/session_events.dart';
import 'package:stats_coach/blocs/session_state.dart';
import 'package:stats_coach/models/training_set.dart';
import 'package:stats_coach/viewmodels/training_set_view_model.dart';
import 'package:stats_coach/widgets/toasty_snack_bar.dart';
import '../models/player.dart';
import '../models/shot.dart';
import '../services/database_helper.dart';

class ShotRecordingScreenV3 extends StatefulWidget {
  final int tabIndex;
  TrainingSetViewModel trainingSet;

  ShotRecordingScreenV3({super.key, required this.tabIndex, required this.trainingSet});

  @override
  _ShotRecordingScreenV3State createState() => _ShotRecordingScreenV3State();
}

class _ShotRecordingScreenV3State extends State<ShotRecordingScreenV3> {
  int madeShots = 0;
  int totalShots = 0;
  final TextEditingController _madeController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final ExpansionTileController _setInfoExpansionTileController = ExpansionTileController();
  
  final GlobalKey<FormState> _setInfoFormKey = GlobalKey<FormState>(); // for set info
  final TextEditingController _typeAheadController = TextEditingController();
  Player? _selectedPlayer;
  
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Player> players = [];
  String? _selectedPlayerId;
  String? _selectedPosition;
  String? _selectedCategory;
  String? _selectedDrill;
  String? _selectedLocation;
  late TrainingSetViewModel _currentTrainingSet;

  static const Color _setInfoFormBorderColor = Colors.black87;
  static const double _collapsedSetInfoFormBorderRadius = 100;

  bool _isFormCollapsed = true;

  @override
  void initState() {
    super.initState();
    // Initialize the shots count with the existing training set data
    madeShots = widget.trainingSet.madeShots ?? 0;
    totalShots = widget.trainingSet.totalShots ?? 0;
    _typeAheadController.addListener(() {
/*      if (_typeAheadController.text != _selectedPlayer?.name) {
        setState(() {
          _selectedPlayer = null;
        });
      }*/
    });
    _loadPlayers();
    _updateShotCounterControllers();
  }

  @override
  void dispose() {
    _typeAheadController.dispose();
    _madeController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _updateShotCounterControllers() {
    _madeController.text = madeShots.toString();
    _totalController.text = totalShots.toString();
  }

  Future<void> _loadPlayers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> playerMaps = await db.query('players');
    var ps = playerMaps.map((map) => Player.fromMap(map)).toList();
    players = ps;
  }

  // Dispatch the updated session state when the user records a shot
  void _incrementShot(bool success) {
    setState(() {
      // Start time for set is when first shot is recorded.
      DateTime startTimestamp = (totalShots == 0)
          ? DateTime.now()
          : widget.trainingSet.startTimestamp ?? DateTime.now();

      totalShots += 1;
      if (success) {
        madeShots += 1;
      }
      _updateTrainingSet(
          madeShots: madeShots,
          totalShots: totalShots,
          startTimestamp: startTimestamp
      );
      _updateShotCounterControllers();
    });
  }

  // Dispatch the update when the user selects a player, position, or drill
  void _updateTrainingSet(
      {int? id,
        int? campId,
        int? playerId,
        String? playerName,
        bool? isDummyName,
        DateTime? startTimestamp,
        DateTime? endTimestamp,
        String? position,
        String? shotCategory,
        String? drill,
        String? location,
        int? madeShots,
        int? totalShots}) {

    setState(() {
      widget.trainingSet = widget.trainingSet.copyWith(
        id: id ?? widget.trainingSet.id,
        campId: campId ?? widget.trainingSet.campId,
        playerId: playerId ?? widget.trainingSet.playerId,
        playerName: playerName ?? widget.trainingSet.playerName,
        isDummyName: isDummyName ?? widget.trainingSet.isDummyName,
        startTimestamp: startTimestamp ?? widget.trainingSet.startTimestamp,
        endTimestamp: endTimestamp ?? widget.trainingSet.endTimestamp,
        position: position ?? widget.trainingSet.position,
        shotCategory: shotCategory ?? widget.trainingSet.shotCategory,
        drill: drill ?? widget.trainingSet.drill,
        location: location ?? widget.trainingSet.location,
        madeShots: madeShots ?? widget.trainingSet.madeShots,
        totalShots: totalShots ?? widget.trainingSet.totalShots,
      );
      // Send the updated training set to the SessionBloc
      context
          .read<SessionBloc>()
          .add(TrainingSetViewModelUpdated(widget.tabIndex, widget.trainingSet));
    });

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
      return players;
    }

    String queryLower = query.toLowerCase();
    // Filter players whose first or last name begins with the query
    List<Player> beginsWithPlayers = players.where((player) {
      return player.name.toLowerCase().startsWith(queryLower) ||
          player.name.split(' ').last.toLowerCase().startsWith(queryLower);
    }).toList();

    // Get the rest of of the players
    var restPlayers = players.toSet().difference(beginsWithPlayers.toSet());
    // Filter the rest of the players based on the query
    var containsPlayers = restPlayers.where((player) {
      return player.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Sort the filtered players by their last name, and tie-break by first name
    beginsWithPlayers.sort(_sortPlayers);
    containsPlayers.sort(_sortPlayers);

    return beginsWithPlayers; // + containsPlayers;
  }

  void _endSet() {
    // Store the set information to the database
    // Each set contains shots for this session
    // debugPrint('$sessionShots');
    // for (Shot shot in sessionShots) {
    //  debugPrint('$shot');
    //}
    // Copy list for fire and forget recording into DB
    //  _dbHelper.recordSet(List.from(sessionShots));

    // record end timestamp
    _updateTrainingSet(endTimestamp: DateTime.now());
    // save set to DB (first convert view model to db model)
    _dbHelper.recordTrainingSet(TrainingSet.fromMap(widget.trainingSet.toMap()));

    // clear shot counter and timestamps from state
    _updateTrainingSet(
        madeShots: 0,
        totalShots: 0,
        startTimestamp: DateTime.now(), // so that if the next set's shots are manually entered we have a start time
        endTimestamp: null // this will be set when end-set button is pressed
    );

    // clear shot counter from screen
    setState(() {
      // Reset the shot counter and shots for the next set
      madeShots = 0;
      totalShots = 0;
      _updateShotCounterControllers();
      //     sessionShots.clear();
    });

    // Optionally show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Set recorded! Ready for the next set.')),
    );
  }

  void _onMadeChanged(String value) {
    setState(() {
      if (value == "")  return;
      madeShots = int.tryParse(value) ?? 0;
      // made shots must be less than or equal to total shots
      if (madeShots > totalShots) {
        totalShots = madeShots;
      }
      _updateTrainingSet(
          madeShots: madeShots,
          totalShots: totalShots,
      );
      _updateShotCounterControllers();

    });
  }

  void _onTotalSubmitted(String value) {
    setState(() {
      totalShots = int.tryParse(value) ?? 0;
      // made shots must be less than or equal to total shots
      if (madeShots > totalShots) {
        madeShots = totalShots;
      }
      _updateTrainingSet(
        madeShots: madeShots,
        totalShots: totalShots,
      );
      _updateShotCounterControllers();

    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return BlocBuilder<SessionBloc, SessionState>(builder: (context, state) {
      final currentSet = state
          .trainingSets[widget.tabIndex]; // Get the current set from the state
      if (!(currentSet.isDummyName ?? false)) {
        _typeAheadController.text = currentSet.playerName ?? "";
      }
      // if(currentSet.startTimestamp == null)
      //   _updateTrainingSet(startTimestamp: DateTime.now());
      return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                Positioned(
                  child: _setControlColumn(height , width - 52),
                ),
                _setInfoForm(currentSet, height, width),

              ])
            ],
          ));
    });
  }

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

  Widget _madeShotButton(minHeight, minWidth) {
    return ElevatedButton(
      onPressed: () => _incrementShot(true),
      style: //ElevatedButton.styleFrom(backgroundColor: Colors.green),
      ElevatedButton.styleFrom(
        elevation: 3,
        minimumSize: Size(minWidth, minHeight),
        maximumSize: Size(minWidth, minHeight),
        side: BorderSide(
          color: Colors.green,
          width: 3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        // StarBorder(
        //   //side: //BorderSide.merge(BorderSide.none, BorderSide()),
        //         points: 200,
        //   innerRadiusRatio: 0.7,
        //   pointRounding: 0.4,
        //   squash: 0.5,
        //   valleyRounding: 0.6,
        //   rotation: 90,
        //
        //     ),
        //side: BorderSide(color: Color(0xFF007006)),
        foregroundColor: Colors.black,
        backgroundColor: Colors.green.shade200,
        //const Color(0xFF007006),
        shadowColor: Colors.lightGreen,
        surfaceTintColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text('Made', style: TextStyle(fontSize: 18)
        //GoogleFonts.ibmPlexSans(
        //fontSize: 18 ,
        // fontWeight: FontWeight.bold,
        //),
      ),
    );
  }

  Widget _missedShotButton(double minHeight, double minWidth) {
    return ElevatedButton(
      onPressed: () => _incrementShot(false),
      style: ElevatedButton.styleFrom(
        elevation: 3,
        minimumSize: Size(minWidth, minHeight),
        maximumSize: Size(minWidth, minHeight),
        side: BorderSide(
          color: Colors.red,
          width: 3,
          strokeAlign: BorderSide.strokeAlignInside
        ),
        foregroundColor: Colors.black,
        //backgroundColor: Color.alphaBlend(Colors.redAccent, Colors.yellow),
         backgroundColor: Colors.redAccent.shade200,//Color(0xFFB41D13),
        //backgroundColor: Colors.green.shade200,
        //const Color(0xFF007006),
        shadowColor: Colors.lightGreen,
        surfaceTintColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      // backgroundColor: Color(0xFFB41D13),
      // style: elevatedbutton.stylefrom(
      //   //side: borderside(color: color(0xc0d03608)),
      //   foregroundcolor: colors.black,
      //   backgroundcolor: colors.red.shade100,
      //   //color(0xc8ec5648),
      //   shadowcolor: colors.grey,
      //   surfacetintcolor: colors.black,
      //   padding: const edgeinsets.symmetric(horizontal: 24, vertical: 12),
      // ),
      child: Text(
        'Missed',
        style: TextStyle(
          fontSize: 18,
        ),
        // style: GoogleFonts.barlow(
        //   //fontSize: 18 ,
        //   fontWeight: FontWeight.bold,
        // ),
      ),
    );
  }

  Widget _setInfoForm(TrainingSetViewModel currentSet, double ctxHeight, double ctxWidth) {
    return ExpansionTile(
        controller: _setInfoExpansionTileController,
        collapsedIconColor: const Color(0xFF000000),
        backgroundColor: Colors.blue.shade100,
        collapsedBackgroundColor: Colors.blue.shade100,
        shape: const RoundedRectangleBorder(
            side: BorderSide(width: 1, color: _setInfoFormBorderColor,
                strokeAlign: BorderSide.strokeAlignInside),
            // side: BorderSide.lerp(BorderSide.none, BorderSide(), 0.9),
            borderRadius: //BorderRadius.circular(15),
            BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5))),
        collapsedShape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: _setInfoFormBorderColor,
              strokeAlign: BorderSide.strokeAlignInside),
          //side: BorderSide.lerp(BorderSide.none, BorderSide(), 0.9),
          borderRadius: BorderRadius.circular(_collapsedSetInfoFormBorderRadius),
        ),
        dense: true,
        initiallyExpanded: false,
        //title: const Text('Set Info: Tap to expand/collapse'),
        title: const Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'Set Info |',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ' Tap to expand/collapse',
                //style: TextStyle(fontStyle: FontStyle.italic),
              )
            ],
          ),
        ),
        //subtitle: Text('Tap arrow to expand/collapse'),
        children: [
          Form(
            key: _setInfoFormKey,
            child: Column(
              children: [
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
/*                  validator: (str) {
                    debugPrint("validator: $str");
                    if (str?.isNotEmpty ?? false)
                      return "No player named $str found. Please create player or select known player";
                    return "Please select a player";
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,*/
                  // initialValue: savedSet.playerName,
                  /*textFieldConfiguration: TextFieldConfiguration(
                    controller: _typeAheadController,
                    decoration: const InputDecoration(
                      hintText: "Search Player",
                      //labelText: '${currentSet.playerName}',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),*/
                  suggestionsCallback: (String pattern) {
                    return _getSuggestions(pattern);
                  },
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
                      _updateTrainingSet(
                        playerId: suggestion.id,
                        playerName: suggestion.name,
                        isDummyName: false,
                      );
                    });
                  },
                  emptyBuilder: (context) => const ListTile(
                    title: Text('No players found'),
                  ),
                ),
                // Position Dropdown
                DropdownButtonFormField<String>(
                  value: currentSet.position,
                  hint: const Text(' Select Position'),
                  onChanged: (String? newPosition) {
                    _updateTrainingSet(position: newPosition);
                  },
                  items: <String>['Guard', 'Wing', 'Big']
                      .map((String position) {
                    return DropdownMenuItem<String>(
                      value: position,
                      child: Text(
                        " $position",
                      ),
                    );
                  }).toList(),
                ),
                // Shot Category Dropdown
                DropdownButtonFormField<String>(
                  value: currentSet.shotCategory,
                  hint: const Text(' Select Shot Category'),
                  onChanged: (String? newCategory) {
                    _updateTrainingSet(shotCategory: newCategory);
                  },
                  items: <String>['Two Ball', 'Three Ball', 'Free Throw']
                      .map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(" $category"),
                    );
                  }).toList(),
                ),
                // Drill Dropdown
                DropdownButtonFormField<String>(
                  value: currentSet.drill,
                  hint: const Text(' Select Drill'),
                  onChanged: (String? newDrill) {
                    _updateTrainingSet(drill: newDrill);
                  },
                  items: _getDrillsForPositionAndCategory(
                      currentSet.position, currentSet.shotCategory)
                      .map((String drill) {
                    return DropdownMenuItem<String>(
                      value: drill,
                      child: Text(" $drill"),
                    );
                  }).toList(),
                ),
                // Location Dropdown
                DropdownButtonFormField<String>(
                  value: currentSet.location,
                  hint: const Text(' Select Location'),
                  onChanged: (String? newLocation) {
                    _updateTrainingSet(location: newLocation);
                  },
                  items: _getLocationsForDrill(currentSet.drill)
                      .map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(" $location"),
                    );
                  }).toList(),
                )
              ]
            ),
          ),
    ]);
  }

  Widget _setControlColumn(double contextHeight, double contextWidth) {
    double height = contextHeight;
    double width = contextWidth;
    return
      Column(children: [
        SizedBox(height: height*0.07),
        _buildShotCounterRow(),
        SizedBox(height: height*0.009 ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _madeShotButton(height / 2, width / 2 ),
            const SizedBox(width: 20),
            _missedShotButton(height / 2, width / 2 ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed:() {
              // validate set info
              if (widget.trainingSet.isDummyName ?? false) {
               // tell user they need to fill out the set info form
                // and uncollapse the form with validation errors shown on it
                _showValidationErrors();
                return ;
              }
              _endSet();
            },
            style: ElevatedButton.styleFrom(
              side: BorderSide(width: 2.5,
                  color: Colors.blue,
                  style: BorderStyle.values[1],
                  strokeAlign: BorderSide.strokeAlignInside),
              //shadowColor: Colors.amberAccent,
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
            child: const Text('End Set'),
          ),
        ),

      ]);
  }

  // Method to build the row displaying the shot counters
  Widget _buildShotCounterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Shots:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildShotTextField(controller: _madeController, onChanged: _onMadeChanged),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'out of',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildShotTextField(controller: _totalController, onSubmitted: _onTotalSubmitted),
            ],
          ),
        ),
      ],
    );
  }

  // Method to build made TextField for shot counts
  Widget _buildMadeShotTextField(
      TextEditingController controller, Function(String) onChanged) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // Method to build made TextField for shot counts
  Widget _buildTotalShotTextField(
      TextEditingController controller, Function() onEditingComplete) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onEditingComplete: onEditingComplete,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // Method to build made TextField for shot counts
  Widget _buildShotTextField({
      required TextEditingController controller,
      Function(String)? onChanged,
      Function(String)? onSubmitted
  }) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _old_buildShotCounterRow() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Text(
              'Shots: $madeShots out of $totalShots',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        ]);

  }

  void _showValidationErrors() {
    ScaffoldMessenger.of(context).showSnackBar(
      getToastySnackBar(
        msg: "Please fill out the set information before ending the set.",
        bgColor: Colors.red,
        duration: const Duration(milliseconds: 2400),
        context: context,
      )
    );
      _setInfoExpansionTileController.expand();
      // Uncollapse the form
      setState(() {
        _isFormCollapsed = false;
      });
  }
}
