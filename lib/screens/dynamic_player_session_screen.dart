import 'package:flutter/material.dart';
//import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:stats_coach/blocs/session_bloc.dart';
import 'package:stats_coach/blocs/session_events.dart';
import 'package:stats_coach/blocs/session_state.dart';
import 'package:stats_coach/models/training_set.dart';
import 'package:stats_coach/screens/dynamic_shot_recording_screen.dart';
import 'package:stats_coach/viewmodels/training_set_view_model.dart';
import '../models/player.dart';
import '../services/database_helper.dart';

// todo make tabs drag and drop
// todo make tabs selectable
class DynamicPlayerSessionScreen extends StatefulWidget {
  @override
  _DynamicPlayerSessionScreenState createState() => _DynamicPlayerSessionScreenState();
}

class _DynamicPlayerSessionScreenState extends State<DynamicPlayerSessionScreen> {
  @override
  Widget build(BuildContext context) {
    //Future.delayed(Duration)
    // No need to create a BlocProvider here, we just use the existing one from above
    return Scaffold(
      //appBar: AppBar(title: const Text('Player Sessions')),
      floatingActionButton: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state)  {
            return _buildSpeedDial(context, state);
          }),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          double screenHeight = MediaQuery.of(context).size.height;
          return Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.05), //x,y -- -1 is top, 1 is bottom
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              //Spacer(flex: 1), // Pushes the content down
              Expanded(
                child: DynamicTabBarWidget(
                  dynamicTabs: _buildTabs(state),
                  showBackIcon: state.trainingSets.length > 1,
                  showNextIcon: state.trainingSets.length > 1,
                  isScrollable: true,
                  onAddTabMoveTo: MoveToTab.last,
                  onRemoveTabMoveTo: MoveToTab.idol,
                  // onTabAdded: (index) {
                  //   debugPrint("tab added");
                  //  // setState(() { });
                  // },
                  onTabRemoved: (index) {
                    debugPrint("tab removed: $index");
                    debugPrint("fixing dummy names");

                    // if a training set is using a dummy player,
                    // update the name to reflect an increasing dummy name counter
                    for (int i = 0, dummyCounter = 1 ; i < state.trainingSets.length; ++i, ++dummyCounter){
                      if ( (state.trainingSets[i].isDummyName ?? false)
                          && !(state.trainingSets[i].playerName?.endsWith((dummyCounter).toString()) ?? false)
                      )
                      {
                        context.read<SessionBloc>().add(TrainingSetViewModelUpdated(i,
                          state.trainingSets[i].copyWith(playerName: 'Player $dummyCounter')
                        ));
                      }
                    }
                   // setState(() { });

                  },
                  // onAddTabMoveTo: MoveToTab.first,
                  onTabChanged: (index) {
                    // When a tab is changed, update the current tab index in the Bloc
                    debugPrint("tab changed to tabIndex=$index");
                    context.read<SessionBloc>().add(UpdateCurrentTab(index ?? 0));
                    setState(() { });
                  },
                  onTabControllerUpdated: (tabController) {
                    debugPrint("DPSS::tabcontroller updated..");

                  },
                ),
              ),
              // Add/remove buttons
              //_buildSpeedDial(context, state),
            ]
              )
          );
        },
      ),// blocbuilder wrapped in scaffold
    );
  }

  List<TabData> _buildTabs(SessionState state) {
    // consider removing timestamp logic since its not needed for business logic
    // checking for initial dummy training set's null startTimestamp and adding if needed
    if (state.trainingSets.first.startTimestamp == null) {
      final updatedInitialSet = state.trainingSets.first.copyWith(startTimestamp: DateTime.now());
      context.read<SessionBloc>().add(TrainingSetViewModelUpdated(0, updatedInitialSet));
    }
    debugPrint("building tab data list with ${state.trainingSets.length} count of training sets and current tab index=${state.currentTabIndex} ");

    return List.generate(state.trainingSets.length, (index) {
      debugPrint("generating tab $index");
      debugPrint("playerName: ${state.trainingSets[index].playerName}"
          " totalShots: ${state.trainingSets[index].totalShots}");
      return TabData(
        index: index,
        title: Tab(
          key: UniqueKey(), //ValueKey('tab_title_${state.trainingSets[index].startTimestamp ?? index}'),
          child:  Row(
            mainAxisSize: MainAxisSize.min,
           children: [
             Text(state.trainingSets[index].playerDisplayName ?? 'Player ${index + 1}'),
             // SizedBox(1
             //   width: 20,
             //   height: 20,
             //   child:
/*               ElevatedButton(
                 style: ElevatedButton.styleFrom(
                     alignment: Alignment.centerLeft,
                     maximumSize: const Size(15,15)),
                 child: const Icon( Icons.info, size: 1, ),
                 onPressed: () => debugPrint("Pressed tab ${index}"),
               ),*/
             //)
           ]
          )
        ),
        content: ShotRecordingScreenV3(
          key: UniqueKey(),//ValueKey('tab_content_${state.trainingSets[index].startTimestamp ?? index}'),
          tabIndex: index,
          trainingSet: state.trainingSets[index],
        ),
      );
    });
  }


  // todo add clear all players
  Widget _buildSpeedDial(BuildContext context, SessionState state) {
    return SpeedDial(
      shape: StadiumBorder(
        side: BorderSide(
          width: 1.5,
          style: BorderStyle.none,
        ),
      ),
      icon: Icons.add,
      gradientBoxShape: BoxShape.circle,
      gradient: RadialGradient(
          focal: Alignment.center,
          focalRadius: 0.41,
        //startAngle: 0.9, // Sweep
          center: Alignment.center,
          stops: List.of([
            0.05,
            0.1,
            0.2,
            0.5,
            0.9
          ]),
          colors: List.of([
            Colors.yellow,
            const Color(0xE8000000),
            Colors.yellowAccent,
            const Color(0xE846D4E5),
            const Color(0xE8000000),
          ])
      ),
      activeIcon: Icons.close,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.person_add),
          backgroundColor: Colors.green,
          label: 'Add Player',
          onTap: () {
            // Add a new player (training set)

            final newSet = TrainingSetViewModel(
                isSetInfoFormExpanded: false,
                playerName: 'Player ${state.trainingSets.length + 1}',
                isDummyName: true,
                startTimestamp: DateTime.now(),
            );
            context.read<SessionBloc>().add(AddPlayer(newSet));
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.person_remove),
          backgroundColor: Colors.red,
          label: 'Remove Player',
          onTap: () {
            final currentIdxAfterRemove = (state.currentTabIndex == state.trainingSets.length - 1)
              ? state.currentTabIndex - 1
              : state.currentTabIndex;

            context.read<SessionBloc>().add(RemovePlayer(state.currentTabIndex));
            context.read<SessionBloc>().add(UpdateCurrentTab(currentIdxAfterRemove));
            //re-add the initial dummy player tab if last player is removed
            if (state.trainingSets.length == 1) {

              // TODO investigate if the inital training set in the session bloc needs a start time
              final newSet = TrainingSetViewModel(
                  isSetInfoFormExpanded: false,
                  playerName: 'Player 1',
                  isDummyName: true,
                  startTimestamp: DateTime.now());
              context.read<SessionBloc>().add(AddPlayer(newSet));
            }
            else {
              context.read<SessionBloc>().add(DedupPlayerDisplayNames(
                  Player(
                    name: state.trainingSets[state.currentTabIndex].playerName ?? "",
                      id: state.trainingSets[state.currentTabIndex].playerId,
                  )
              ));
            }

            setState(() {

            });
          },
        ),
/*        SpeedDialChild(
          child: const Icon(Icons.refresh),
          backgroundColor: Colors.amber,
          label: 'Refresh',
          onTap: () {
            //context.read<SessionBloc>().add(UpdateCurrentTab(currentIndex ?? 0));
            Navigator.pop(context,
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DynamicPlayerSessionScreen()),
            );
            setState(() {
            });
          },
        )*/
      ],
    );
  }
}
