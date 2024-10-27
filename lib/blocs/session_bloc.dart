import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stats_coach/blocs/session_events.dart';
import 'package:stats_coach/blocs/session_state.dart';
import 'package:stats_coach/models/player.dart';
import 'package:stats_coach/models/training_set.dart';
import 'package:stats_coach/viewmodels/training_set_view_model.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  static const TrainingSetViewModel _initialTrainingSetViewModel = TrainingSetViewModel(
    playerId: 0,
    playerName: "Player 1",
    isDummyName: true,
    isSetInfoFormExpanded: false,
  );


  SessionBloc() : super(SessionState(
    trainingSets: [_initialTrainingSetViewModel],
    currentTabIndex: 0,
  )) {
    on<DedupPlayerDisplayNames>(_onDedupPlayerDisplayNames);
    on<SendPlayerToSession>(_onSendPlayerToSession);
    on<UpdatePlayerInSession>(_onUpdatePlayerInSession);
    on<AddPlayer>(_onAddPlayer);
    on<RemovePlayer>(_onRemovePlayer);
    on<UpdateCurrentTab>(_onUpdateCurrentTab);
    on<TrainingSetViewModelUpdated>(_onTrainingSetViewModelUpdated);

  }

  void _onDedupPlayerDisplayNames(DedupPlayerDisplayNames event, Emitter<SessionState> emit) {
    int firstMatchIdx = -1, playerCounter = 0, idx = 0;
    List<TrainingSetViewModel> updatedTrainingSetViewModels = List.from(state.trainingSets);
    for (var trainingSet in state.trainingSets) {
      // if player matches -- not dummy player and same player id
      if (!(trainingSet.isDummyName ?? false) && trainingSet.playerId == event.player.id) {
        ++playerCounter;
        firstMatchIdx = firstMatchIdx < 0 ? idx : firstMatchIdx; // save idx only if its the first match
        updatedTrainingSetViewModels[idx] = trainingSet.copyWith(
          playerDisplayName: "${event.player.name} ($playerCounter)",
          dupPlayerIdx: playerCounter
        );
      }
      ++idx;
    }
    // to avoid multiple passes of the list, the loop above assumes there will be
    // dupes, so we revert the changed display name if there were no dupes
    if (playerCounter == 1) {
      updatedTrainingSetViewModels[firstMatchIdx] = updatedTrainingSetViewModels[firstMatchIdx]
          .copyWith(
            playerDisplayName: "${event.player.name}",
          );
    }
    emit(state.copyWith(trainingSets: updatedTrainingSetViewModels));
  }


  void _onSendPlayerToSession(SendPlayerToSession event, Emitter<SessionState> emit) {
    // either replace first dummy player or add to end
    bool isDummyFound = false;
    final updatedTrainingSetViewModels = state.trainingSets.map((trainingSet) {
      // if havent found dummy and player is dummy, replace with this player
      if (!isDummyFound && (trainingSet.isDummyName ?? false)){
        isDummyFound = true;
        return trainingSet.copyWith(
            playerName: event.player.name,
            playerId: event.player.id,
            isDummyName: false,
        );
      }
      return trainingSet;
    }).toList(growable: false);

    if (!isDummyFound) {
      final newSet = TrainingSetViewModel(
        playerName: event.player.name,
        isDummyName: false,
        startTimestamp: DateTime.now(),
        playerId: event.player.id,
      );
      _onAddPlayer(AddPlayer(newSet), emit);
      return;
    }

    emit(state.copyWith(trainingSets: updatedTrainingSetViewModels));
  }

  void _onUpdatePlayerInSession(UpdatePlayerInSession event, Emitter<SessionState> emit) {
    final updatedTrainingSetViewModels = state.trainingSets.map((trainingSet) {
      // if player exists in session, update their name
      if (trainingSet.playerId == event.updatedPlayer.id) {
        return trainingSet.copyWith(
            playerName: event.updatedPlayer.name,
            playerDisplayName: event.updatedPlayer.name
        );
      }
      return trainingSet;
    }).toList(growable: false);

    emit(state.copyWith(trainingSets: updatedTrainingSetViewModels));
  }

  void _onAddPlayer(AddPlayer event, Emitter<SessionState> emit) {
    final updatedSets = List<TrainingSetViewModel>.from(state.trainingSets)..add(event.newTrainingSetViewModel);
    emit(state.copyWith(trainingSets: updatedSets));
  }

  void _onRemovePlayer(RemovePlayer event, Emitter<SessionState> emit) {
    final updatedSets = List<TrainingSetViewModel>.from(state.trainingSets)..removeAt(event.tabIndex);
    int newTabIndex = event.tabIndex >= updatedSets.length ? updatedSets.length - 1 : event.tabIndex;
    emit(state.copyWith(currentTabIndex: 0));
    //emit(state.copyWith(trainingSets: updatedSets, currentTabIndex: newTabIndex));
    emit(state.copyWith(trainingSets: updatedSets));
  }


  void _onUpdateCurrentTab(UpdateCurrentTab event, Emitter<SessionState> emit) {
    emit(state.copyWith(currentTabIndex: event.tabIndex));
  }

  void _onTrainingSetViewModelUpdated(TrainingSetViewModelUpdated event, Emitter<SessionState> emit) {
    final updatedTrainingSetViewModels = List<TrainingSetViewModel>.from(state.trainingSets);
    if (updatedTrainingSetViewModels.length <= event.tabIndex) {
      updatedTrainingSetViewModels.add(event.trainingSet);
    } else {
      updatedTrainingSetViewModels[event.tabIndex] = event.trainingSet;
    }
    emit(state.copyWith(trainingSets: updatedTrainingSetViewModels));
  }

  /*

    // Register the PlayerSelected event handler
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
    // Handle TrainingSetViewModel updates
    on<TrainingSetViewModelUpdated>((event, emit) {
      final updatedTrainingSetViewModels = List<TrainingSetViewModel>.from(state.trainingSets);

      if (updatedTrainingSetViewModels.length <= event.tabIndex) {
        updatedTrainingSetViewModels.add(event.trainingSet);
      } else {
        updatedTrainingSetViewModels[event.tabIndex] = event.trainingSet;
      }

      emit(state.copyWith(trainingSets: updatedTrainingSetViewModels));
    });

    on<RemoveFromSession>((event, emit) {

      debugPrint("Removing state at index ${event.tabIndex}");

      debugPrint('Players before removal...');
      for (Player p in state.players) {
        debugPrint("player id = ${p.id}, player name=${p.name}");
      }


      debugPrint('training sets before removal...');
      for (TrainingSetViewModel t in state.trainingSets) {
        debugPrint("training set id = ${t.id}, training set player name=${t.playerName}, set position: ${t.position}");
      }

      final updatedPlayers = List<Player>
                                .from(state.players)
                                ..removeAt(event.tabIndex);
      final updatedTrainingSetViewModels = List<TrainingSetViewModel>
                                    .from(state.trainingSets)
                                    ..removeAt(event.tabIndex);

      emit(state.copyWith(
          players: updatedPlayers,
          trainingSets: updatedTrainingSetViewModels
      ));

      debugPrint('Players after removal...');
      for (Player p in state.players) {
        debugPrint("player id = ${p.id}, player name=${p.name}");
      }


      debugPrint('training sets after removal...');
      for (TrainingSetViewModel t in state.trainingSets) {
        debugPrint("training set id = ${t.id}, training set player name=${t.playerName}, set position: ${t.position}");
      }

    });
   */
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