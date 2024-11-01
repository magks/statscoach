import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stats_coach/blocs/session_bloc.dart';
import 'package:stats_coach/blocs/stats_bloc.dart';
import 'dart:io';
import 'package:stats_coach/routing/go_router_config.dart';

import 'package:stats_coach/screens/main_screen.dart';
//import 'package:stats_coach/screens/main_screen_dev.dart'; // Import dart:io to use Platform class

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

  runApp(
    MultiBlocProvider(
        providers: [
          BlocProvider<SessionBloc>(
            create: (context) => SessionBloc(),
          ),
          BlocProvider<StatsBloc>(
            create: (context) => StatsBloc(),
          ),
        ],
        child: StatsCoachApp()
    )
  );
}

bool isDesktop() {
  // Use Platform class to determine if the app is running on a desktop platform
  return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}

class StatsCoachApp extends StatelessWidget {
  const StatsCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
          title: 'Stats Coach',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'GolosText'
          ),
          routerConfig: goRouterConfig,
    );
  }
}
