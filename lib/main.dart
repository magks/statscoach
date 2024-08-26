import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'package:stats_coach/screens/main_screen.dart'; // Import dart:io to use Platform class

const bool isInDebugMode = kDebugMode;//!bool.fromEnvironment("dart.vm.product");
void main() {

  // Only necessary if binding needs to be initialized before calling runApp
  // such as when main calls an async function that depends on WidgetFlutterBinging
  // to be initialized (e.g. Firebase is used).
  // Included here regardless to silence the warning on android "W/Parcel:  Expecting binder got null!"
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize sqflite_common_ffi for desktop platforms
  if (isDesktop()) {
    databaseFactory = databaseFactoryFfi;
  }

  runApp(StatsCoachApp());
}

bool isDesktop() {
  // Use Platform class to determine if the app is running on a desktop platform
  return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}

class StatsCoachApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stats Coach',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}
