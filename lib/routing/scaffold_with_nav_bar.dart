import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The StatefulNavigationShell from the associated StatefulShellRoute is
      // directly passed as the body of the Scaffold.
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFFFD82),
          selectedItemColor: Color(0xFF130E06),
        unselectedItemColor: Color(0xFF545454),
        selectedFontSize: 0,
        unselectedFontSize: 0,
        // Here, the items of BottomNavigationBar are hard coded. In a real
        // world scenario, the items would most likely be generated from the
        // branches of the shell route, which can be fetched using
        // `navigationShell.route.branches`.
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts_sharp), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.sports_basketball_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.query_stats_sharp), label: ''),
        ],
        currentIndex: navigationShell.currentIndex,
        // Navigate to the current location of the branch at the provided index
        // when tapping an item in the BottomNavigationBar.
        onTap: (int index) => _onTap(context, index)//navigationShell.goBranch(index),
      ),
    );
  }


  /// NOTE: For a slightly more sophisticated branch switching, change the onTap
  /// handler on the BottomNavigationBar above to the following:
  /// `onTap: (int index) => _onTap(context, index),`
  // ignore: unused_element
  void _onTap(BuildContext context, int index) {
    // When navigating to a new branch, it's recommended to use the goBranch
    // method, as doing so makes sure the last navigation state of the
    // Navigator for the branch is restored.
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}