import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io'; // Import dart:io to use Platform class
import 'screens/main_screen.dart';

void main() {
  // Initialize sqflite_common_ffi for desktop platforms
  if (isDesktop()) {
    databaseFactory = databaseFactoryFfi;
  }

  runApp(CoachStatsApp());
}

bool isDesktop() {
  // Use Platform class to determine if the app is running on a desktop platform
  return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}

class CoachStatsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coach Stats App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}
