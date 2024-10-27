import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stats_coach/routing/scaffold_with_nav_bar.dart';
import 'package:stats_coach/screens/dynamic_player_session_screen.dart';
import 'package:stats_coach/screens/main_screen.dart';
import 'package:stats_coach/screens/stats_screen.dart';
import 'package:stats_coach/screens/training_management_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GlobalKey<NavigatorState> _sectionMainNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionMainNav');


/// The route configuration.
final GoRouter goRouterConfig = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/training_session',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          // Return the widget that implements the custom shell (in this case
          // using a BottomNavigationBar). The StatefulNavigationShell is passed
          // to be able access the state of the shell and to navigate to other
          // branches in a stateful way.
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // The route branch for the first tab of the bottom navigation bar.
          playersBranch(),
          trainingSessionBranch(),
          statsBranch(),

        ],
    ),
  ],
);

trainingSessionBranch() {
  return StatefulShellBranch(
    // It's not necessary to provide a navigatorKey if it isn't also
    // needed elsewhere. If not provided, a default key will be used.
    routes: <RouteBase>[
      GoRoute(
        // The screen to display as the root in the second tab of the
        // bottom navigation bar.
        path: '/training_session',
        builder: (BuildContext context, GoRouterState state) =>
          DynamicPlayerSessionScreen(),
      ),
    ],
  );

}

StatefulShellBranch playersBranch() {
  return StatefulShellBranch(
      navigatorKey: _sectionMainNavigatorKey,
      routes: <RouteBase>[
        GoRoute(
          // The screen to display as the root in the first tab of the
          // bottom navigation bar.
          path: '/players',
          builder: (BuildContext context, GoRouterState state) =>
              TrainingManagementScreen(),
          /*routes: <RouteBase>[
                  // The details screen to display stacked on navigator of the
                  // first tab. This will cover screen A but not the application
                  // shell (bottom navigation bar).
                  GoRoute(
                    path: 'details',
                    builder: (BuildContext context, GoRouterState state) =>
                        const DetailsScreen(label: 'A'),
                  ),
                ],*/
        ),
      ]          // The route branch for the second tab of the bottom navigation bar.
  );

}

StatefulShellBranch statsBranch() {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: '/stats',
        builder: (BuildContext context, GoRouterState state) => StatsScreen(),
      ),
    ],
  );
}

