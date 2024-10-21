import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:stats_coach/services/database_helper.dart'; // Import your DatabaseHelper class

class ExportService {
  //final DatabaseHelper _dbHelper;

  ExportService();

  Future<String> exportShotsToCSV() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> shots = await db.query('shots');

    List<List<dynamic>> rows = [];

    // Adding the header row
    rows.add([
      'Shot ID',
      'Player ID',
      'Timestamp',
      'Game ID',
      'Session ID',
      'Shot Type',
      'X Location',
      'Y Location',
      'Was Blocked',
      'Involved Dribble',
      'Success'
    ]);

    // Adding shot data rows
    for (var shot in shots) {
      rows.add([
        shot['id'],
        shot['playerId'],
        shot['timestamp'],
        shot['gameId'],
        shot['sessionId'],
        shot['shotType'],
        shot['xLocation'],
        shot['yLocation'],
        shot['wasBlocked'] == 1 ? 'Yes' : 'No',
        shot['involvedDribble'] == 1 ? 'Yes' : 'No',
        shot['success'] == 1 ? 'Yes' : 'No',
      ]);
    }

    // Convert the rows to CSV format
    String csvData = const ListToCsvConverter().convert(rows);

    // Get the directory to store the file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/shots_export.csv';

    // Write the CSV data to a file
    final file = File(path);
    await file.writeAsString(csvData);

    return path; // Return the path to the saved file
  }
}
