import 'package:flutter/material.dart';
import 'package:stats_coach/screens/dynamic_player_session_screen.dart';
//import 'package:stats_coach/screens/shot_recording_enhanced_generic_screen.dart';
import 'package:stats_coach/services/database_helper.dart';
import 'package:stats_coach/services/export_service.dart';
import 'shot_list_screen.dart';
import 'package:stats_coach/main.dart'; // Import to access the isInDebugMode flag

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stats Coach'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
/*            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PeopleManagementScreen()),
                );
              },
              child: Text(PeopleManagementScreen.DefaultLinkText),
            ),*/
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Record shots for a game
              },
              child: Text('Start New Game/Practice'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DynamicPlayerSessionScreen()),
                );
              },
              child: Text('Record Shot'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShotListScreen()),
                );
              },
              child: Text('View Statistics'),
            ),
            SizedBox(height: 16.0),
/*            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShotChartScreen()),
                );
              },
              child: Text('View Shot Chart'),
            ),*/
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Export data as CSV
                ExportService exportSvc = ExportService();
                String filePath = await exportSvc.exportShotsToCSV();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Data exported to $filePath')),
                );
              },
              child: Text('Export Data'),
            ),
            if (isInDebugMode) ...[
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  await DatabaseHelper.instance.clearDatabase();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Database cleared')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Clear Database (Dev Only)'),
              ),
            ],
            if (isInDebugMode) ...[
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  await DatabaseHelper.instance.addSamplePlayers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Database cleared')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Add Example Players (Dev Only)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
