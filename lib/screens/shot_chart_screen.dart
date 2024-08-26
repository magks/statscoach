import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:stats_coach/models/contained_image.dart';
import 'package:stats_coach/widgets/heat_map.dart';
import '../models/player.dart';
import '../services/database_helper.dart';
import '../models/shot.dart';

class ShotChartScreen extends StatefulWidget {
  @override
  _ShotChartScreenState createState() => _ShotChartScreenState();
}

class _ShotChartScreenState extends State<ShotChartScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Shot> shots = [];
  List<Shot> filteredShots = [];
  Map<int, String> playerNames = {};
  String? _selectedPlayer;
  String? _selectedShotType;
  bool _showHeatmap = false; // Track heatmap visibility
  ui.Image? _courtImage; // To hold the loaded image
  double _imageWidth = 0;
  double _imageHeight = 0;

  double get opacityOnHeatMap => _showHeatmap ? 0 : 1;

  @override
  void initState() {
    super.initState();
    _loadShots();
    _loadImage();
  }

  Future<void> _loadShots() async {
    List<Shot> shotList = await dbHelper.getShots();
    List<Player> playerList = await dbHelper.getPlayers();
    setState(() {
      shots = shotList;
      filteredShots = shotList;
      playerNames = {for (var player in playerList) player.id!: player.name};
    });
  }
  Future<void> _loadImage() async {
    final ImageStream stream = const AssetImage('assets/basketball_court.png').resolve(ImageConfiguration());
    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _courtImage = info.image;
        _imageWidth = info.image.width.toDouble();
        _imageHeight = info.image.height.toDouble();
      });
    }));
  }

  void _showShotDetails(Shot shot) {
    String playerName = playerNames[shot.playerId] ?? 'Unknown Player';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Shot Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Player: $playerName'),
              Text('Shot Type: ${shot.shotType}'),
              Text('Blocked: ${shot.wasBlocked ? "Yes" : "No"}'),
              Text('Involved Dribble: ${shot.involvedDribble ? "Yes" : "No"}'),
              Text('Location: (${shot.xLocation.toStringAsFixed(2)}, ${shot.yLocation.toStringAsFixed(2)})'),
              Text('Time: ${shot.timestamp}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _filterShots() {
    setState(() {
      filteredShots = shots.where((shot) {
        if (_selectedPlayer != null && playerNames[shot.playerId] != _selectedPlayer) return false;
        if (_selectedShotType != null && shot.shotType != _selectedShotType) return false;
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shot Chart'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    hint: Text('Select Player'),
                    value: _selectedPlayer,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPlayer = newValue;
                        _filterShots();
                      });
                    },
                    items: playerNames.values.map((String player) {
                      return DropdownMenuItem<String>(
                        value: player,
                        child: Text(player),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: DropdownButton<String>(
                    hint: Text('Select Shot Type'),
                    value: _selectedShotType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedShotType = newValue;
                        _filterShots();
                      });
                    },
                    items: <String>['2pt', '3pt', 'Free-throw'].map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                ),

              ],
          ),
          ),
    Expanded(
    child: _courtImage == null
    ? Center(child: CircularProgressIndicator())
        : LayoutBuilder(
    builder: (context, constraints) {
      ContainedImage cImage = ContainedImage(
        constraints.maxWidth,
        constraints.maxHeight,
        _imageWidth,
        _imageHeight,
      );

      return Center(
        child: Stack(
          children: [
            Positioned(
              left: cImage.imageLeftOffset,
              top: cImage.imageTopOffset,
              width: cImage.displayedWidth,
              height: cImage.displayedHeight,
              child: Image.asset(
                'assets/basketball_court.png',
                fit: BoxFit.contain,
              ),
            ),
            //DummyHeatmapOverlay(),
            if (_showHeatmap) HeatmapOverlay(filteredShots, cImage),
            ...filteredShots.map((shot) {
              // Calculate the shot's position relative to the displayed image size
              final double xPos = cImage.projectXCoordOnImage(shot.xLocation);
              final double yPos = cImage.projectYCoordOnImage(shot.yLocation);

              return Positioned(
                left: xPos - 0, // Adjust for marker size
                top: yPos - 0,
                child: GestureDetector(
                  onTap: () => _showShotDetails(shot),
                  child: Icon(
                    Icons.circle,
                    color: shot.shotType == '3pt'
                        ? Colors.green.withOpacity(opacityOnHeatMap)
                        : Colors.blue.withOpacity(opacityOnHeatMap),
                    size: 10.0,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      );
    },
    ),
    ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  value: _showHeatmap,
                  onChanged: (bool value) {
                    setState(() {
                      _showHeatmap = value;
                    });
                  },
                  activeColor: Colors.red,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
                Text('Heatmap'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

