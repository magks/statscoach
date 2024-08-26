import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'shot_recording_screen.dart';
import 'shot_list_screen.dart';
import 'shot_chart_screen.dart';
import 'team_management_screen.dart';
import '../main.dart'; // Import to access the isInDebugMode flag
class MainScreen extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper();
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamManagementScreen()),
                );
              },
              child: Text('Manage Team'),
            ),
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
                  MaterialPageRoute(builder: (context) => ShotRecordingScreen()),
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShotChartScreen()),
                );
              },
              child: Text('View Shot Chart'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Export data as CSV
                String filePath = await dbHelper.exportShotsToCSV();
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
                  await dbHelper.clearDatabase();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Database cleared')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Clear Database (Dev Only)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
