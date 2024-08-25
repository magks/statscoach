import 'package:flutter/material.dart';
import 'team_management_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coach Stats App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to team management screen
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
                // Navigate to shot recording screen
              },
              child: Text('Start New Game/Practice'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to stats screen
              },
              child: Text('View Statistics'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Export data as CSV
              },
              child: Text('Export Data'),
            ),
          ],
        ),
      ),
    );
  }
}

