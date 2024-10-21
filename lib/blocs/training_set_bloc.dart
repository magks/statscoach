import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stats_coach/blocs/session_events.dart';
import 'package:stats_coach/blocs/session_state.dart';
import 'package:stats_coach/models/player.dart';

import 'training_set_events.dart';
import 'training_set_state.dart';

class TrainingSetBloc extends Bloc<TrainingSetEvent, TrainingSetState> {
  TrainingSetBloc() : super(const TrainingSetState()) {
    // Register the PlayerSelected event handler
/*
    on<PlayerSelected>((event, emit) {
      final sessionPlayers = List<Player>.from(state.players);

      // Ensure the list can accommodate the index
      if (sessionPlayers.length <= event.tabIndex) {
        sessionPlayers.add(event.player);
      } else {
        sessionPlayers[event.tabIndex] = event.player;
      }

      emit(state.copyWith(players: sessionPlayers));
    });
*/
  }

/*
  @override
  Stream<SessionState> mapEventToState(SessionEvent event) async* {
    if (event is PlayerSelected) {
      final updatedPlayers = List<Player>.from(state.players);
      if (updatedPlayers.length <= event.tabIndex) {
        updatedPlayers.add(event.player);
      }
      else {
        updatedPlayers[event.tabIndex] = event.player;
      }
      yield state.copyWith(players: updatedPlayers);
    } else if (event is ShotRecorded) {
      final updatedMadeShots = List<int>.from(state.madeShots);
      final updatedTotalShots = List<int>.from(state.totalShots);
      // if first time recording, initialize shot counters
      if (updatedMadeShots.length <= event.tabIndex) {
        updatedMadeShots.add(0);
        updatedTotalShots.add(0);
      }
      // update shot stats
      if (event.isMade) {
        ++updatedMadeShots[event.tabIndex];
      }
      ++updatedTotalShots[event.tabIndex];
      yield state.copyWith(madeShots: updatedMadeShots, totalShots: updatedTotalShots);
    }
  }
*/
}